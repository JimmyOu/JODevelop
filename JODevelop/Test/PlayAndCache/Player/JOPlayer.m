//
//  JOPlayer.m
//  边下边播Demo
//
//  Created by JimmyOu on 2018/5/8.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "JOPlayer.h"
#import "VideoControlView.h"
#import "HUDHelper.h"
#import "JOVideoPlayerResourceLoader.h"
#import "JOVideoPlayerDownloader.h"
#import "JOVideoPlayerCache.h"
@interface JOPlayer() <JOVideoPlayerResourceLoaderDelegate>
@property (nonatomic) JOPlayerState state;
@property (nonatomic) CGFloat       loadedProgress;   //缓冲进度
@property (nonatomic) CGFloat       duration;         //视频总时间
@property (nonatomic) CGFloat       current;          //当前播放时间
@property (nonatomic) CGFloat       progress;         //播放进度 0~1
@property (nonatomic) BOOL           isLocalVideo; //是否播放本地文件
@property (nonatomic) BOOL           isFinishLoad; //是否下载完毕
@property (weak, nonatomic) UIView *showView;
@property (weak, nonatomic)  VideoControlView *controlV;

@property (strong, nonatomic) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem   *currentPlayerItem;
@property (nonatomic, strong) NSObject       *playbackTimeObserver;
@property (strong, nonatomic) JOVideoPlayerResourceLoader *joResourceLoader;
@property (strong, nonatomic) JOVideoPlayerDownloader *playerDownloader;
@property (strong, nonatomic) AVAsset *videoAsset;
@property (strong, nonatomic) AVURLAsset *videoURLAsset;
@property (nonatomic, strong) AVPlayerLayer  *currentPlayerLayer;


@property (strong, nonatomic) AVAssetDownloadURLSession *downloadUrlSession;
@property (strong, nonatomic) AVAssetDownloadTask *task;

@end
@implementation JOPlayer

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static JOPlayer *instance ;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        _isPauseByUser = YES;
        _loadedProgress = 0;
        _duration = 0;
        _current  = 0;
        _state = JOPlayerStateStopped;
        _stopWhenAppDidEnterBackground = YES;
    }
    return self;
}
- (void)dealloc
{
    [self clearPlayer];
}

- (void)clearPlayer {
    if (!self.currentPlayerItem) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.currentPlayerItem removeObserver:self forKeyPath:@"status"];
    [self.currentPlayerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.currentPlayerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.currentPlayerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [self.player removeTimeObserver:self.playbackTimeObserver];
    self.playbackTimeObserver = nil;
    self.currentPlayerItem = nil;
}

