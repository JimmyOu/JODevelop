//
//  JOResourceLoadingLocalTask.m
//  JODevelop
//
//  Created by JimmyOu on 2018/5/15.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "JOResourceLoadingLocalTask.h"
#import <pthread.h>
#import "JOVideoPlayerCacheFile.h"

@interface JOResourceLoadingLocalTask()

@property (nonatomic) pthread_mutex_t plock;

@end

@implementation JOResourceLoadingLocalTask

- (void)dealloc {
    NSLog(@"Local task dealloc");
    pthread_mutex_destroy(&_plock);
}
- (instancetype)initWithLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest requestRange:(NSRange)requestRange cacheFile:(JOVideoPlayerCacheFile *)cacheFile customURL:(NSURL *)customURL cached:(BOOL)cached {
    self = [super initWithLoadingRequest:loadingRequest requestRange:requestRange cacheFile:cacheFile customURL:customURL cached:cached];
    if (self) {
        Init_PThread_Lock(&_plock);
        if(cacheFile.responseHeaders && !loadingRequest.contentInformationRequest.contentType){
            [self fillContentInformation];
        }
    }
    return self;
}
- (void)startOnQueue:(dispatch_queue_t)queue {
    [super startOnQueue:queue];
    dispatch_async(queue, ^{
        [self internalStart];
    });
}
- (void)internalStart {
    if ([self isCancelled]) {
        [self requestDidCompleteWithError:nil];
        return;
    }
    
    NSLog(@"开始响应本地请求");
    int lock = pthread_mutex_trylock(&_plock);
    NSUInteger offset = self.requestRange.location;
    while (offset < NSMaxRange(self.requestRange)) {
        if ([self isCancelled]) {
            break;
        }
        
        @autoreleasepool {
            //从localFile拿到data，子线程,每次只读BufferSize
            NSRange range = NSMakeRange(offset, MIN(NSMaxRange(self.requestRange) - offset, kJOVideoPlayerFileReadBufferSize));
            NSData *data = [self.cacheFile dataWithRange:range];
            //塞回request.这个方法可以重复掉用，相当于append data
            [self.loadingRequest.dataRequest respondWithData:data];
            offset = NSMaxRange(range);
        }
    }
    
    NSLog(@"本地请求完成");
    if (!lock) {
        pthread_mutex_unlock(&_plock);
    }
    [self requestDidCompleteWithError:nil];
    
}
- (void)start {
    NSAssert(![NSThread isMainThread], @"dont use main thread when start a local task");
    [super start];
    [self internalStart];
}
- (void)fillContentInformation {
    int lock = pthread_mutex_trylock(&_plock);
    NSMutableDictionary *responseHeaders = [self.cacheFile.responseHeaders mutableCopy];
    BOOL supportRange = responseHeaders[kJOVideoPlayerContentRangeKey] != nil;
    if (supportRange && JOValidByteRange(self.requestRange)) {
        NSUInteger fileLength = [self.cacheFile fileLength];
        
        NSString *contentRange = [NSString stringWithFormat:@"bytes %tu-%tu/%tu", self.requestRange.location, fileLength, fileLength];
        responseHeaders[kJOVideoPlayerContentRangeKey] = contentRange;
    }
    else {
        [responseHeaders removeObjectForKey:kJOVideoPlayerContentRangeKey];
    }
    NSUInteger contentLength = self.requestRange.length != NSUIntegerMax ? self.requestRange.length : self.cacheFile.fileLength - self.requestRange.location;
    responseHeaders[@"Content-Length"] = [NSString stringWithFormat:@"%tu", contentLength];
    NSInteger statusCode = supportRange ? 206 : 200;
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:self.loadingRequest.request.URL
                                                              statusCode:statusCode
                                                             HTTPVersion:@"HTTP/1.1"
                                                            headerFields:responseHeaders];
    [self.loadingRequest jo_fillContentInformationWithResponse:response];
    if (!lock) {
        pthread_mutex_unlock(&_plock);
    }
}
@end
