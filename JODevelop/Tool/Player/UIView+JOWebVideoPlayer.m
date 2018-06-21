//
//  UIView+JOWebVideoPlayer.m
//  JODevelop
//
//  Created by JimmyOu on 2018/6/14.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "UIView+JOWebVideoPlayer.h"
#import <objc/runtime.h>
#import "JOVideoPlayerCompat.h"
#import "JOPlayerManager.h"
#import "JOVideoPlayer.h"
#import "JOVideoControlView.h"
#import "JOVideoProgressView.h"
#import "JOVideoBufferingIndicator.h"
@interface JOVideoPlayerHelper: NSObject
@property (strong, nonatomic) JOVideoPlayerView *videoPlayerView;
@property (strong, nonatomic) UIView<JOVideoPlayerProtocol> *progressView;
@property (strong, nonatomic) UIView<JOVideoPlayerProtocol> *controlView;
@property (strong, nonatomic) UIView<JOVideoPlayerBufferingProtocol> *buffuringView;
@property (weak, nonatomic) id<JOVideoPlayerDelegate> videoPlayerDelegate;
@property (assign, nonatomic) JOVideoPlayViewInterfaceOrientation interfaceOrientation;
@property (assign, nonatomic) JOVideoPlayerStatus playerStatus;
@property (nonatomic, weak) UIView *playVideoView;
@property (nonatomic, copy) NSURL *videoURL;
//是否用内置的进度条
@property (assign, nonatomic) BOOL useStandardProgressView;
//是否用内置的控制条
@property (assign, nonatomic) BOOL useStandardControlView;
//是否用内置的加载控件
@property (assign, nonatomic) BOOL useStandardBuffuringView;

@end

@implementation JOVideoPlayerHelper
- (instancetype)initWithPlayVideoView:(UIView *)playVideoView {
    self = [super init];
    if(self){
        _playVideoView = playVideoView;
        _useStandardProgressView = YES;
        _useStandardControlView = YES;
        _useStandardBuffuringView = YES;
    }
    return self;
}
- (JOVideoPlayViewInterfaceOrientation)interfaceOrientation {
    if (_interfaceOrientation == JOVideoPlayViewInterfaceOrientationUnknown) {
        CGSize referenceSize = self.playVideoView.window.bounds.size;
        _interfaceOrientation = referenceSize.width < referenceSize.height ? JOVideoPlayViewInterfaceOrientationPortrait : JOVideoPlayViewInterfaceOrientationLandscape;
    }
    return _interfaceOrientation;
}
- (JOVideoPlayerView *)videoPlayerView {
    if (!_videoPlayerView) {
        BOOL autoHide = YES;
        if (_playVideoView.jo_videoPlayerDelegate && [_playVideoView.jo_videoPlayerDelegate respondsToSelector:@selector(shouldAutoHideControlContainerViewWhenUserTaping)] ) {
            autoHide = [_playVideoView.jo_videoPlayerDelegate shouldAutoHideControlContainerViewWhenUserTaping];
        }
        _videoPlayerView = [[JOVideoPlayerView alloc] initWithNeedAutoHideControlViewWhenUserTapping:autoHide];
    }
    return _videoPlayerView;
}

@end

@interface UIView ()

@property (readonly, nonatomic) JOVideoPlayerHelper *helper;

@end

@implementation UIView (JOWebVideoPlayer)

#pragma mark - Play API

- (void)jo_playVideoWithURL:(NSURL *)url {
    [self jo_playVideoWithURL:url configurationCompletion:nil];
}
- (void)jo_playVideoWithURL:(NSURL *)url configurationCompletion:(JOPlayVideoConfigurationCompletion)configurationCompletion {
    [self jo_playVideoWithURL:url
                   options:JOVideoPlayerContinueInBackground |
     JOVideoPlayerLayerVideoGravityResizeAspect | JOVideoPlayerRetryFailed
   configurationCompletion:configurationCompletion];
}


