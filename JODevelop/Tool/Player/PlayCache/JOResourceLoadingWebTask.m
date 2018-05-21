//
//  JOResourceLoadingWebTask.m
//  JODevelop
//
//  Created by JimmyOu on 2018/5/15.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "JOResourceLoadingWebTask.h"
#import <pthread/pthread.h>
#import "JOVideoPlayerCacheFile.h"
@interface JOResourceLoadingWebTask()

@property (assign, nonatomic) UIBackgroundTaskIdentifier backgroundTaskId;
@property (strong, nonatomic) NSURLSessionDataTask *dataTask;
@property (assign, nonatomic) NSUInteger offset;
@property (assign, nonatomic) NSUInteger requestLength;
@property (assign, nonatomic) BOOL haveDataSaved;
@property (nonatomic) pthread_mutex_t plock;

@end

@implementation JOResourceLoadingWebTask

- (void)dealloc {
    NSLog(@"Web task dealloc: %@", self);
    pthread_mutex_destroy(&_plock);
}

- (instancetype)initWithLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest
                          requestRange:(NSRange)requestRange
                             cacheFile:(JOVideoPlayerCacheFile *)cacheFile
                             customURL:(NSURL *)customURL
                                cached:(BOOL)cached {
    NSParameterAssert(JOValidByteRange(requestRange));
    self = [super initWithLoadingRequest:loadingRequest
                            requestRange:requestRange
                               cacheFile:cacheFile
                               customURL:customURL
                                  cached:cached];
    if(self){
       
        Init_PThread_Lock(&_plock);
        _haveDataSaved = NO;
        _offset = requestRange.location;
        _requestLength = requestRange.length;
    }
    return self;
}

- (void)start {
    [super start];
    JODispatchSyncOnMainThread(^{
        [self internalStart];
    });
}

- (void)startOnQueue:(dispatch_queue_t)queue {
    [super startOnQueue:queue];
    dispatch_async(queue, ^{
        [self internalStart];
    });
}
- (void)cancel {
    if (self.isCancelled || self.isFinished) {
        return;
    }
    [super cancel];
    //取消的时候可以先看看有没有需要缓存的
    [self synchronizeCacheFileIfNeeded];
    if (self.dataTask) {
        NSLog(@"cancel a web task, id = %lu",self.dataTask.taskIdentifier);
        [self.dataTask cancel];
        JODispatchSyncOnMainThread(^{
            [[NSNotificationCenter defaultCenter] postNotificationName:JOVideoPlayerDownloadStopNotification object:self];
        });
    }
}
- (BOOL)shouldContinueWhenAppEnterBackground {
    return self.options & JOVideoDownloaderContinueInBackground;
}
- (void)internalStart {
    //task request data from web
    NSParameterAssert(self.unownedSession);
    NSParameterAssert(self.request);
    if (!self.unownedSession || !self.request) {
        [self requestDidCompleteWithError:JOErrorWithDescription(@"task request or session cant be  nil")];
        return;
    }
    if ([self isCancelled]) {
        [self requestDidCompleteWithError:nil];
        return;
    }
    
    //backgroundTask
    if ([self shouldContinueWhenAppEnterBackground] && [UIApplication respondsToSelector:@selector(sharedApplication)]) {
        UIApplication *application = [UIApplication sharedApplication];
        __weak typeof(self) weakSelf = self;
        self.backgroundTaskId = [application beginBackgroundTaskWithExpirationHandler:^{
            __strong typeof(self) strongSelf = weakSelf;
            if (!strongSelf) {
                return ;
            }
            [strongSelf cancel];
            [application endBackgroundTask:strongSelf.backgroundTaskId];
            strongSelf.backgroundTaskId = UIBackgroundTaskInvalid;
        }];
    }
    
    NSURLSession *session = self.unownedSession;
    self.dataTask = [session dataTaskWithRequest:self.request];
    NSLog(@"开始网络请求，dataTask，taskID = %lu",self.dataTask.taskIdentifier);
    [self.dataTask resume];
    if (self.dataTask) {
        [[NSNotificationCenter defaultCenter] postNotificationName:JOVideoPlayerDownloadStartNotification object:self];
    }
    if (self.backgroundTaskId != UIBackgroundTaskInvalid) {
        UIApplication * app = [UIApplication performSelector:@selector(sharedApplication)];
        [app endBackgroundTask:self.backgroundTaskId];
        self.backgroundTaskId = UIBackgroundTaskInvalid;
    }
}

- (void)requestDidReceiveResponse:(NSURLResponse *)response {
    if ([response isKindOfClass:[NSHTTPURLResponse class]] && !self.loadingRequest.contentInformationRequest.contentType) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        [self.cacheFile storeResponse:httpResponse];
        [self.loadingRequest jo_fillContentInformationWithResponse:httpResponse];
        if (![(NSHTTPURLResponse *)response jo_supportRange]) {
            self.offset = 0;
        }
    }
}
- (void)requestDidReciveData:(NSData *)data storeCompletion:(dispatch_block_t)completion {
    if (data.bytes) {
        [self.cacheFile storeVideoData:data atOffset:self.offset synchronize:NO storedCompletion:completion];
        int lock = pthread_mutex_trylock(&_plock);
        self.haveDataSaved = YES;
        self.offset += [data length];
        [self.loadingRequest.dataRequest respondWithData:data];
        
        
        static BOOL _needLog = YES;
        if(_needLog) {
            _needLog = NO;
            NSLog(@"收到数据响应, 数据长度为: %lu", data.length);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                _needLog = YES;
            });
        }
        if (!lock) {
            pthread_mutex_unlock(&_plock);
        }
    }
}
- (void)requestDidCompleteWithError:(NSError *_Nullable)error {
    [self synchronizeCacheFileIfNeeded];
    [super requestDidCompleteWithError:error];
}
- (void)synchronizeCacheFileIfNeeded {
    if (self.haveDataSaved) {
        [self.cacheFile synchronize];
    }
}
@end
