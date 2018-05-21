//
//  JOVideoLoadingRequestTask.m
//  JODevelop
//
//  Created by JimmyOu on 2018/5/15.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "JOVideoLoadingRequestTask.h"
#import <pthread.h>

@interface JOVideoLoadingRequestTask()
@property (assign, nonatomic) BOOL excuting;
@property (assign, nonatomic) BOOL finished;
@property (assign, nonatomic) BOOL cancelled;
@property (assign, nonatomic) BOOL cached;

@property (strong, nonatomic) AVAssetResourceLoadingRequest *loadingRequest;
@property (assign, nonatomic) NSRange requestRange;
@property (strong, nonatomic) JOVideoPlayerCacheFile *cacheFile;
@property (strong, nonatomic) NSURL *customURL;

@property (nonatomic) pthread_mutex_t lock;

@end
NSUInteger kJOVideoPlayerFileReadBufferSize = 1024 * 32; // 每次只读32K
NSString *kJOVideoPlayerContentRangeKey = @"Content-Range";

@implementation JOVideoLoadingRequestTask

- (void)dealloc {
    pthread_mutex_destroy(&_lock);
}
- (instancetype)initWithLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest
                          requestRange:(NSRange)requestRange
                             cacheFile:(JOVideoPlayerCacheFile *)cacheFile
                             customURL:(NSURL *)customURL
                                cached:(BOOL)cached {
    NSParameterAssert(loadingRequest);
    NSParameterAssert(JOValidByteRange(requestRange));
    NSParameterAssert(cacheFile);
    NSParameterAssert(customURL);
    if(!loadingRequest || !JOValidByteRange(requestRange) || !cacheFile || !customURL){
        return nil;
    }
    
    self = [super init];
    if(self){
        _loadingRequest = loadingRequest;
        _requestRange = requestRange;
        _cacheFile = cacheFile;
        _customURL = customURL;
        _cached = cached;
        _excuting = NO;
        _cancelled = NO;
        _finished = NO;
        Init_PThread_Lock(&_lock);
    }
    return self;
}

+ (instancetype)requestTaskWithLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest
                                 requestRange:(NSRange)requestRange
                                    cacheFile:(JOVideoPlayerCacheFile *)cacheFile
                                    customURL:(NSURL *)customURL
                                       cached:(BOOL)cached {
    return [[[self class] alloc] initWithLoadingRequest:loadingRequest
                                           requestRange:requestRange
                                              cacheFile:cacheFile
                                              customURL:customURL
                                                 cached:cached];
}

- (void)requestDidReceiveResponse:(NSURLResponse *)response {
    NSAssert(NO, @"You must override this method in subclass");
}
- (void)requestDidReciveData:(NSData *)data storeCompletion:(dispatch_block_t)completion {
    NSAssert(NO, @"You must override this method in subclass");
}
- (void)requestDidCompleteWithError:(NSError *)error {
    JODispatchSyncOnMainThread(^{
        self.excuting = NO;
        self.finished = YES;
        if (self.delegate && [self.delegate respondsToSelector:@selector(requestTask:didCompleteWithError:)]) {
            [self.delegate requestTask:self didCompleteWithError:error];
        }
    });
}
- (void)start {
    int lock = pthread_mutex_trylock(&_lock);
    self.excuting = YES;
    if (!lock) {
        pthread_mutex_unlock(&_lock);
    }
}
- (void)startOnQueue:(dispatch_queue_t)queue {
    dispatch_async(queue, ^{
        int lock = pthread_mutex_trylock(&self->_lock);
        self.excuting = YES;
        if (!lock) {
            pthread_mutex_unlock(&self->_lock);
        }
    });
}
- (void)cancel {
    NSLog(@"%@ task has been canceed",[self class]);
    int lock = pthread_mutex_trylock(&_lock);
    self.excuting = NO;
    self.cancelled = YES;
    if (!lock) {
        pthread_mutex_unlock(&_lock);
    }
}

#pragma mark Private
- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)setCancelled:(BOOL)cancelled {
    [self willChangeValueForKey:@"isCancelled"];
    _cancelled = cancelled;
    [self didChangeValueForKey:@"isCancelled"];
}
- (void)setExcuting:(BOOL)excuting {
    [self willChangeValueForKey:@"isExcuting"];
    _excuting = excuting;
    [self didChangeValueForKey:@"isExcuting"];
}

@end
