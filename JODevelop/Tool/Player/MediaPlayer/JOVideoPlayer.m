//
//  JOVideoPlayer.m
//  JODevelop
//
//  Created by JimmyOu on 2018/6/12.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "JOVideoPlayer.h"
#import "JOPlayerModel.h"
#import <pthread.h>

@interface JOVideoPlayer()<JOVideoPlayerResourceLoaderDelegate>
/**
 * The current play video item.
 */
@property(nonatomic, strong, nullable)JOPlayerModel *playerModel;

/**
 * The playing status of video player before app enter background.
 */
@property(nonatomic, assign)JOVideoPlayerStatus playerStatus_beforeEnterBackground;


@property(nonatomic) pthread_mutex_t lock;

@property (nonatomic, strong) NSTimer *checkBufferingTimer;

@property(nonatomic, assign) JOVideoPlayerStatus playerStatus;
@end 

@implementation JOVideoPlayer
- (void)dealloc {
    pthread_mutex_destroy(&_lock);
    [self stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _playerStatus = JOVideoPlayerStatusUnknown;
        Init_PThread_Lock(&_lock);
        [self addObserver];
        
    }
    return self;
}
- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidPlayToEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appReceivedMemoryWarning)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
}



#pragma mark - Public
- (BOOL)playLocalFileWithURL:(NSURL *)url options:(JOVideoPlayerOptions)options showOnLayer:(CALayer *)showLayer completion:(JOPlayVideoConfigurationCompletion)completion{
    
    if (url.absoluteString.length == 0) {
        [self callDelegateMethodWithError:JOErrorWithDescription(@"local url is disable")];
        return nil;
    }
    if (!showLayer) {
        [self callDelegateMethodWithError:JOErrorWithDescription(@"The layer to display video layer is nil")];
        return nil;
    }
    if(self.playerModel){
        [self.playerModel reset];
        self.playerModel = nil;
    }
    
    NSURL *videoPathURL = url;
    AVURLAsset *videoURLAsset = [AVURLAsset URLAssetWithURL:videoPathURL options:nil];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:videoURLAsset];
    JOPlayerModel *model = [self playerModelWithURL:videoPathURL
                                              playerItem:playerItem
                                                 options:options
                                             showOnLayer:showLayer];
    if (options & JOVideoPlayerMutedPlay) {
        model.player.muted = YES;
    }
    self.playerModel = model;
    if(completion){
        completion([UIView new], model);
    }
    return model;
}

- (JOPlayerModel *)playWithURL:(NSURL *)url options:(JOVideoPlayerOptions)options showOnLayer:(CALayer *)showLayer completion:(JOPlayVideoConfigurationCompletion)completion {
    if (!url.absoluteString.length) {
        [self callDelegateMethodWithError:JOErrorWithDescription(@"The url is disable")];
        return nil;
    }
    
    if (!showLayer) {
        [self callDelegateMethodWithError:JOErrorWithDescription(@"The layer to display video layer is nil")];
        return nil;
    }
    
    if(self.playerModel){
        [self.playerModel reset];
        self.playerModel = nil;
    }
    
    AVURLAsset *videoURLAsset = nil;
    JOVideoPlayerResourceLoader *resourceLoader = nil;
    if (self.enableResourceLoader) { //如果启用边下边播
        resourceLoader = [JOVideoPlayerResourceLoader resourceLoaderWithCustomURL:url];
        resourceLoader.delegate = self;
        //提供给avplayer一个他不能识别的url才会触发avplayer触发去询问自定义resourceLoader。
        videoURLAsset = [AVURLAsset URLAssetWithURL:[self handleVideoURL:url] options:nil];
        [videoURLAsset.resourceLoader setDelegate:resourceLoader queue:dispatch_get_main_queue()];
    } else {
        videoURLAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    }
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:videoURLAsset];
    JOPlayerModel *model = [self playerModelWithURL:url
                                              playerItem:playerItem
                                                 options:options
                                             showOnLayer:showLayer];
    self.playerModel = model;
    
    model.resourceLoader = resourceLoader;
    if (options & JOVideoPlayerMutedPlay) {
        model.player.muted = YES;
    }
    if(completion){
        completion([UIView new], model);
    }
    return model;
}

- (BOOL)resumePlayWithShowLayer:(CALayer *)showLayer options:(JOVideoPlayerOptions)options completion:(JOPlayVideoConfigurationCompletion)completion {
    if (!showLayer) {
        [self callDelegateMethodWithError:JOErrorWithDescription(@"The layer to display video layer is nil")];
        return NO;
    }
    [self.playerModel.playerLayer removeFromSuperlayer];
    self.playerModel.unownedShowLayer = showLayer;
    
    if (options & JOVideoPlayerMutedPlay) {
        self.playerModel.player.muted = YES;
    }
    else {
        self.playerModel.player.muted = NO;
    }
    [self setVideoGravityWithOptions:options playerModel:self.playerModel];
    [self displayVideoPicturesOnShowLayer];
    
    if(completion){
        completion([UIView new], self.playerModel);
    }
    [self callPlayerStatusDidChangeDelegateMethod];
    return YES;
}

