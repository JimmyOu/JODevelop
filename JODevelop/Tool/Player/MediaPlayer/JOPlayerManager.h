//
//  JOPlayerManager.h
//  JODevelop
//
//  Created by JimmyOu on 2018/6/14.
//  Copyright © 2018年 JimmyOu. All rights reserved.
// 控制播放模块

#import <Foundation/Foundation.h>
#import "JOVideoPlayerDownloader.h"
#import "JOVideoPlayerCache.h"
#import "JOVideoPlayerProtocol.h"
#import "JOVideoPlayer.h"

@class JOPlayerManager;
@protocol JOPlayerManagerDelegate<NSObject>

- (BOOL)videoPlayerManager:(JOPlayerManager *)videoPlayerManager
    shouldAutoReplayForURL:(NSURL *)videoURL;

- (void)videoPlayerManager:(JOPlayerManager *)videoPlayerManager
    playerStatusDidChanged:(JOVideoPlayerStatus)playerStatus;

- (void)videoPlayerManager:(JOPlayerManager *)videoPlayerManager
   didFetchVideoFileLength:(NSUInteger)videoLength;

- (void)videoPlayerManagerDownloadProgressDidChange:(JOPlayerManager *)videoPlayerManager
                                          cacheType:(JOVideoPlayerCacheType)cacheType
                                     fragmentRanges:(NSArray<NSValue *> * _Nullable)fragmentRanges
                                       expectedSize:(NSUInteger)expectedSize
                                              error:(NSError *_Nullable)error;

- (void)videoPlayerManagerPlayProgressDidChange:(JOPlayerManager *)videoPlayerManager
                                 elapsedSeconds:(double)elapsedSeconds
                                   totalSeconds:(double)totalSeconds
                                          error:(NSError *_Nullable)error;

- (BOOL)videoPlayerManager:(JOPlayerManager *)videoPlayerManager
shouldPausePlaybackWhenApplicationDidEnterBackgroundForURL:(NSURL *)videoURL;

- (BOOL)videoPlayerManager:(JOPlayerManager *)videoPlayerManager
shouldResumePlaybackWhenApplicationDidEnterForegroundForURL:(NSURL *)videoURL;

- (BOOL)videoPlayerManager:(JOPlayerManager *)videoPlayerManager
shouldPausePlaybackWhenReceiveAudioSessionInterruptionNotificationForURL:(NSURL *)videoURL;

- (NSString *)videoPlayerManagerPreferAudioSessionCategory:(JOPlayerManager *)videoPlayerManager;

/*是否开启边下边播*/
- (BOOL)videoPlayerManager:(JOPlayerManager *)videoPlayerManager shouldDownloadUrlWhenPlaying:(NSURL *)url;


@end
//存储播放信息
@interface JOPlayerManagerModel : NSObject

@property (nonatomic, strong, readonly) NSURL *videoURL;

@property (nonatomic, assign) JOVideoPlayerCacheType cacheType;

@property (nonatomic, assign) NSUInteger fileLength;

/**
 * The fragment of video data that cached in disk.
 */
@property (nonatomic, strong, readonly, nullable) NSArray<NSValue *> *fragmentRanges;

@end

@interface JOPlayerManager : NSObject<JOVideoPlayerPlayProtocol>
@property (weak, nonatomic) id<JOPlayerManagerDelegate> delegate;
@property (readonly) JOVideoPlayerCache *videoCache;
@property (readonly) JOVideoPlayerDownloader *videoDownloader;
@property (readonly) JOPlayerManagerModel *managerModel;
@property (readonly) JOVideoPlayer *videoPlayer;

+ (instancetype)sharedInstance;

- (nonnull instancetype)initWithCache:(nonnull JOVideoPlayerCache *)cache
                           downloader:(nonnull JOVideoPlayerDownloader *)downloader NS_DESIGNATED_INITIALIZER;

# pragma mark - Play Video
- (void)playVideoWithURL:(NSURL *)url
             showOnLayer:(CALayer *)layer
                 options:(JOVideoPlayerOptions)options
 configurationCompletion:(JOPlayVideoConfigurationCompletion)configurationCompletion;


@end