- (void)playWithUrl:(NSURL *)url showView:(UIView *)showView {
    [self.player pause];
    [self clearPlayer];
    self.isPauseByUser = NO;
    self.loadedProgress = 0;
    self.duration = 0;
    self.current  = 0;
    
    _showView = showView;
    
    NSString *str = [url absoluteString];
    //如果是是本地资源，直接播放
    if (![str hasPrefix:@"http"]) {
        self.videoAsset  = [AVURLAsset URLAssetWithURL:url options:nil];
        self.currentPlayerItem          = [AVPlayerItem playerItemWithAsset:_videoAsset];
        if (!self.player) {
            self.player = [AVPlayer playerWithPlayerItem:self.currentPlayerItem];
        } else {
            [self.player replaceCurrentItemWithPlayerItem:self.currentPlayerItem];
        }
        
        _isLocalVideo = YES;
        [self playUrl:url];
    } else {
        JOVideoPlayerCache *cacheFile = [JOVideoPlayerCache sharedInstance];
        [cacheFile queryCacheOperationForKey:[url absoluteString]
                                  completion:^(NSString * _Nullable videoPath, JOVideoPlayerCacheType cacheType) {
                                      if (!videoPath) { //远程使用loader进行代理
                                          self.joResourceLoader = [JOVideoPlayerResourceLoader resourceLoaderWithCustomURL:url];
                                          self.joResourceLoader.delegate = self;
                                          self.videoURLAsset = [AVURLAsset URLAssetWithURL:[self handleVideoURL:url] options:nil];
                                          [self.videoURLAsset.resourceLoader setDelegate:self.joResourceLoader queue:dispatch_get_main_queue()];
                                          
                                          self.currentPlayerItem          = [AVPlayerItem playerItemWithAsset:self.videoURLAsset];
                                          
                                          if (!self.player) {
                                              self.player = [AVPlayer playerWithPlayerItem:self.currentPlayerItem];
                                          } else {
                                              [self.player replaceCurrentItemWithPlayerItem:self.currentPlayerItem];
                                          }
                                          self.isLocalVideo = NO;
                                          [self playUrl:url];
                                      } else if (cacheType == JOVideoPlayerCacheTypeFull) { //已经缓存完毕用localFile
                                          self.videoAsset  = [AVURLAsset URLAssetWithURL:url options:nil];
                                          self.currentPlayerItem          = [AVPlayerItem playerItemWithAsset:self.videoAsset];
                                          if (!self.player) {
                                              self.player = [AVPlayer playerWithPlayerItem:self.currentPlayerItem];
                                          } else {
                                              [self.player replaceCurrentItemWithPlayerItem:self.currentPlayerItem];
                                          }
                                          
                                          self.isLocalVideo = YES;
                                          [self playUrl:url];
                                      } else if (cacheType == JOVideoPlayerCacheTypeFragment) { //本地缓存了一部分用loader进行代理
                                          self.joResourceLoader = [JOVideoPlayerResourceLoader resourceLoaderWithCustomURL:url];
                                          self.joResourceLoader.delegate = self;
                                          self.videoURLAsset = [AVURLAsset URLAssetWithURL:[self handleVideoURL:url] options:nil];
                                          [self.videoURLAsset.resourceLoader setDelegate:self.joResourceLoader queue:dispatch_get_main_queue()];
                                          
                                          self.currentPlayerItem          = [AVPlayerItem playerItemWithAsset:self.videoURLAsset];
                                          
                                          if (!self.player) {
                                              self.player = [AVPlayer playerWithPlayerItem:self.currentPlayerItem];
                                          } else {
                                              [self.player replaceCurrentItemWithPlayerItem:self.currentPlayerItem];
                                          }
                                          self.isLocalVideo = YES;
                                          [self playUrl:url];
                                      }
        }];
        
    }
}
- (void)playUrl:(NSURL *)url {
    if (!_currentPlayerLayer) {
        self.currentPlayerLayer       = [AVPlayerLayer playerLayerWithPlayer:self.player];
        self.currentPlayerLayer.frame = CGRectMake(0, 44, _showView.bounds.size.width, _showView.bounds.size.height-44);
        [_showView.layer addSublayer:self.currentPlayerLayer];
    }
    [self registerKVO];
    [self registerNotifications];
    
    // 本地文件不设置Buffering状态
    if ([url.scheme isEqualToString:@"file"]) {
        self.state = JOPlayerStatePlaying;
    } else {
        self.state = JOPlayerStateBuffering;
    }
    
    if (!_controlV) {
        [_showView setNeedsLayout];
        [_showView layoutIfNeeded];
        VideoControlView *controlV = [[VideoControlView alloc] initWithFrame:_showView.frame];
        [_showView addSubview:controlV];
        controlV.player = self;
        _controlV = controlV;
    }
    [[HUDHelper sharedInstance] showHudOnView:_showView caption:nil image:nil acitivity:YES autoHideTime:0];
    
}
- (void)registerKVO {
    [self.currentPlayerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.currentPlayerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [self.currentPlayerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [self.currentPlayerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    
}
- (void)registerNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterPlayGround) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.currentPlayerItem];
}

#pragma mark - public
- (void)fullScreen
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kJOPlayerFullScreenNotification object:nil];
    self.currentPlayerLayer.transform = CATransform3DMakeRotation(M_PI/2, 0, 0, 1);
    self.currentPlayerLayer.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
}

- (void)halfScreen
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kJOPlayerHalfScreenNotification object:nil];
    self.currentPlayerLayer.transform = CATransform3DIdentity;
    self.currentPlayerLayer.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
}

- (void)seekToTime:(CGFloat)seconds
{
    if (self.state == JOPlayerStateStopped) {
        return;
    }
    
    seconds = MAX(0, seconds);
    seconds = MIN(seconds, self.duration);
    
    [self.player pause];
    [self.player seekToTime:CMTimeMakeWithSeconds(seconds, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
        self.isPauseByUser = NO;
        [self.player play];
        if (!self.currentPlayerItem.isPlaybackLikelyToKeepUp) {
            self.state = JOPlayerStateBuffering;
            [[HUDHelper sharedInstance] showHudOnView:self.showView caption:nil image:nil acitivity:YES autoHideTime:0];
        }
        
    }];
}

- (void)resume
{
    if (!self.currentPlayerItem) {
        return;
    }

    [self.controlV setStopButtonPause:NO];
    self.isPauseByUser = NO;
    [self.player play];
}

- (void)pause
{
    if (!self.currentPlayerItem) {
        return;
    }
    [self.controlV setStopButtonPause:YES];
    self.isPauseByUser = YES;
    self.state = JOPlayerStatePause;
    [self.player pause];
}

- (void)stop
{
    self.isPauseByUser = YES;
    self.loadedProgress = 0;
    self.duration = 0;
    self.current  = 0;
    self.state = JOPlayerStateStopped;
    [self.player pause];
    [self clearPlayer];
}

#pragma mark - observer
- (void)appDidEnterBackground
{
    if (self.stopWhenAppDidEnterBackground) {
        [self pause];
        self.state = JOPlayerStatePause;
        self.isPauseByUser = NO;
    }
}
- (void)appDidEnterPlayGround
{
    if (!self.isPauseByUser) {
        [self resume];
        self.state = JOPlayerStatePlaying;
    }
}