- (void)jo_playVideoWithURL:(NSURL *)url
                 options:(JOVideoPlayerOptions)options
 configurationCompletion:(JOPlayVideoConfigurationCompletion _Nullable)configurationCompletion {
    JOMainThreadAssert;
    
    [self jo_configureUI];
    
    [self jo_stopPlay];
    self.jo_videoURL = url;
    
    if (!url) {
        JODispatchSyncOnMainThread(^{
            if (self.jo_videoPlayerDelegate && [self.jo_videoPlayerDelegate respondsToSelector:@selector(playVideoFailWithError:videoURL:)]) {
                [self.jo_videoPlayerDelegate playVideoFailWithError:JOErrorWithDescription(@"invalid url") videoURL:url];
            }
        });
        return;
    }
    //stop buffer animation
    [self callFinishBufferingDelegate];
    [JOPlayerManager sharedInstance].delegate = self;
    self.helper.videoPlayerView.hidden = NO;
    //1. add bufferingView
    if (self.jo_buffuringView && !self.jo_buffuringView.superview) {
//        self.jo_buffuringView.frame = self.bounds;
        [self.helper.videoPlayerView.bufferingIndicatorContainerView addSubview:self.jo_buffuringView];
        [self.jo_buffuringView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.jo_buffuringView.superview);
        }];
    }
    if (self.jo_buffuringView) {
        [self callStartBufferingDelegate];
    }
    
    //2. add progressView
    if (self.jo_progressView && !self.jo_progressView.superview) {
        if(self.jo_progressView && [self.jo_progressView respondsToSelector:@selector(viewWillAddToPlayerView:)]){
            [self.jo_progressView viewWillAddToPlayerView:self];
        }
        [self.helper.videoPlayerView.progressContainerView addSubview:self.jo_progressView];
        [self.jo_progressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.jo_progressView.superview);
        }];
    }
    
    //3. add controlView
    if (self.jo_controlView && !self.jo_controlView.superview) {
        if(self.jo_controlView && [self.jo_controlView respondsToSelector:@selector(viewWillAddToPlayerView:)]){
            [self.jo_controlView viewWillAddToPlayerView:self];
        }
        [self.helper.videoPlayerView.controlContainerView addSubview:self.jo_controlView];
        [self.jo_controlView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.jo_controlView.superview);
        }];
    }
    if (!self.helper.videoPlayerView.superview) {
        [self addSubview:self.helper.videoPlayerView];

    }
    self.helper.videoPlayerView.frame = self.bounds;
    [self.helper.videoPlayerView layoutIfNeeded];
    self.helper.videoPlayerView.backgroundColor = [UIColor clearColor];
    
    [[JOPlayerManager sharedInstance] playVideoWithURL:url
                                           showOnLayer:self.helper.videoPlayerView.videoContainerLayer
                                               options:options
                               configurationCompletion:^(UIView * _Nonnull view, JOPlayerModel * _Nonnull playerModel) {
                                   if (configurationCompletion) {
                                       configurationCompletion(view,playerModel);
                                   }
    }];
    
}
- (void)jo_configureUI {
    UIView *progressView = self.jo_progressView;
    UIView *controlView = self.jo_controlView;
    UIView *bufferingView = self.jo_buffuringView;
    

    if (self.useStandardBuffuringView && !progressView) {
        self.jo_progressView = [[JOVideoProgressView alloc] init];
    }
    if (self.useStandardControlView && !controlView) {
        self.jo_controlView = [[JOVideoControlView alloc] initWithControlBar:nil blurImage:nil];
    }
    if (self.useStandardBuffuringView && !bufferingView) {
        self.jo_buffuringView = [[JOVideoBufferingIndicator alloc] init];
    }
}

#pragma mark - Control API
- (void)setJo_rate:(float)jo_rate {
    [JOPlayerManager sharedInstance].rate = jo_rate;
}
- (float)jo_rate {
    return [JOPlayerManager sharedInstance].rate;
}

- (void)setJo_muted:(BOOL)jo_muted {
    [JOPlayerManager sharedInstance].muted = jo_muted;
}
- (BOOL)jo_muted {
    return [JOPlayerManager sharedInstance].muted;
}
- (void)setJo_volume:(float)jo_volume {
    [JOPlayerManager sharedInstance].volume = jo_volume;
}
- (float)jo_volume {
    return [JOPlayerManager sharedInstance].volume;
}

- (void)jo_seekToTime:(CMTime)time {
    [[JOPlayerManager sharedInstance] seekToTime:time];
}

- (NSTimeInterval)jo_elapsedSeconds {
    return [JOPlayerManager sharedInstance].elapsedSeconds;
}


- (NSTimeInterval)jo_totalSeconds {
    return [JOPlayerManager sharedInstance].totalSeconds;
}