#pragma private
- (JOPlayerModel *)playerModelWithURL:(NSURL *)url
                                playerItem:(AVPlayerItem *)playerItem
                                   options:(JOVideoPlayerOptions)options
                               showOnLayer:(CALayer *)showLayer {
    [self resetAwakeWaitingTimeInterval];
    JOPlayerModel *model = [JOPlayerModel new];
    model.unownedShowLayer = showLayer;
    model.url = url;
    model.playerOptions = options;
    model.playerItem = playerItem;
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    model.player = [AVPlayer playerWithPlayerItem:playerItem];
    [model.player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:nil];
    if ([model.player respondsToSelector:@selector(automaticallyWaitsToMinimizeStalling)]) {
        model.player.automaticallyWaitsToMinimizeStalling = NO;
    }
    model.playerLayer = [AVPlayerLayer playerLayerWithPlayer:model.player];
    [self setVideoGravityWithOptions:options playerModel:model];
    model.videoPlayer = self;
    self.playerStatus = JOVideoPlayerStatusUnknown;
    [self startCheckBufferingTimer];
    
    // add observer for video playing progress.
    __weak typeof(model) wItem = model;
    __weak typeof(self) wself = self;
    [model.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 10.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time){
        __strong typeof(wItem) sItem = wItem;
        __strong typeof(wself) sself = wself;
        if (!sItem || !sself) return;
        
        double elapsedSeconds = CMTimeGetSeconds(time);
        double totalSeconds = CMTimeGetSeconds(sItem.playerItem.duration);
        sself.playerModel.elapsedSeconds = elapsedSeconds;
        sself.playerModel.totalSeconds = totalSeconds;
        if(totalSeconds == 0 || isnan(totalSeconds) || elapsedSeconds > totalSeconds){
            return;
        }
        JODispatchSyncOnMainThread(^{
            if (sself.delegate && [sself.delegate respondsToSelector:@selector(videoPlayerPlayProgressDidChange:elapsedSeconds:totalSeconds:)]) {
                [sself.delegate videoPlayerPlayProgressDidChange:sself
                                                  elapsedSeconds:elapsedSeconds
                                                    totalSeconds:totalSeconds];
            }
        });
        
    }];
    
    return model;
}

#pragma mark Notifications && KVO
- (void)appReceivedMemoryWarning {
    [self.playerModel stop];
}

- (void)playerItemDidPlayToEnd:(NSNotification *)notification {
    AVPlayerItem *playerItem = notification.object;
    if(playerItem != self.playerModel.playerItem){
        return;
    }
    
    self.playerStatus = JOVideoPlayerStatusStop;
    [self callPlayerStatusDidChangeDelegateMethod];
    [self stopCheckBufferingTimerIfNeed];
    
    // ask need automatic replay or not.
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayer:shouldAutoReplayVideoForURL:)]) {
        if (![self.delegate videoPlayer:self shouldAutoReplayVideoForURL:self.playerModel.url]) {
            return;
        }
    }
    [self seekToHeaderThenStartPlayback];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItem *playerItem = (AVPlayerItem *)object;
        AVPlayerItemStatus status = playerItem.status;
        switch (status) {
            case AVPlayerItemStatusUnknown:{
                self.playerStatus = AVPlayerItemStatusUnknown;
                [self callPlayerStatusDidChangeDelegateMethod];
            }
                break;
                
            case AVPlayerItemStatusReadyToPlay:{
                NSLog(@"AVPlayerItemStatusReadyToPlay");
                self.playerStatus = JOVideoPlayerStatusReadyToPlay;
                // When get ready to play note, we can go to play, and can add the video picture on show view.
                if (!self.playerModel) return;
                [self.playerModel.player play];
                [self displayVideoPicturesOnShowLayer];
                [self callPlayerStatusDidChangeDelegateMethod];
            }
                break;
                
            case AVPlayerItemStatusFailed:{
                [self stopCheckBufferingTimerIfNeed];
                self.playerStatus = JOVideoPlayerStatusFailed;
                [self callDelegateMethodWithError:JOErrorWithDescription(@"AVPlayerItemStatusFailed")];
                [self callPlayerStatusDidChangeDelegateMethod];
            }
                break;
                
            default:
                break;
        }
    }
    else if([keyPath isEqualToString:@"rate"]) {
        float rate = [change[NSKeyValueChangeNewKey] floatValue];
        if((rate != 0) && (self.playerStatus == JOVideoPlayerStatusReadyToPlay)){
            self.playerStatus = JOVideoPlayerStatusPlaying;
            [self callPlayerStatusDidChangeDelegateMethod];
        }
    }
}


