//
//  UIView+JOWebVideoPlayer.h
//  JODevelop
//
//  Created by JimmyOu on 2018/6/14.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JOVideoPlayerProtocol.h"
#import "JOVideoPlayerView.h"
#import "JOPlayerManager.h"

@protocol JOWebVideoPlayerDelegate<NSObject>
- (BOOL)shouldAutoReplayForURL:(NSURL *)url;
- (BOOL)shouldAutoHideControlContainerViewWhenUserTaping;
- (BOOL)shouldPausePlayWhenApplicationDidEnterBackground;
- (BOOL)shouldResumePlayWhenApplicationDidEnterForeground;
- (BOOL)shouldPausePlayWhenReciveAudiosessionInterruptionNotification;
- (NSString *)prefferAudioSessionCategory;
- (void)playerStatusDidChanged:(JOVideoPlayerStatus)playerStatus;
- (void)playVideoFailWithError:(NSError *)error videoURL:(NSURL *)videoURL;
- (NSString *)preferAudioSessionCategory; // default  AVAudioSessionCategoryPlayback
/*是否开启边下边播, default yes*/
- (BOOL)shouldDownloadUrlWhenPlaying:(NSURL *)url;
@end
@interface UIView (JOWebVideoPlayer)<JOPlayerManagerDelegate>

@property (weak, nonatomic) id<JOWebVideoPlayerDelegate> jo_videoPlayerDelegate;
@property (readonly, nonatomic) JOVideoPlayViewInterfaceOrientation jo_InterfaceOrientation;
@property (readonly, nonatomic) JOVideoPlayerStatus jo_videoPlayerStatus;
@property (readonly, nonatomic) JOVideoPlayerView *jo_videoPlayerView;
@property (readonly, nonatomic, copy) NSURL *jo_videoURL;
//progressV
@property (strong, nonatomic, nullable) UIView<JOVideoPlayerProtocol> *jo_progressView;
//controlV
@property (strong, nonatomic, nullable) UIView<JOVideoPlayerProtocol> *jo_controlView;
//bufferV
@property (strong, nonatomic, nullable) UIView<JOVideoPlayerBufferingProtocol> *jo_buffuringView;
//是否用内置的进度条,deafault yes
@property (assign, nonatomic) BOOL useStandardProgressView;
//是否用内置的控制条,deafault yes
@property (assign, nonatomic) BOOL useStandardControlView;
//是否用内置的加载控件,deafault yes
@property (assign, nonatomic) BOOL useStandardBuffuringView;


#pragma mark - Play API

/**
 播放音视频
 */
- (void)jo_playVideoWithURL:(NSURL *)url;
/**
 播放视频
 @param url url
 @param configurationCompletion callback
 */
- (void)jo_playVideoWithURL:(NSURL *)url
    configurationCompletion:(JOPlayVideoConfigurationCompletion _Nullable)configurationCompletion;
/**
 播放视频
 @param url url
 @param options 播放模式
 @param configurationCompletion callback
 */
- (void)jo_playVideoWithURL:(NSURL *)url
                 options:(JOVideoPlayerOptions)options
 configurationCompletion:(JOPlayVideoConfigurationCompletion _Nullable)configurationCompletion;




#pragma mark - Control API

/**
 * The current playback rate.
 */
@property (nonatomic) float jo_rate;

/**
 * A Boolean value that indicates whether the audio output of the player is muted.
 */
@property (nonatomic) BOOL jo_muted;

/**
 * The audio playback volume for the player, ranging from 0.0 through 1.0 on a linear scale.
 */
@property (nonatomic) float jo_volume;

/**
 * Moves the playback cursor.
 *
 * @param time The time where seek to.
 */
- (void)jo_seekToTime:(CMTime)time;

/**
 * Fetch the elapsed seconds of player.
 */
- (NSTimeInterval)jo_elapsedSeconds;

/**
 * Fetch the total seconds of player.
 */
- (NSTimeInterval)jo_totalSeconds;

/**
 *  Call this method to pause playback.
 */
- (void)jo_pause;

/**
 *  Call this method to resume playback.
 */
- (void)jo_resume;

/**
 * @return Returns the current time of the current player item.
 */
- (CMTime)jo_currentTime;

/**
 * Call this method to stop play video.
 */
- (void)jo_stopPlay;

#pragma mark - Landscape Or Portrait Control

/**
 * Call this method to enter full screen.
 */
- (void)jo_gotoLandscape;
- (void)jo_gotoLandscapeWithCompletionHandler:(dispatch_block_t)completion;

/**
 * Call this method to exit full screen.
 */
- (void)jo_gotoPortrait;
- (void)jo_gotoPortraitWithCompletionHandler:(dispatch_block_t)completion;

@end
