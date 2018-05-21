//
//  JOVideoPlayerResourceLoader.m
//  JODevelop
//
//  Created by JimmyOu on 2018/5/15.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "JOVideoPlayerResourceLoader.h"
#import "JOVideoPlayerCacheFile.h"
#import "JOResourceLoadingWebTask.h"
#import "JOResourceLoadingLocalTask.h"
#import <pthread/pthread.h>
#import "JOVideoPlayerCompat.h"
#import "JOVideoPlayerCachePath.h"

@interface JOVideoPlayerResourceLoader()<JOVideoLoadingRequestTaskDelegate>

@property (strong, nonatomic) NSMutableArray<AVAssetResourceLoadingRequest *> *loadingRequests;

@property (strong, nonatomic) AVAssetResourceLoadingRequest *runningLoadingRequest;

@property (strong, nonatomic) JOVideoPlayerCacheFile *cacheFile;

@property (strong, nonatomic) NSMutableArray<JOVideoLoadingRequestTask *> *requestTasks;

@property (strong, nonatomic) JOVideoLoadingRequestTask *runningRequestTask;

@property (nonatomic) pthread_mutex_t lock;

@property (nonatomic, strong, nonnull) dispatch_queue_t ioQueue;
@end

@implementation JOVideoPlayerResourceLoader

- (void)dealloc {
    if (self.runningRequestTask) {
        [self.runningRequestTask cancel];
        [self removeCurrentRequestTaskAndResetAll];
    }
    self.loadingRequests = nil;
    pthread_mutex_destroy(&_lock);
}



+ (instancetype)resourceLoaderWithCustomURL:(NSURL *)customURL {
    return [[JOVideoPlayerResourceLoader alloc] initWithCustomURL:customURL];
}

- (instancetype)initWithCustomURL:(NSURL *)customURL {
    NSParameterAssert(customURL);
    if(!customURL){
        return nil;
    }
    
    self = [super init];
    if(self){
        Init_PThread_Lock(&_lock);
        _ioQueue = dispatch_queue_create("com.jo.resourceLoader.www", DISPATCH_QUEUE_SERIAL);
        _customURL = customURL;
        _loadingRequests = [@[] mutableCopy];
        NSString *key = customURL.absoluteString;
        _cacheFile = [JOVideoPlayerCacheFile cacheFileWithFilePath:[JOVideoPlayerCachePath createVideoFileIfNeededForKey:key]
                                                     indexFilePath:[JOVideoPlayerCachePath createVideoIndexFileIfNeededForKey:key]];
        
    }
    return self;
}
#pragma mark - AVAssetResourceLoaderDelegate
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    if (resourceLoader && loadingRequest) {
        //得到avfoundation请求放到queue里
        [self.loadingRequests addObject:loadingRequest];
        NSLog(@"ResourceLoader 接收到新的请求, 当前请求数: %ld <<<<<<<<<<<<<<", self.loadingRequests.count);
        if (!self.runningRequestTask) { //如果当前没有正在运行的请求，直接进到下一个请求
            [self findAndStartNextLoadingRequestIfNeed];
        }
    }
    return YES;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    if ([self.loadingRequests containsObject:loadingRequest]) {
        if (loadingRequest == self.runningLoadingRequest) {
            NSLog(@"取消了一个正在进行的请求");
            if (self.runningLoadingRequest && self.runningRequestTask) {
                [self.runningRequestTask cancel];
            }
            if ([self.loadingRequests containsObject:self.runningLoadingRequest]) {
                [self.loadingRequests removeObject:self.runningLoadingRequest];
            }
            [self removeCurrentRequestTaskAndResetAll];
            [self findAndStartNextLoadingRequestIfNeed];
        }
        else {
            NSLog(@"取消了一个不在进行的请求");
            [self.loadingRequests removeObject:loadingRequest];
        }
    }
    else {
        NSLog(@"要取消的请求已经完成了");
    }
}

#pragma mark - JOVideoLoadingRequestTaskDelegate
- (void)requestTask:(JOVideoLoadingRequestTask *)requestTask didCompleteWithError:(NSError *)error {
    if (error.code == NSURLErrorCancelled) {
        return;
    }
    if (![self.requestTasks containsObject:requestTask]) {
        NSLog(@"完成的 task 不是正在进行的 task");
        return;
    }
    
    if (error) {
        [self finishCurrentRequestWithError:error];
    }
    else {
        [self finishCurrentRequestWithError:nil];
    }
}
#pragma mark - Finish Request
- (void)finishCurrentRequestWithError:(NSError *)error {
    if (error) {
        NSLog(@"ResourceLoader 完成一个请求 error: %@", error);
        [self.runningRequestTask.loadingRequest finishLoadingWithError:error];
        [self.loadingRequests removeObject:self.runningLoadingRequest];
        [self removeCurrentRequestTaskAndResetAll];
        [self findAndStartNextLoadingRequestIfNeed];
    }
    else {
        NSLog(@"ResourceLoader 完成一个请求, 没有错误");
        // 要所有的请求都完成了才行.
        [self.requestTasks removeObject:self.runningRequestTask];
        if(!self.requestTasks.count){ // 全部完成.
            [self.runningRequestTask.loadingRequest finishLoading];
            [self.loadingRequests removeObject:self.runningLoadingRequest];
            [self removeCurrentRequestTaskAndResetAll];
            [self findAndStartNextLoadingRequestIfNeed];
        }
        else { // 完成了一部分, 继续请求.
            [self startNextTaskIfNeed];
        }
    }
}