- (void)jo_pause {
     [[JOPlayerManager sharedInstance] pause];
}


- (void)jo_resume {
    [[JOPlayerManager sharedInstance] resume];
}


- (CMTime)jo_currentTime {
    return [JOPlayerManager sharedInstance].currentTime;
}


- (void)jo_stopPlay {
    [[JOPlayerManager sharedInstance] stop];
    self.helper.videoPlayerView.hidden = YES;
    self.helper.videoPlayerView.backgroundColor = [UIColor clearColor];
    [self callFinishBufferingDelegate];
    
}

#pragma mark - Landscape Or Portrait Control

- (void)jo_gotoLandscape {
    [self jo_gotoLandscapeWithCompletionHandler:nil];
}
- (void)jo_gotoLandscapeWithCompletionHandler:(dispatch_block_t)completion {
    // 这里用view放到window上，比较简单
    if (self.jo_InterfaceOrientation != JOVideoPlayViewInterfaceOrientationPortrait) {
        return;
    }
    self.jo_InterfaceOrientation = JOVideoPlayViewInterfaceOrientationLandscape;
    JOVideoPlayerView *playerView = self.helper.videoPlayerView;
    playerView.backgroundColor = [UIColor blackColor];
    CGRect frameInWindow = [self convertRect:playerView.frame toView:nil];
    [playerView removeFromSuperview];
    [[UIApplication sharedApplication].keyWindow addSubview:playerView];
    playerView.frame = frameInWindow;
    playerView.controlContainerView.alpha = 0;
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self excuteLanscape];
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
        [UIView animateWithDuration:0.5 animations:^{
            playerView.controlContainerView.alpha = 1;
        }];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        // hide status bar.
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
#pragma clang diagnostic pop
    }];
    [self refreshStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
    [self callOrientationDelegateWithInterfaceOrientation:JOVideoPlayViewInterfaceOrientationLandscape];
}

- (void)jo_gotoPortrait {
    [self jo_gotoPortraitWithCompletionHandler:nil];
}
- (void)jo_gotoPortraitWithCompletionHandler:(dispatch_block_t)completion {
    if (self.jo_InterfaceOrientation != JOVideoPlayViewInterfaceOrientationLandscape) {
        return;
    }
    
    self.helper.interfaceOrientation = JOVideoPlayViewInterfaceOrientationPortrait;
    JOVideoPlayerView *videoPlayerView = self.helper.videoPlayerView;
    videoPlayerView.backgroundColor = [UIColor blackColor];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    // display status bar.
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
#pragma clang diagnostic pop
    videoPlayerView.controlContainerView.alpha = 0;
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self excutePortrait];
                     }
                     completion:^(BOOL finished) {
                         [self finishPortrait];
                         if (completion) {
                             completion();
                         }
                     }];
    [self refreshStatusBarOrientation:UIInterfaceOrientationPortrait];
    [self callOrientationDelegateWithInterfaceOrientation:JOVideoPlayViewInterfaceOrientationPortrait];
}

#pragma mark - private

- (void)excuteLanscape {
    UIView *videoPlayerView = self.helper.videoPlayerView;
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGRect bounds = CGRectMake(0, 0, CGRectGetHeight(screenBounds), CGRectGetWidth(screenBounds));
    CGPoint center = CGPointMake(CGRectGetMidX(screenBounds), CGRectGetMidY(screenBounds));
    videoPlayerView.bounds = bounds;
    videoPlayerView.center = center;
    videoPlayerView.transform = CGAffineTransformMakeRotation(M_PI_2);
    [[JOPlayerManager sharedInstance] videoPlayer].playerModel.playerLayer.frame = bounds;
}
- (void)excutePortrait {
    UIView *videoPlayerView = self.helper.videoPlayerView;
    CGRect frame = [self.superview convertRect:self.frame toView:nil];
    videoPlayerView.transform = CGAffineTransformIdentity;
    videoPlayerView.frame = frame;
    [[JOPlayerManager sharedInstance] videoPlayer].playerModel.playerLayer.frame = self.bounds;
}

- (void)finishPortrait {
    JOVideoPlayerView *videoPlayerView = self.helper.videoPlayerView;
    [videoPlayerView removeFromSuperview];
    [self addSubview:videoPlayerView];
    videoPlayerView.frame = self.bounds;
    [[JOPlayerManager sharedInstance] videoPlayer].playerModel.playerLayer.frame = self.bounds;
    [UIView animateWithDuration:0.5 animations:^{
        videoPlayerView.controlContainerView.alpha = 1;
    }];
}

