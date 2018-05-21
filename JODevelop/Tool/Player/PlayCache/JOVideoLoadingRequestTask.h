//
//  JOVideoLoadingRequestTask.h
//  JODevelop
//
//  Created by JimmyOu on 2018/5/15.
//  Copyright © 2018年 JimmyOu. All rights reserved.
// 抽象类，主要用其子类

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "JOVideoPlayerCompat.h"

extern NSUInteger kJOVideoPlayerFileReadBufferSize;
extern NSString *kJOVideoPlayerContentRangeKey;

@class JOVideoLoadingRequestTask, JOVideoPlayerCacheFile;
@protocol JOVideoLoadingRequestTaskDelegate<NSObject>
@optional
- (void)requestTask:(JOVideoLoadingRequestTask *)requestTask didReceiveResponse:(NSURLResponse *)response;

- (void)requestTask:(JOVideoLoadingRequestTask *)requestTask didReceiveData:(NSData *)data;
- (void)requestTask:(JOVideoLoadingRequestTask *)requestTask didCompleteWithError:(NSError *)error;
@end

@interface JOVideoLoadingRequestTask : NSObject

@property (weak, nonatomic) id<JOVideoLoadingRequestTaskDelegate> delegate;

@property (readonly) AVAssetResourceLoadingRequest *loadingRequest;

@property (readonly) NSRange requestRange;

@property (readonly) JOVideoPlayerCacheFile *cacheFile;

@property (readonly) NSURL *customURL;

/**
 表明requestRange的文件是否完全在localFile
 */
@property (readonly, getter=isCached) BOOL cached;

@property (readonly, getter=isExcuting) BOOL excuting;
@property (readonly, getter=isFinished) BOOL finished;
@property (readonly, getter=isCancelled) BOOL cancelled;

+ (instancetype)requestTaskWithLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest
                                 requestRange:(NSRange)requestRange
                                    cacheFile:(JOVideoPlayerCacheFile *)cacheFile
                                    customURL:(NSURL *)customURL
                                       cached:(BOOL)cached;
- (instancetype)initWithLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest
                          requestRange:(NSRange)requestRange
                             cacheFile:(JOVideoPlayerCacheFile *)cacheFile
                             customURL:(NSURL *)customURL
                                cached:(BOOL)cached;

- (void)requestDidReceiveResponse:(NSURLResponse *)response;

- (void)requestDidReciveData:(NSData *)data storeCompletion:(dispatch_block_t)completion;

- (void)requestDidCompleteWithError:(NSError *_Nullable)error NS_REQUIRES_SUPER;

- (void)start NS_REQUIRES_SUPER;

- (void)startOnQueue:(dispatch_queue_t)queue NS_REQUIRES_SUPER;

- (void)cancel NS_REQUIRES_SUPER;

@end
