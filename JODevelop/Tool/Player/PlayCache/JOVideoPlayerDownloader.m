//
//  JOVideoPlayerDownloader.m
//  JODevelop
//
//  Created by JimmyOu on 2018/5/15.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "JOVideoPlayerDownloader.h"
#import "JOVideoPlayerCacheFile.h"
#import <pthread.h>
#import "JOVideoPlayerCache.h"

@interface JOVideoPlayerDownloader()<NSURLSessionDelegate, NSURLSessionDataDelegate>

// The session in which data tasks will run
@property (strong, nonatomic) NSURLSession *session;

// The size of received data now.
@property(nonatomic, assign)NSUInteger receivedSize;

/*
 * The expected size.
 */
@property(nonatomic, assign) NSUInteger expectedSize;

@property (nonatomic) pthread_mutex_t lock;

/*
 * The running operation.
 */
@property(nonatomic, weak, nullable) JOResourceLoadingWebTask *runningTask;



@end
@implementation JOVideoPlayerDownloader

+ (nonnull instancetype)sharedDownloader {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (nonnull instancetype)init {
    return [self initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
}

- (nonnull instancetype)initWithSessionConfiguration:(nullable NSURLSessionConfiguration *)sessionConfiguration {
    if ((self = [super init])) {
        Init_PThread_Lock(&_lock);
        _expectedSize = 0;
        _receivedSize = 0;
        _runningTask = nil;
        
        if (!sessionConfiguration) {
            sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        }
        sessionConfiguration.timeoutIntervalForRequest = 15.f;
        
        self.session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                     delegate:self
                                                delegateQueue:nil];
    }
    return self;
}

- (void)downloadVideoWithRequestTask:(JOResourceLoadingWebTask *)requestTask
                     downloadOptions:(JOVideoDownloaderOptions)downloadOptions {
    NSParameterAssert(requestTask);
    if (requestTask.customURL == nil) {
        [self callCompleteDelegateIfNeedWithError:JOErrorWithDescription(@"Please check the download URL, because it is nil")];
        return;
    }
    
    [self reset];
    _runningTask = requestTask;
    _downloaderOptions = downloadOptions;
    [self startDownloadOpeartionWithRequestTask:requestTask
                                        options:downloadOptions];
}

- (void)cancel {
    int lock = pthread_mutex_trylock(&_lock);
    if (self.runningTask) {
        [self.runningTask cancel];
        [self reset];
    }
    if (!lock) {
        pthread_mutex_unlock(&_lock);
    }
}
#pragma mark - Download Operation
- (void)startDownloadOpeartionWithRequestTask:(JOResourceLoadingWebTask *)requestTask
                                      options:(JOVideoDownloaderOptions)options {
    if (!self.downloadTimeout) {
        self.downloadTimeout = 15.f;
    }
    //我们用JOVidepPlayerCache，所以我们不需要NSURLCache
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requestTask.customURL
                                                                cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                            timeoutInterval:self.downloadTimeout];
    request.HTTPShouldHandleCookies = options & JOVideoDownloaderHandleCookies;
    request.HTTPShouldUsePipelining = YES;
    
    if (!self.urlCredential && self.username && self.password) {
        self.urlCredential = [NSURLCredential credentialWithUser:self.username
                                                        password:self.password
                                                     persistence:NSURLCredentialPersistenceForSession];
    }
    NSString *rangeValue = JORangeToHTTPRangeHeader(requestTask.requestRange);
    if (rangeValue) {
        [request setValue:rangeValue forHTTPHeaderField:@"Range"];
    }
    self.runningTask = requestTask;
    requestTask.request = request;
    requestTask.unownedSession = self.session;
}
#pragma mark - Private