- (void)refreshStatusBarOrientation:(UIInterfaceOrientation)interfaceOrientation {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[UIApplication sharedApplication] setStatusBarOrientation:interfaceOrientation animated:YES];
#pragma clang diagnostic pop
}

- (void)callOrientationDelegateWithInterfaceOrientation:(JOVideoPlayViewInterfaceOrientation)interfaceOrientation {
    if(self.jo_controlView && [self.jo_controlView respondsToSelector:@selector(videoPlayerInterfaceOrientationDidChange:videoURL:)]){
        [self.jo_controlView videoPlayerInterfaceOrientationDidChange:interfaceOrientation videoURL:self.jo_videoURL];
    }
    if(self.jo_progressView && [self.jo_progressView respondsToSelector:@selector(videoPlayerInterfaceOrientationDidChange:videoURL:)]){
        [self.jo_progressView videoPlayerInterfaceOrientationDidChange:interfaceOrientation videoURL:self.jo_videoURL];
    }
}

- (void)callStartBufferingDelegate {
    if(self.helper.buffuringView && [self.helper.buffuringView respondsToSelector:@selector(didStartBufferingVideoURL:)]){
        [self.helper.buffuringView didStartBufferingVideoURL:self.jo_videoURL];
    }
}

- (void)callFinishBufferingDelegate {
    if(self.helper.buffuringView && [self.helper.buffuringView respondsToSelector:@selector(didFinishBufferingVideoURL:)]){
        [self.helper.buffuringView didFinishBufferingVideoURL:self.jo_videoURL];
    }
}

#pragma mark - JOPlayerManagerDelegate
- (BOOL)videoPlayerManager:(JOPlayerManager *)videoPlayerManager
    shouldAutoReplayForURL:(NSURL *)videoURL {
    if (self.jo_videoPlayerDelegate && [self.jo_videoPlayerDelegate respondsToSelector:@selector(shouldAutoReplayForURL:)]) {
        return [self.jo_videoPlayerDelegate shouldAutoReplayForURL:videoURL];
    }
    return YES;
}

- (void)videoPlayerManager:(JOPlayerManager *)videoPlayerManager
    playerStatusDidChanged:(JOVideoPlayerStatus)playerStatus {
    if (playerStatus == JOVideoPlayerStatusPlaying) {
        self.helper.videoPlayerView.backgroundColor = [UIColor blackColor];
    }
    self.helper.playerStatus = playerStatus;
    if (self.jo_videoPlayerDelegate && [self.jo_videoPlayerDelegate respondsToSelector:@selector(playerStatusDidChanged:)]) {
        return [self.jo_videoPlayerDelegate playerStatusDidChanged:playerStatus];
    }
    
    BOOL needDisplayBufferingIndicator = (playerStatus == JOVideoPlayerStatusBuffering)|| (playerStatus == JOVideoPlayerStatusUnknown) || (playerStatus == JOVideoPlayerStatusFailed);
    needDisplayBufferingIndicator ? [self callStartBufferingDelegate] : [self callFinishBufferingDelegate];
    if(self.jo_controlView && [self.jo_controlView respondsToSelector:@selector(videoplayerStatusDidChange:videoURL:)]){
        [self.jo_controlView videoplayerStatusDidChange:playerStatus videoURL:self.jo_videoURL];
    }
    if(self.jo_progressView && [self.jo_progressView respondsToSelector:@selector(videoplayerStatusDidChange:videoURL:)]){
        [self.jo_progressView videoplayerStatusDidChange:playerStatus videoURL:self.jo_videoURL];
    }
}

- (void)videoPlayerManager:(JOPlayerManager *)videoPlayerManager
   didFetchVideoFileLength:(NSUInteger)videoLength {
    if(self.helper.controlView && [self.helper.controlView respondsToSelector:@selector(didFetchVideoFileLength:videoURL:)]){
        [self.helper.controlView didFetchVideoFileLength:videoLength videoURL:self.jo_videoURL];
    }
    if(self.helper.progressView && [self.helper.progressView respondsToSelector:@selector(didFetchVideoFileLength:videoURL:)]){
        [self.helper.progressView didFetchVideoFileLength:videoLength videoURL:self.jo_videoURL];
    }
}