#pragma mark - JOVideoPlayerPlayProtocol
- (void)setRate:(CGFloat)rate {
    if(!self.playerModel){
        return;
    }
    [self.playerModel setRate:rate];
}

- (CGFloat)rate {
    if(!self.playerModel){
        return 0;
    }
    return self.playerModel.rate;
}

- (void)setMuted:(BOOL)muted {
    if(!self.playerModel){
        return;
    }
    [self.playerModel setMuted:muted];
}

- (BOOL)muted {
    if(!self.playerModel){
        return NO;
    }
    return self.playerModel.muted;
}

- (void)setVolume:(CGFloat)volume {
    if(!self.playerModel){
        return;
    }
    [self.playerModel setVolume:volume];
}

- (CGFloat)volume {
    if(!self.playerModel){
        return 0;
    }
    return self.playerModel.volume;
}

- (void)seekToTime:(CMTime)time {
    if(!self.playerModel){
        return;
    }
    if (self.playerModel.player.status != AVPlayerStatusReadyToPlay) {
        return;
    }
    if(!CMTIME_IS_VALID(time)){
        return;
    }
    BOOL needResume = self.playerModel.player.rate != 0;
    self.playerModel.lastTime = 0;
    [self internalPauseWithNeedCallDelegate:NO];
    __weak typeof(self) wself = self;
    [self.playerModel.player seekToTime:time completionHandler:^(BOOL finished) {
        __strong typeof(wself) sself = wself;
        if(finished && needResume){
            [sself internalResumeWithNeedCallDelegate:NO];
        }
        
    }];
}

- (NSTimeInterval)elapsedSeconds {
    return [self.playerModel elapsedSeconds];
}

- (NSTimeInterval)totalSeconds {
    return [self.playerModel totalSeconds];
}

- (void)pause {
    if(!self.playerModel){
        return;
    }
    [self internalPauseWithNeedCallDelegate:YES];
}

- (void)resume {
    if(!self.playerModel){
        return;
    }
    if(self.playerStatus == JOVideoPlayerStatusStop){
        self.playerStatus = JOVideoPlayerStatusUnknown;
        [self seekToHeaderThenStartPlayback];
        return;
    }
    [self internalResumeWithNeedCallDelegate:YES];
}
- (void)play {
    [self resume];
}

- (CMTime)currentTime {
    if(!self.playerModel){
        return kCMTimeZero;
    }
    return self.playerModel.currentTime;
}

- (void)stop{
    if(!self.playerModel){
        return;
    }
    [self.playerModel stop];
    [self stopCheckBufferingTimerIfNeed];
    [self resetAwakeWaitingTimeInterval];
    self.playerModel = nil;
    self.playerStatus = JOVideoPlayerStatusStop;
    [self callPlayerStatusDidChangeDelegateMethod];
}




#pragma mark - JOVideoPlayerResourceLoaderDelegate
//收到一个requestTask请求
- (void)resourceLoader:(JOVideoPlayerResourceLoader *)resourceLoader didReceiveLoadingWebTask:(JOResourceLoadingWebTask *)webTask {
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayer:didReceiveLoadingRequestTask:)]) {
        [self.delegate videoPlayer:self didReceiveLoadingRequestTask:webTask];
    }
}



- (void)callDelegateMethodWithError:(NSError *)error {
    JODispatchSyncOnMainThread(^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayer:playFailedWithError:)]) {
            [self.delegate videoPlayer:self playFailedWithError:error];
        }
    });
}

