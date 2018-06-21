//
//  JOVideoPlayerProtocol.h
//  JODevelop
//
//  Created by JimmyOu on 2018/6/12.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "JOVideoPlayerCompat.h"

#ifndef JOVideoPlayerProtocol_h
#define JOVideoPlayerProtocol_h


#pragma mark - playProtocol
@protocol JOVideoPlayerProtocol<NSObject>
@optional

- (void)viewWillAddToPlayerView:(UIView *)playerView;
/**
 called when the downloader fetched the file length or read from disk.
 */
- (void)didFetchVideoFileLength:(NSInteger)videoLenth videoURL:(NSURL *)videoURL;
/*
 called when recived new video data from web
 */
- (void)cacheRangeDidChange:(NSArray<NSValue *> *)cacheRanges videoURL:(NSURL *)videoURL;

/**
 called when play progress changed

 @param elapsedSecounds elapsed time
 @param totalSeconds total time
 @param videoURL video url
 */
- (void)playProgressDidChangeElapsedSeconds:(NSTimeInterval)elapsedSecounds totalSeconds:(NSTimeInterval)totalSeconds videoURL:(NSURL *)videoURL;

/**
 called when play status changed
 */
- (void)videoplayerStatusDidChange:(JOVideoPlayerStatus)playerStatus videoURL:(NSURL *)videoURL;
/**
 called when play orientation did changed
 */
- (void)videoPlayerInterfaceOrientationDidChange:(JOVideoPlayViewInterfaceOrientation)interfaceOrientation videoURL:(NSURL *)videoURL;

@end

@protocol JOVideoPlayerBufferingProtocol

@optional

- (void)didStartBufferingVideoURL:(NSURL *)videoURL;

- (void)didFinishBufferingVideoURL:(NSURL *)videoURL;

@end

@protocol JOVideoPlayerControlProgressProtocol<JOVideoPlayerProtocol>

@property(nonatomic) BOOL userDragging;

@property(nonatomic) NSTimeInterval userDragTimeInterval;

@end


@protocol JOVideoPlayerPlayProtocol<NSObject>
@required

/**
 播放速度
 */
@property (assign, nonatomic) CGFloat rate;

/**
  是否静音
 */
@property (assign, nonatomic) BOOL muted;
/**
 音量， ranging from 0.0 through 1.0
 */
@property (assign, nonatomic) CGFloat volume;

/**
 拖动到某一时刻
 */
- (void)seekToTime:(CMTime)time;

/**
 播放的时间
 */
- (NSTimeInterval)elapsedSeconds;
/**
 资源的总时长
 */
- (NSTimeInterval)totalSeconds;
- (CMTime)currentTime;

- (void)play;
- (void)pause;
- (void)resume;
- (void)stop;

@end



#endif /* JOVideoPlayerProtocol_h */