- (void)videoPlayerManagerDownloadProgressDidChange:(JOPlayerManager *)videoPlayerManager
                                          cacheType:(JOVideoPlayerCacheType)cacheType
                                     fragmentRanges:(NSArray<NSValue *> * _Nullable)fragmentRanges
                                       expectedSize:(NSUInteger)expectedSize
                                              error:(NSError *_Nullable)error {
    if(error){
        if (self.jo_videoPlayerDelegate && [self.jo_videoPlayerDelegate respondsToSelector:@selector(playVideoFailWithError:videoURL:)]) {
            [self.jo_videoPlayerDelegate playVideoFailWithError:JOErrorWithDescription(@"Try to play video with a invalid url")
                                                       videoURL:videoPlayerManager.managerModel.videoURL];
        }
        return;
    }
    switch(cacheType){
        case JOVideoPlayerCacheTypeLocation:
        case JOVideoPlayerCacheTypeFull:
            NSParameterAssert(fragmentRanges);
            NSRange range = [fragmentRanges.firstObject rangeValue];
            NSParameterAssert(range.length == expectedSize);
            break;
            
        default:
            break;
    }
    if(self.helper.controlView && [self.helper.controlView respondsToSelector:@selector(cacheRangeDidChange:videoURL:)]){
        [self.helper.controlView cacheRangeDidChange:fragmentRanges videoURL:self.jo_videoURL];
    }
    if(self.helper.progressView && [self.helper.progressView respondsToSelector:@selector(cacheRangeDidChange:videoURL:)]){
        [self.helper.progressView cacheRangeDidChange:fragmentRanges videoURL:self.jo_videoURL];
    }
}

- (void)videoPlayerManagerPlayProgressDidChange:(JOPlayerManager *)videoPlayerManager
                                 elapsedSeconds:(double)elapsedSeconds
                                   totalSeconds:(double)totalSeconds
                                          error:(NSError *_Nullable)error {
    if(error){
        if (self.jo_videoPlayerDelegate && [self.jo_videoPlayerDelegate respondsToSelector:@selector(playVideoFailWithError:videoURL:)]) {
            [self.jo_videoPlayerDelegate playVideoFailWithError:JOErrorWithDescription(@"Try to play video with a invalid url")
                                                       videoURL:videoPlayerManager.managerModel.videoURL];
        }
        return;
    }
    if(self.helper.controlView && [self.helper.controlView respondsToSelector:@selector(playProgressDidChangeElapsedSeconds:totalSeconds:videoURL:)]){
        [self.helper.controlView playProgressDidChangeElapsedSeconds:elapsedSeconds
                                                        totalSeconds:totalSeconds
                                                            videoURL:self.jo_videoURL];
    }
    if(self.helper.progressView && [self.helper.progressView respondsToSelector:@selector(playProgressDidChangeElapsedSeconds:totalSeconds:videoURL:)]){
        [self.helper.progressView playProgressDidChangeElapsedSeconds:elapsedSeconds
                                                         totalSeconds:totalSeconds
                                                             videoURL:self.jo_videoURL];
    }
}

- (BOOL)videoPlayerManager:(JOPlayerManager *)videoPlayerManager
shouldPausePlaybackWhenApplicationDidEnterBackgroundForURL:(NSURL *)videoURL {
    if (self.jo_videoPlayerDelegate && [self.jo_videoPlayerDelegate respondsToSelector:@selector(shouldPausePlayWhenApplicationDidEnterBackground)]) {
        return [self.jo_videoPlayerDelegate shouldPausePlayWhenApplicationDidEnterBackground];
    }
    return YES;
}

- (BOOL)videoPlayerManager:(JOPlayerManager *)videoPlayerManager
shouldResumePlaybackWhenApplicationDidEnterForegroundForURL:(NSURL *)videoURL {
    if (self.jo_videoPlayerDelegate && [self.jo_videoPlayerDelegate respondsToSelector:@selector(shouldResumePlayWhenApplicationDidEnterForeground)]) {
        return [self.jo_videoPlayerDelegate shouldResumePlayWhenApplicationDidEnterForeground];
    }
    return YES;
}