- (void)setVideoGravityWithOptions:(JOVideoPlayerOptions)options
                       playerModel:(JOPlayerModel *)playerModel {
    NSString *videoGravity = nil;
    if (options & JOVideoPlayerLayerVideoGravityResizeAspect) {
        videoGravity = AVLayerVideoGravityResizeAspect;
    }
    else if (options & JOVideoPlayerLayerVideoGravityResize){
        videoGravity = AVLayerVideoGravityResize;
    }
    else if (options & JOVideoPlayerLayerVideoGravityResizeAspectFill){
        videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    playerModel.playerLayer.videoGravity = videoGravity;
}


#pragma mark - Timer
- (void)startCheckBufferingTimer {
    if(self.checkBufferingTimer){
        [self stopCheckBufferingTimerIfNeed];
    }
    self.checkBufferingTimer = [NSTimer timerWithTimeInterval:0.5
                                                       target:self
                                                     selector:@selector(checkBufferingTimeDidChange)
                                                     userInfo:nil
                                                      repeats:YES];
    [NSRunLoop.mainRunLoop addTimer:self.checkBufferingTimer forMode:NSRunLoopCommonModes];
}

- (void)stopCheckBufferingTimerIfNeed {
    if(self.checkBufferingTimer){
        [self.checkBufferingTimer invalidate];
        self.checkBufferingTimer = nil;
    }
}

- (void)checkBufferingTimeDidChange {
    NSTimeInterval currentTime = CMTimeGetSeconds(self.playerModel.player.currentTime);
    if (currentTime != 0 && currentTime > (self.playerModel.lastTime + 0.3)) {
        self.playerModel.lastTime = currentTime;
        [self endAwakeFromBuffering];
        if(self.playerStatus == JOVideoPlayerStatusPlaying){
            return;
        }
        self.playerStatus = JOVideoPlayerStatusPlaying;
        [self callPlayerStatusDidChangeDelegateMethod];
    }
    else{
        if(self.playerStatus == JOVideoPlayerStatusBuffering){
            [self startAwakeWhenBuffering];
            return;
        }
        self.playerStatus = JOVideoPlayerStatusBuffering;
        [self callPlayerStatusDidChangeDelegateMethod];
    }
}

#pragma mark - Awake When Buffering
static NSTimeInterval _awakeWaitingTimeInterval = 3;
- (void)resetAwakeWaitingTimeInterval {
    _awakeWaitingTimeInterval = 3;
    NSLog(@"重置了播放唤醒等待时间");
}

- (void)updateAwakeWaitingTimerInterval {
    _awakeWaitingTimeInterval += 2;
    if(_awakeWaitingTimeInterval > 12){
        _awakeWaitingTimeInterval = 12;
    }
}

static BOOL _isOpenAwakeWhenBuffering = NO;
- (void)startAwakeWhenBuffering {
    if(!_isOpenAwakeWhenBuffering){
        _isOpenAwakeWhenBuffering = YES;
        NSLog(@"Start awake when buffering.");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_awakeWaitingTimeInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            if(!_isOpenAwakeWhenBuffering){
                [self endAwakeFromBuffering];
                NSLog(@"Player is playing when call awake buffering block.");
                return;
            }
            NSLog(@"Call resume in awake buffering block.");
            _isOpenAwakeWhenBuffering = NO;
            [self.playerModel pause];
            [self updateAwakeWaitingTimerInterval];
            [self.playerModel resume];
            
        });
    }
}

- (void)endAwakeFromBuffering {
    if(_isOpenAwakeWhenBuffering){
        NSLog(@"End awake buffering.");
        _isOpenAwakeWhenBuffering = NO;
        [self resetAwakeWaitingTimeInterval];
    }
}

#pragma mark - private

- (void)displayVideoPicturesOnShowLayer{
    if (!self.playerModel.isCancelled) {
        self.playerModel.playerLayer.frame = self.playerModel.unownedShowLayer.bounds;
        // use dispatch_after to prevent layer layout animation.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.playerModel.unownedShowLayer addSublayer:self.playerModel.playerLayer];
        });
    }
}

- (NSURL *)handleVideoURL:(NSURL *)url {
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];
    components.scheme = @"jovideoPlayer";
    return [components URL];
}

- (void)seekToHeaderThenStartPlayback {
    // Seek the start point of file data and repeat play, this handle have no memory surge.
    __weak typeof(self.playerModel) weak_Item = self.playerModel;
    [self.playerModel.player seekToTime:CMTimeMake(0, 1) completionHandler:^(BOOL finished) {
        __strong typeof(weak_Item) strong_Item = weak_Item;
        if (!strong_Item) return;
        
        self.playerModel.lastTime = 0;
        [strong_Item.player play];
        [self callPlayerStatusDidChangeDelegateMethod];
        [self startCheckBufferingTimer];
        
    }];
}

- (void)callPlayerStatusDidChangeDelegateMethod {
    JODispatchSyncOnMainThread(^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayer:playerStatusDidChange:)]) {
            [self.delegate videoPlayer:self playerStatusDidChange:self.playerStatus];
        }
    });
}
- (void)internalPauseWithNeedCallDelegate:(BOOL)needCallDelegate {
    [self.playerModel pause];
    [self stopCheckBufferingTimerIfNeed];
    self.playerStatus = JOVideoPlayerStatusPause;
    [self endAwakeFromBuffering];
    if(needCallDelegate){
        [self callPlayerStatusDidChangeDelegateMethod];
    }
}

- (void)internalResumeWithNeedCallDelegate:(BOOL)needCallDelegate {
    [self.playerModel resume];
    [self startCheckBufferingTimer];
    self.playerStatus = JOVideoPlayerStatusPlaying;
    if(needCallDelegate){
        [self callPlayerStatusDidChangeDelegateMethod];
    }
}

@end
