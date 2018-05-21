//
//  JOVideoPlayerDownloader.h
//  JODevelop
//
//  Created by JimmyOu on 2018/5/15.
//  Copyright © 2018年 JimmyOu. All rights reserved.
// 一个downloader对应一个url

#import <Foundation/Foundation.h>
#import "JOVideoPlayerCompat.h"
#import "JOResourceLoadingWebTask.h"

@class JOVideoPlayerDownloader;
@protocol JOVideoPlayerDownloaderDelegate<NSObject>

@optional

- (void)downloader:(JOVideoPlayerDownloader *)downloader
didReceiveResponse:(NSURLResponse *)response;

- (void)downloader:(JOVideoPlayerDownloader *)downloader
    didReceiveData:(NSData *)data
      receivedSize:(NSUInteger)receivedSize
      expectedSize:(NSUInteger)expectedSize;

- (void)downloader:(JOVideoPlayerDownloader *)downloader
didCompleteWithError:(NSError *)error;

@end

@interface JOVideoPlayerDownloader : NSObject

@property (strong, nonatomic, nullable) NSURLCredential *urlCredential; //default

@property (strong, nonatomic, nullable) NSString *username; //认证用
@property (strong, nonatomic, nullable) NSString *password;//认证用
@property (assign, nonatomic) NSTimeInterval downloadTimeout; //超时 default 15s
@property (weak, nonatomic, nullable, readonly)  JOResourceLoadingWebTask *runningTask;// current running webTask
@property (assign, nonatomic, readonly) JOVideoDownloaderOptions downloaderOptions;
@property (weak, nonatomic) id<JOVideoPlayerDownloaderDelegate> delegate;


+ (nonnull instancetype)sharedDownloader;

- (nonnull instancetype)initWithSessionConfiguration:(nullable NSURLSessionConfiguration *)sessionConfiguration NS_DESIGNATED_INITIALIZER;

- (void)downloadVideoWithRequestTask:(JOResourceLoadingWebTask *)requestTask
                     downloadOptions:(JOVideoDownloaderOptions)downloadOptions;

- (void)cancel;

@end