- (BOOL)videoPlayerManager:(JOPlayerManager *)videoPlayerManager
shouldPausePlaybackWhenReceiveAudioSessionInterruptionNotificationForURL:(NSURL *)videoURL {
    if (self.jo_videoPlayerDelegate && [self.jo_videoPlayerDelegate respondsToSelector:@selector(shouldPausePlayWhenReciveAudiosessionInterruptionNotification)]) {
        return [self.jo_videoPlayerDelegate shouldPausePlayWhenReciveAudiosessionInterruptionNotification];
    }
    return YES;
}
- (NSString *)videoPlayerManagerPreferAudioSessionCategory:(JOPlayerManager *)videoPlayerManager {
    if (self.jo_videoPlayerDelegate && [self.jo_videoPlayerDelegate respondsToSelector:@selector(preferAudioSessionCategory)]) {
        return [self.jo_videoPlayerDelegate preferAudioSessionCategory];
    }
    return AVAudioSessionCategoryPlayback;
}
- (BOOL)videoPlayerManager:(JOPlayerManager *)videoPlayerManager shouldDownloadUrlWhenPlaying:(NSURL *)url {
    if (self.jo_videoPlayerDelegate && [self.jo_videoPlayerDelegate respondsToSelector:@selector(shouldDownloadUrlWhenPlaying:)]) {
        return [self.jo_videoPlayerDelegate shouldDownloadUrlWhenPlaying:url];
    }
    return YES;
}
#pragma mark -  getter && setter
- (JOVideoPlayViewInterfaceOrientation)jo_InterfaceOrientation {
    return self.helper.interfaceOrientation;
}
- (void)setJo_InterfaceOrientation:(JOVideoPlayViewInterfaceOrientation)jo_InterfaceOrientation {
    self.helper.interfaceOrientation = jo_InterfaceOrientation;
}
- (JOVideoPlayerStatus)jo_videoPlayerStatus {
    return self.helper.playerStatus;
}
- (JOVideoPlayerView *)jo_videoPlayerView {
    return self.helper.videoPlayerView;
}
- (void)setJo_videoPlayerDelegate:(id<JOVideoPlayerDelegate>)jo_videoPlayerDelegate {
    self.helper.videoPlayerDelegate = jo_videoPlayerDelegate;
}
- (id<JOVideoPlayerDelegate>)jo_videoPlayerDelegate {
    return self.helper.videoPlayerDelegate;
}
- (NSURL *)jo_videoURL {
    return self.helper.videoURL;
}
- (void)setJo_videoURL:(NSURL *)jo_videoURL {
     self.helper.videoURL = jo_videoURL;
}
- (void)setJo_progressView:(UIView<JOVideoPlayerProtocol> *)jo_progressView {
    self.helper.progressView = jo_progressView;
}
- (UIView<JOVideoPlayerProtocol> *)jo_progressView {
    return self.helper.progressView;
}
- (void)setJo_controlView:(UIView<JOVideoPlayerProtocol> *)jo_controlView {
    self.helper.controlView = jo_controlView;
}
- (UIView<JOVideoPlayerProtocol> *)jo_controlView {
    return self.helper.controlView;
}
- (void)setJo_buffuringView:(UIView<JOVideoPlayerBufferingProtocol> *)jo_buffuringView {
    self.helper.buffuringView = jo_buffuringView;
}
- (UIView<JOVideoPlayerBufferingProtocol> *)jo_buffuringView {
    return self.helper.buffuringView;
}
- (void)setUseStandardControlView:(BOOL)useStandardControlView {
    self.helper.useStandardControlView = useStandardControlView;
}
- (BOOL)useStandardControlView {
    return self.helper.useStandardControlView;
}
- (BOOL)useStandardProgressView {
    return self.helper.useStandardProgressView;
}
- (void)setUseStandardProgressView:(BOOL)useStandardProgressView {
    self.helper.useStandardProgressView = useStandardProgressView;
}
- (BOOL)useStandardBuffuringView {
    return self.helper.useStandardBuffuringView;
}
- (void)setUseStandardBuffuringView:(BOOL)useStandardBuffuringView {
    self.helper.useStandardBuffuringView = useStandardBuffuringView;
}

- (JOVideoPlayerHelper *)helper {
    JOVideoPlayerHelper *helper = objc_getAssociatedObject(self, _cmd);
    if (!helper) {
        helper = [[JOVideoPlayerHelper alloc] initWithPlayVideoView:self];
        objc_setAssociatedObject(self, _cmd, helper, OBJC_ASSOCIATION_RETAIN);
    }
    return helper;
}

@end