- (void)playerItemDidPlayToEnd:(NSNotification *)notification
{
    [self stop];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    
    if ([keyPath isEqualToString:@"status"]) {
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {
            [self monitoringPlayback:playerItem];// 给播放器添加计时器
            
        } else if ([playerItem status] == AVPlayerStatusFailed || [playerItem status] == AVPlayerStatusUnknown) {
            [self stop];
            [HUDHelper showMessage:@"播放失败"];
        }
        
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {  //监听播放器的下载进度
        
        [self calculateDownloadProgress:playerItem];
        
    } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) { //监听播放器在缓冲数据的状态
        [[HUDHelper sharedInstance] showHudOnView:_showView caption:nil image:nil acitivity:YES autoHideTime:0];
        if (playerItem.isPlaybackBufferEmpty) {
            self.state = JOPlayerStateBuffering;
            [self bufferingSomeSecond];
        }
    }
}

- (void)monitoringPlayback:(AVPlayerItem *)playerItem
{
    
    
    self.duration = playerItem.duration.value / playerItem.duration.timescale; //视频总时间
    [self.player play];
    [self.controlV updateTotolTime:self.duration];
    [self.controlV setPlaySliderValue:self.duration];
    
    __weak __typeof(self)weakSelf = self;
    self.playbackTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        CGFloat current = playerItem.currentTime.value/playerItem.currentTime.timescale;
        [strongSelf.controlV updateCurrentTime:current];
        [strongSelf.controlV updateVideoSlider:current];
        if (strongSelf.isPauseByUser == NO) {
            strongSelf.state = JOPlayerStatePlaying;
        }
        
        if (strongSelf.current != current) {
            strongSelf.current = current;
            if (strongSelf.current > strongSelf.duration) {
                strongSelf.current = strongSelf.duration;
            }
        }
        
    }];
    
}

- (void)calculateDownloadProgress:(AVPlayerItem *)playerItem
{
    NSArray *loadedTimeRanges = [playerItem loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval timeInterval = startSeconds + durationSeconds;// 计算缓冲总进度
    CMTime duration = playerItem.duration;
    CGFloat totalDuration = CMTimeGetSeconds(duration);
    self.loadedProgress = timeInterval / totalDuration;
    [self.controlV.videoProgressView setProgress:timeInterval / totalDuration animated:YES];
}

- (void)bufferingSomeSecond
{
    // playbackBufferEmpty会反复进入，因此在bufferingOneSecond延时播放执行完之前再调用bufferingSomeSecond都忽略
    static BOOL isBuffering = NO;
    if (isBuffering) {
        return;
    }
    isBuffering = YES;
    
    // 需要先暂停一小会之后再播放，否则网络状况不好的时候时间在走，声音播放不出来
    [self.player pause];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // 如果此时用户已经暂停了，则不再需要开启播放了
        if (self.isPauseByUser) {
            isBuffering = NO;
            return;
        }
        
        [self.player play];
        // 如果执行了play还是没有播放则说明还没有缓存好，则再次缓存一段时间
        isBuffering = NO;
        if (!self.currentPlayerItem.isPlaybackLikelyToKeepUp) {
            [self bufferingSomeSecond];
        }
    });
}

- (void)setState:(JOPlayerState)state
{
    if (state != JOPlayerStateBuffering) {
        [[HUDHelper sharedInstance] hideHud];
    }
    
    if (_state == state) {
        return;
    }
    
    _state = state;
}

//#pragma mark - JOVideoResourceLoaderDelegate
//- (void)didFinishLoadingWithTask:(JOVideoRequestTask *)task
//{
//    _isFinishLoad = task.isFinishLoad;
//}
//
////网络中断：-1005
////无网络连接：-1009
////请求超时：-1001
////服务器内部错误：-1004
////找不到服务器：-1003
//- (void)didFailLoadingWithTask:(JOVideoRequestTask *)task WithError:(NSInteger)errorCode
//{
//    NSString *str = nil;
//    if (errorCode == -999) {
//        return;
//    }
//    switch (errorCode) {
//        case -1001:
//            str = @"请求超时";
//            break;
//        case -1003:
//        case -1004:
//            str = @"服务器错误";
//            break;
//        case -1005:
//            str = @"网络中断";
//            break;
//        case -1009:
//            str = @"无网络连接";
//            break;
//
//        default:
//            str = [NSString stringWithFormat:@"%@", @"(_errorCode)"];
//            break;
//    }
//
//    [HUDHelper showMessage:str];
//
//}

- (NSURL *)handleVideoURL:(NSURL *)originalURL {
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:originalURL resolvingAgainstBaseURL:NO];
    components.scheme = @"Test";
    return [components URL];
}



#pragma mark - JOVideoPlayerResourceLoaderDelegate

- (void)resourceLoader:(JOVideoPlayerResourceLoader *)resourceLoader didReceiveLoadingWebTask:(JOResourceLoadingWebTask *)webTask {
    self.playerDownloader = [JOVideoPlayerDownloader sharedDownloader];
    JOVideoDownloaderOptions option = JOVideoDownloaderIgnoreCachedResponse | JOVideoDownloaderContinueInBackground | JOVideoDownloaderHandleCookies | JOVideoDownloaderAllowInvalidSSLCertificates;
    [self.playerDownloader downloadVideoWithRequestTask:webTask
                                       downloadOptions:option];
}




@end