- (void)callCompleteDelegateIfNeedWithError:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(downloader:didCompleteWithError:)]) {
        [self.delegate downloader:self didCompleteWithError:error];
    }
}
- (void)reset {
    NSLog(@"调用了 reset");
    self.runningTask = nil;
    self.expectedSize = 0;
    self.receivedSize = 0;
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    if (response) {
        NSLog(@"URLSession will perform HTTP redirection");
        self.runningTask.loadingRequest.redirect = request;
    }
    if(completionHandler){
        completionHandler(request);
    }
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    NSLog(@"URLSession 收到响应");
    if (![response respondsToSelector:@selector(statusCode)] || (((NSHTTPURLResponse *)response).statusCode < 400 && ((NSHTTPURLResponse *)response).statusCode != 304)) {
        NSInteger expected = MAX((NSInteger)response.expectedContentLength, 0);
        self.expectedSize = expected;
        // Support video / audio only.
        BOOL isSupportMIMEType = [response.MIMEType containsString:@"video"] || [response.MIMEType containsString:@"audio"];
        if(!isSupportMIMEType){
            NSLog(@"Not support MIMEType: %@", response.MIMEType);
            JODispatchSyncOnMainThread(^{
                [self cancel];
                [self callCompleteDelegateIfNeedWithError:JOErrorWithDescription([NSString stringWithFormat:@"Not support MIMEType: %@", response.MIMEType])];
                [[NSNotificationCenter defaultCenter] postNotificationName:JOVideoPlayerDownloadStopNotification object:self];
            });
            if (completionHandler) {
                completionHandler(NSURLSessionResponseCancel);
            }
            return;
        }
        //如果设备的size不够，直接取消
        if (![[JOVideoPlayerCache sharedInstance] haveFreeSizeToCacheFileWithSize:expected]) {
            JODispatchSyncOnMainThread(^{
                [self cancel];
                [self callCompleteDelegateIfNeedWithError:JOErrorWithDescription(@"No enough size of device to cache the video data")];
                [[NSNotificationCenter defaultCenter] postNotificationName:JOVideoPlayerDownloadStopNotification object:self];
            });
            if (completionHandler) {
                completionHandler(NSURLSessionResponseCancel);
            }
        } else {
            JODispatchSyncOnMainThread(^{
                if(!self.runningTask){
                    if (completionHandler) {
                        completionHandler(NSURLSessionResponseCancel);
                    }
                    return;
                }
                [self.runningTask requestDidReceiveResponse:response];
                if (self.delegate && [self.delegate respondsToSelector:@selector(downloader:didReceiveResponse:)]) {
                    [self.delegate downloader:self didReceiveResponse:response];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:JOVideoPlayerDownloadReceiveResponseNotification object:self];
            });
            if (completionHandler) {
                completionHandler(NSURLSessionResponseAllow);
            }
        }
    } else {
        JODispatchSyncOnMainThread(^{
            [self cancel];
            NSString *errorMsg = [NSString stringWithFormat:@"The statusCode of response is: %ld", (long)((NSHTTPURLResponse *)response).statusCode];
            [self callCompleteDelegateIfNeedWithError:JOErrorWithDescription(errorMsg)];
            [[NSNotificationCenter defaultCenter] postNotificationName:JOVideoPlayerDownloadStopNotification object:self];
        });
        if (completionHandler) {
            completionHandler(NSURLSessionResponseCancel);
        }
    }
    
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    // may runningTask is dealloc in main-thread and this method called in sub-thread.
    if(!self.runningTask){
        [self reset];
        return;
    }
    if (dataTask.taskIdentifier != self.runningTask.dataTask.taskIdentifier) {
        NSLog(@"dataTask不是现在正在运行的这个请求, id 是: %lu", dataTask.taskIdentifier);
        return;
    }
    self.receivedSize += data.length;
    [self.runningTask requestDidReciveData:data storeCompletion:^{
        JODispatchSyncOnMainThread(^{
            if (self.delegate && [self.delegate respondsToSelector:@selector(downloader:didReceiveData:receivedSize:expectedSize:)]) {
                [self.delegate downloader:self
                           didReceiveData:data
                             receivedSize:self.receivedSize
                             expectedSize:self.expectedSize];
            }
        });
    }];
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {
    JODispatchSyncOnMainThread(^{
        NSLog(@"URLSession 完成了一个请求, id 是 %ld, error 是: %@", task.taskIdentifier, error);
        BOOL completeValid = self.runningTask && task.taskIdentifier == self.runningTask.dataTask.taskIdentifier;
        if(!completeValid){
            NSLog(@"URLSession 完成了一个不是正在请求的请求, id 是: %lu", task.taskIdentifier);
            return;
        }
        
        [self.runningTask requestDidCompleteWithError:error];
        if (!error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:JOVideoPlayerDownloadFinishNotification object:self];
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(downloader:didCompleteWithError:)]) {
            [self.delegate downloader:self didCompleteWithError:error];
        }
    });
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
downloadCompletionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))downloadCompletionHandler {
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    __block NSURLCredential *credential = nil;
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if (!(self.runningTask.options & JOVideoDownloaderAllowInvalidSSLCertificates)) {
            disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        }
        else {
            credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            disposition = NSURLSessionAuthChallengeUseCredential;
        }
    }
    else {
        if (challenge.previousFailureCount == 0) {
            if (self.urlCredential) {
                credential = self.urlCredential;
                disposition = NSURLSessionAuthChallengeUseCredential;
            }
            else {
                disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
            }
        }
        else {
            disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
        }
    }
    
    if (downloadCompletionHandler) {
        downloadCompletionHandler(disposition, credential);
    }
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
downloadCompletionHandler:(void (^)(NSCachedURLResponse *cachedResponse))downloadCompletionHandler {
    
    // If this method is called, it means the response wasn't read from cache
    NSCachedURLResponse *cachedResponse = proposedResponse;
    
    if (self.runningTask.request.cachePolicy == NSURLRequestReloadIgnoringLocalCacheData) {
        // Prevents caching of responses
        cachedResponse = nil;
    }
    if (downloadCompletionHandler) {
        downloadCompletionHandler(cachedResponse);
    }
}


@end
