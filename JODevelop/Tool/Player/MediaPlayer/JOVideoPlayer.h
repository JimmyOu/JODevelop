//
//  JOVideoPlayer.h
//  JODevelop
//
//  Created by JimmyOu on 2018/6/12.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JOVideoPlayerProtocol.h"
#import "JOVideoPlayerResourceLoader.h"
#import "JOVideoPlayerCompat.h"
#import "JOPlayerModel.h"
@class JOVideoPlayer;
@protocol JPVideoPlayerDelegate<NSObject>

/**
 收到一个下载任务
 */
- (void)videoPlayer:(nonnull JOVideoPlayer *)videoPlayer
didReceiveLoadingRequestTask:(JOResourceLoadingWebTask *)requestTask;

/**
 播放器状态改变通知
 */
- (void)videoPlayer:(nonnull JOVideoPlayer *)videoPlayer playerStatusDidChange:(JOVideoPlayerStatus)playerStatus;
/**
 播放器播放失败
 */
- (void)videoPlayer:(nonnull JOVideoPlayer *)videoPlayer playFailedWithError:(NSError *)error;
/**
 播放器播放了多少
 */
- (void)videoPlayerPlayProgressDidChange:(nonnull JOVideoPlayer *)videoPlayer
                          elapsedSeconds:(double)elapsedSeconds
                            totalSeconds:(double)totalSeconds;
/**
 播放器是否需要重复播放
 */
- (BOOL)videoPlayer:(nonnull JOVideoPlayer *)videoPlayer
shouldAutoReplayVideoForURL:(nonnull NSURL *)videoURL;

@end
@interface JOVideoPlayer : NSObject<JOVideoPlayerPlayProtocol>


@property (nonatomic, weak, nullable) id<JPVideoPlayerDelegate> delegate;
/*
 播放信息
 */
@property (nonatomic, strong, readonly, nullable) JOPlayerModel *playerModel;
/*
 播放状态
 */
@property (nonatomic, assign, readonly) JOVideoPlayerStatus playerStatus;

/**
  是否启用边下边播
 */
@property (assign, nonatomic) BOOL enableResourceLoader;


/**
 播放localFile

 @param url url
 @param options play options
 @param showLayer 显示在哪里
 @param completion 初始化完成
 */
- (JOPlayerModel *)playLocalFileWithURL:(NSURL *)url options:(JOVideoPlayerOptions)options showOnLayer:(CALayer *)showLayer completion:(JOPlayVideoConfigurationCompletion)completion;

/**
 播放web url
 
 @param url url
 @param options play options
 @param showLayer 显示在哪里
 @param completion 初始化完成
 */
- (JOPlayerModel *)playWithURL:(NSURL *)url options:(JOVideoPlayerOptions)options showOnLayer:(CALayer *)showLayer completion:(JOPlayVideoConfigurationCompletion)completion;
/**
 resume play
 @param options play options
 @param showLayer 显示在哪里
 @param completion 初始化完成
 */
- (BOOL)resumePlayWithShowLayer:(CALayer *)showLayer
                        options:(JOVideoPlayerOptions)options
        completion:(JOPlayVideoConfigurationCompletion)completion;


@end