#pragma mark - Private
- (void)findAndStartNextLoadingRequestIfNeed {
    if (self.runningLoadingRequest || self.runningRequestTask) {
        return;
    }
    if (self.loadingRequests.count == 0) {
        return;
    }
    
    self.runningLoadingRequest = [self.loadingRequests firstObject];
    NSRange dataRange = [self fetchRequestRangeWithRequest:self.runningLoadingRequest];
    if (dataRange.length == NSUIntegerMax) {
        dataRange.length = [self.cacheFile fileLength] - dataRange.location;
    }
    [self startCurrentRequestWithLoadingRequest:self.runningLoadingRequest range:dataRange];
    
}
/*
 把loadingRequest分成 webTask或者localTask
 */
- (void)startCurrentRequestWithLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest
                                        range:(NSRange)dataRange {
    NSLog(@"ResourceLoader 处理新的请求, 数据范围是: %@", NSStringFromRange(dataRange));
    if (dataRange.length == NSUIntegerMax) {
        [self addTaskWithLoadingRequest:loadingRequest
                                  range:NSMakeRange(dataRange.location, NSUIntegerMax)
                                 cached:NO];
    }
    else {
        NSUInteger start = dataRange.location;
        NSUInteger end = NSMaxRange(dataRange);
        //用while 循环因为可能有多个cached片段，我们只发起没有cached的视频片段才需要被发起webTask
        while (start < end) {
            NSRange firstNotCachedRange = [self.cacheFile firstNotCachedRangeFromPosition:start];
            if (!JOValidByteRange(firstNotCachedRange)) {
                [self addTaskWithLoadingRequest:loadingRequest
                                          range:dataRange
                                         cached:self.cacheFile.cachedDataBound > 0];
                start = end;
            }
            else if (firstNotCachedRange.location >= end) {
                [self addTaskWithLoadingRequest:loadingRequest
                                          range:dataRange
                                         cached:YES];
                start = end;
            }
            else if (firstNotCachedRange.location >= start) {
                if (firstNotCachedRange.location > start) {
                    [self addTaskWithLoadingRequest:loadingRequest
                                              range:NSMakeRange(start, firstNotCachedRange.location - start)
                                             cached:YES];
                }
                NSUInteger notCachedEnd = MIN(NSMaxRange(firstNotCachedRange), end);
                [self addTaskWithLoadingRequest:loadingRequest
                                          range:NSMakeRange(firstNotCachedRange.location, notCachedEnd - firstNotCachedRange.location)
                                         cached:NO];
                start = notCachedEnd;
            }
            else {
                [self addTaskWithLoadingRequest:loadingRequest
                                          range:dataRange
                                         cached:YES];
                start = end;
            }
            
        }
    }
    // 发起请求.
    [self startNextTaskIfNeed];
}


- (void)addTaskWithLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest
                            range:(NSRange)range
                           cached:(BOOL)cached {
    JOVideoLoadingRequestTask *task;
    if(cached){
        NSLog(@"ResourceLoader 创建了一个本地请求");
        task = [JOResourceLoadingLocalTask requestTaskWithLoadingRequest:loadingRequest
                                                                   requestRange:range
                                                                      cacheFile:self.cacheFile
                                                                      customURL:self.customURL
                                                                         cached:cached];
    }
    else {
        task = [JOResourceLoadingWebTask requestTaskWithLoadingRequest:loadingRequest
                                                                 requestRange:range
                                                                    cacheFile:self.cacheFile
                                                                    customURL:self.customURL
                                                                       cached:cached];
        NSLog(@"ResourceLoader 创建一个网络请求: %@", task);
        if (self.delegate && [self.delegate respondsToSelector:@selector(resourceLoader:didReceiveLoadingWebTask:)]) {
            [self.delegate resourceLoader:self didReceiveLoadingWebTask:(JOResourceLoadingWebTask *)task];
        }
    }
    int lock = pthread_mutex_trylock(&_lock);
    task.delegate = self;
    if (!self.requestTasks) {
        self.requestTasks = [@[] mutableCopy];
    }
    [self.requestTasks addObject:task];
    if (!lock) {
        pthread_mutex_unlock(&_lock);
    }
}
- (void)removeCurrentRequestTaskAndResetAll {
    self.runningLoadingRequest = nil;
    self.requestTasks = [NSMutableArray array];
    self.runningRequestTask = nil;
}
- (NSRange)fetchRequestRangeWithRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    NSUInteger location, length;
    // data range.
    if ([loadingRequest.dataRequest respondsToSelector:@selector(requestsAllDataToEndOfResource)] && loadingRequest.dataRequest.requestsAllDataToEndOfResource) {
        location = (NSUInteger)loadingRequest.dataRequest.requestedOffset;
        length = NSUIntegerMax;
    }
    else {
        location = (NSUInteger)loadingRequest.dataRequest.requestedOffset;
        length = loadingRequest.dataRequest.requestedLength;
    }
    if(loadingRequest.dataRequest.currentOffset > 0){
        location = (NSUInteger)loadingRequest.dataRequest.currentOffset;
    }
    return NSMakeRange(location, length);
}
- (void)startNextTaskIfNeed {
    int lock = pthread_mutex_trylock(&_lock);;
    self.runningRequestTask = self.requestTasks.firstObject;
    if ([self.runningRequestTask isKindOfClass:[JOResourceLoadingLocalTask class]]) {
        [self.runningRequestTask startOnQueue:self.ioQueue];
    }
    else {
        [self.runningRequestTask start];
    }
    if (!lock) {
        pthread_mutex_unlock(&_lock);
    }
}


@end
