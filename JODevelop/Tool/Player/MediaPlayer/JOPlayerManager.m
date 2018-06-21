//
//  JOPlayerManager.m
//  JODevelop
//
//  Created by JimmyOu on 2018/6/14.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "JOPlayerManager.h"
#import "JOVideoPlayerDownloader.h"
#import <pthread.h>
#import "JOPlayerModel.h"
#import "JOVideoPlayerCacheFile.h"


@interface JOPlayerManagerModel()
@property (nonatomic, strong, nullable) NSArray<NSValue *> *fragmentRanges;
@property (nonatomic, strong) NSURL *videoURL;
@end

@implementation JOPlayerManagerModel
@end

@interface JOPlayerManager()<JOVideoPlayerDownloaderDelegate, JPVideoPlayerDelegate>
@property (strong, nonatomic) JOVideoPlayerCache *videoCache;
@property (strong, nonatomic) JOVideoPlayerDownloader *videoDownloader;
@property (strong, nonatomic) NSMutableSet <NSURL *> *failedURLs;
@property (nonatomic) pthread_mutex_t lock;
@property (strong, nonatomic) JOPlayerManagerModel *managerModel;
@property (strong, nonatomic) JOVideoPlayer *videoPlayer;

@property(nonatomic, assign) BOOL pauseWhenApplicationDidEnterBackground;
@property(nonatomic, assign) BOOL applicationDidEnterBackground;

@end

@implementation JOPlayerManager

#pragma mark - initialze
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static JOPlayerManager *instance ;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (instancetype)init
{
    JOVideoPlayerCache *cache = [JOVideoPlayerCache sharedInstance];
    JOVideoPlayerDownloader *downloader = [JOVideoPlayerDownloader sharedDownloader];
    downloader.delegate = self;
    return [self initWithCache:cache downloader:downloader];
}

- (instancetype)initWithCache:(JOVideoPlayerCache *)cache downloader:(JOVideoPlayerDownloader *)downloader {
    if (self = [super init]) {
        _videoCache = cache;
        _videoDownloader = downloader;
        _failedURLs = [NSMutableSet set];
        Init_PThread_Lock(&_lock);
        
        _videoPlayer = [JOVideoPlayer new];
        _videoPlayer.delegate = self;
        
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(audioSessionInterruptionNotification:)
                                                   name:AVAudioSessionInterruptionNotification
                                                 object:nil];
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
          [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
    }
    return self;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - public

- (void)playVideoWithURL:(NSURL *)url showOnLayer:(CALayer *)showLayer options:(JOVideoPlayerOptions)options configurationCompletion:(JOPlayVideoConfigurationCompletion)configurationCompletion {
    JOMainThreadAssert;
    NSParameterAssert(showLayer);
    if (!url || !showLayer) {
        return;
    }
    [self reset];
    [self activeAudioSessionIfNeed];
    
    if ([url isKindOfClass:[NSString class]]) {
        url = [NSURL URLWithString:(NSString *)url];
    }
    
    if (![url isKindOfClass:[NSURL class]]) {
        url = nil;
    }
    self.managerModel = [JOPlayerManagerModel new];
    self.managerModel.videoURL = url;
    BOOL isFailedUrl = NO;
    if(url) {
        int lock = pthread_mutex_trylock(&_lock);
        isFailedUrl = [self.failedURLs containsObject:url];
        if (!lock) {
            pthread_mutex_unlock(&_lock);
        }
    }
    if (url.absoluteString.length == 0 || (!(options & JOVideoPlayerRetryFailed) && isFailedUrl)) {
        NSError *error = [NSError errorWithDomain:JOVideoPlayerErrorDomain code:NSURLErrorFileDoesNotExist userInfo:@{NSLocalizedDescriptionKey:@"the file of given url not exsits"}];
        [self callDownloadDelegateMethodWithFragmentRanges:nil expectedSize:1 cacheType:JOVideoPlayerCacheTypeNone error:error];
    }
    
    BOOL isFileURL = [url isFileURL];
    if (isFileURL) {
        [self playLocalVideoWithURL:url showOnLayer:showLayer options:options configurationCompletion:configurationCompletion];
    } else {
        
        BOOL enableResourceLoarder = [self.delegate respondsToSelector:@selector(videoPlayerManager:shouldDownloadUrlWhenPlaying:)] && [self.delegate videoPlayerManager:self shouldDownloadUrlWhenPlaying:url];
        self.videoPlayer.enableResourceLoader = enableResourceLoarder;
        
        NSString *key = [self cacheKeyForURL:url];
        [self.videoCache queryCacheOperationForKey:key
                                        completion:^(NSString * _Nullable videoPath, JOVideoPlayerCacheType cacheType) {
                                            if (!showLayer) {
                                                [self reset];
                                                return;
                                            }
                                            if (!videoPath) { //play web video
                                                self.managerModel.cacheType = JOVideoPlayerCacheTypeNone;
                                                
                                                [self.videoPlayer playWithURL:url
                                                                      options:options
                                                                  showOnLayer:showLayer
                                                                   completion:configurationCompletion];
                                            } else if (videoPath) { // videoPath in cache
                                                if (cacheType == JOVideoPlayerCacheTypeFull) { //full videPath
                                                    //播放cache里的完整视频
                                                    self.managerModel.cacheType = JOVideoPlayerCacheTypeFull;
                                                    [self playExistedVideoWithURL:url videoPath:videoPath showOnLayer:showLayer options:options configurationCompletion:configurationCompletion];
                                                    
                                                } else if (cacheType == JOVideoPlayerCacheTypeFragment){ //播放片段
                                                    self.managerModel.cacheType = JOVideoPlayerCacheTypeFragment;
                                                    
                                                    [self playFragmentVideoWithURL:url showOnLayer:showLayer options:options configurationCompletion:configurationCompletion];
                                                    
                                                }
                                                
                                            }
                                            
        }];
    }
    
}

- (void)downloadVideoWithRequestTask:(JOResourceLoadingWebTask *)webTask downloadOptions:(JOVideoDownloaderOptions)options {
    [self.videoDownloader downloadVideoWithRequestTask:webTask
                                       downloadOptions:options];
    
}

#pragma mark - notification

- (void)audioSessionInterruptionNotification:(NSNotification *)note {
    AVPlayer *player = note.object;
    // the player is self player, return.
    if(player == self.videoPlayer.playerModel.player){
        return;
    }
    // self not playing.
    if(!self.videoPlayer.playerModel){
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayerManager:shouldPausePlaybackWhenReceiveAudioSessionInterruptionNotificationForURL:)]) {
        BOOL shouldPause = [self.delegate videoPlayerManager:self
shouldPausePlaybackWhenReceiveAudioSessionInterruptionNotificationForURL:self.managerModel.videoURL];
        if(shouldPause){
            [self pause];
        }
        return;
    }
    [self pause];
}

- (void)appDidBecomeActive:(NSNotification *)notification {
    [self activeAudioSessionIfNeed];
    if (self.applicationDidEnterBackground && self.pauseWhenApplicationDidEnterBackground) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayerManager:shouldResumePlaybackWhenApplicationDidEnterForegroundForURL:)]) {
            BOOL needResume = [self.delegate videoPlayerManager:self
shouldResumePlaybackWhenApplicationDidEnterForegroundForURL:self.managerModel.videoURL];
            if(needResume){
                [self.videoPlayer resume];
                self.pauseWhenApplicationDidEnterBackground = NO;
            }
            return;
        }
    }
    self.applicationDidEnterBackground = NO;
}
- (void)appDidEnterBackground:(NSNotification *)notification {
    BOOL needPause = !(!self.managerModel.videoURL ||
                       self.videoPlayer.playerStatus == JOVideoPlayerStatusStop ||
                       self.videoPlayer.playerStatus == JOVideoPlayerStatusPause ||
                       self.videoPlayer.playerStatus == JOVideoPlayerStatusFailed);
    self.applicationDidEnterBackground = YES;
    
    if (needPause) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayerManager:shouldPausePlaybackWhenApplicationDidEnterBackgroundForURL:)]) {
            BOOL pauseWhenEnterBackground = [self.delegate videoPlayerManager:self shouldPausePlaybackWhenApplicationDidEnterBackgroundForURL:self.managerModel.videoURL];
            if (pauseWhenEnterBackground) {
                [self.videoPlayer pause];
                self.pauseWhenApplicationDidEnterBackground = YES;
            }
        }
    }

}


#pragma mark - private
- (void)reset {
    int lock = pthread_mutex_trylock(&_lock);
    self.managerModel = nil;
    if (!lock) {
        pthread_mutex_unlock(&_lock);
    }
}

- (NSString *_Nullable)cacheKeyForURL:(NSURL *)url {
    if (!url) {
        return nil;
    }
    return [url absoluteString];
}

- (void)activeAudioSessionIfNeed {
    NSString *audioSessionCategory = AVAudioSessionCategoryPlayback;
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayerManagerPreferAudioSessionCategory:)]) {
        audioSessionCategory = [self.delegate videoPlayerManagerPreferAudioSessionCategory:self];
    }
    [AVAudioSession.sharedInstance setActive:YES error:nil];
    [AVAudioSession.sharedInstance setCategory:audioSessionCategory error:nil];
}

- (long long)fetchFileSizeAtPath:(NSString *)path {
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:path]) {
        return [[manager attributesOfItemAtPath:path error:nil] fileSize];
    }
    return 0;
}

#pragma mark - play Video
- (void)playLocalVideoWithURL:(NSURL *)url showOnLayer:(CALayer *)showLayer options:(JOVideoPlayerOptions)options configurationCompletion:(JOPlayVideoConfigurationCompletion)configurationCompletion {
    NSString *path = [url.absoluteString stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        self.managerModel.cacheType = JOVideoPlayerCacheTypeLocation;
        self.managerModel.fileLength = (NSUInteger)[self fetchFileSizeAtPath:path];
        self.managerModel.fragmentRanges = @[[NSValue valueWithRange:NSMakeRange(0, self.managerModel.fileLength)]];
        [self callVideoLengthDelegateMethodWithVideoLength:self.managerModel.fileLength];
        [self callDownloadDelegateMethodWithFragmentRanges:self.managerModel.fragmentRanges expectedSize:self.managerModel.fileLength cacheType:self.managerModel.cacheType error:nil];
        [self.videoPlayer playLocalFileWithURL:url options:options showOnLayer:showLayer completion:configurationCompletion];
    } else {
        NSError *error = [NSError errorWithDomain:JOVideoPlayerErrorDomain
                                             code:NSURLErrorFileDoesNotExist
                                         userInfo:@{NSLocalizedDescriptionKey : @"The file of given URL not exists"}];
        [self callDownloadDelegateMethodWithFragmentRanges:nil
                                              expectedSize:1
                                                 cacheType:JOVideoPlayerCacheTypeNone
                                                     error:error];
    }
}

- (void)playExistedVideoWithURL:(NSURL *)url videoPath:(NSString *)videoPath showOnLayer:(CALayer *)showLayer options:(JOVideoPlayerOptions)options configurationCompletion:(JOPlayVideoConfigurationCompletion)configurationCompletion {
    self.managerModel.cacheType = JOVideoPlayerCacheTypeFull;
    self.managerModel.fileLength = (NSUInteger)[self fetchFileSizeAtPath:videoPath];
    self.managerModel.fragmentRanges = @[[NSValue valueWithRange:NSMakeRange(0, self.managerModel.fileLength)]];
    [self callVideoLengthDelegateMethodWithVideoLength:self.managerModel.fileLength];
    [self callDownloadDelegateMethodWithFragmentRanges:self.managerModel.fragmentRanges expectedSize:self.managerModel.fileLength cacheType:self.managerModel.cacheType error:nil];
    [self.videoPlayer playLocalFileWithURL:url options:options showOnLayer:showLayer completion:configurationCompletion];
}

- (void)playFragmentVideoWithURL:(NSURL *)url showOnLayer:(CALayer *)showLayer options:(JOVideoPlayerOptions)options configurationCompletion:(JOPlayVideoConfigurationCompletion)configurationCompletion {
    
    JOPlayerModel *model = [self.videoPlayer playWithURL:url options:options showOnLayer:showLayer completion:configurationCompletion];
    self.managerModel.fileLength = model.resourceLoader.cacheFile.fileLength;
    self.managerModel.fragmentRanges = model.resourceLoader.cacheFile.fragmentRanges;
    [self callVideoLengthDelegateMethodWithVideoLength:model.resourceLoader.cacheFile.fileLength];
    [self callDownloadDelegateMethodWithFragmentRanges:model.resourceLoader.cacheFile.fragmentRanges
                                          expectedSize:model.resourceLoader.cacheFile.fileLength
                                             cacheType:self.managerModel.cacheType
                                                 error:nil];
}



#pragma mark - helper
- (void)callDownloadDelegateMethodWithFragmentRanges:(NSArray<NSValue *> *)fragmentRanges expectedSize:(NSUInteger)expectedSize cacheType:(JOVideoPlayerCacheType)cacheType error:(NSError *)error {
    JODispatchSyncOnMainThread(^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayerManagerDownloadProgressDidChange:cacheType:fragmentRanges:expectedSize:error:)]) {
            [self.delegate videoPlayerManagerDownloadProgressDidChange:self
                                                             cacheType:cacheType
                                                        fragmentRanges:fragmentRanges
                                                          expectedSize:expectedSize
                                                                 error:error];
        }
    });
}
- (void)callVideoLengthDelegateMethodWithVideoLength:(NSUInteger)videoLength {
    JODispatchSyncOnMainThread(^{
        if([self.delegate respondsToSelector:@selector(videoPlayerManager:didFetchVideoFileLength:)]){
            [self.delegate videoPlayerManager:self
                      didFetchVideoFileLength:videoLength];
        }
    });
}

- (void)callPlayDelegateMethodWithElapsedSeconds:(double)elapsedSeconds
                                    totalSeconds:(double)totalSeconds
                                           error:(nullable NSError *)error {
    
}

- (JOVideoDownloaderOptions)fetchDownloadOptionsWithOptions:(JOVideoPlayerOptions)options {
    // download if no cache, and download allowed by delegate.
    JOVideoDownloaderOptions downloadOptions = 0;
    if (options & JOVideoPlayerContinueInBackground)
        downloadOptions |= JOVideoDownloaderContinueInBackground;
    if (options & JOVideoPlayerHandleCookies)
        downloadOptions |= JOVideoDownloaderHandleCookies;
    if (options & JOVideoPlayerAllowInvalidSSLCertificates)
        downloadOptions |= JOVideoDownloaderAllowInvalidSSLCertificates;
    return downloadOptions;
}


#pragma mark - JOVideoPlayerPlayProtocol
- (void)setRate:(CGFloat)rate {
    [self.videoPlayer setRate:rate];
}

- (CGFloat)rate {
    return self.videoPlayer.rate;
}

- (void)setMuted:(BOOL)muted {
    [self.videoPlayer setMuted:muted];
}

- (BOOL)muted {
    return self.videoPlayer.muted;
}

- (void)setVolume:(CGFloat)volume {
    [self.videoPlayer setVolume:volume];
}

- (CGFloat)volume {
    return self.videoPlayer.volume;
}

- (void)seekToTime:(CMTime)time {
     [self.videoPlayer seekToTime:time];
}

- (NSTimeInterval)elapsedSeconds {
    return [self.videoPlayer elapsedSeconds];
}

- (NSTimeInterval)totalSeconds {
    return [self.videoPlayer totalSeconds];
}

- (void)pause {
    [self.videoPlayer pause];
}

- (void)resume {
    [self.videoPlayer resume];
}
- (void)play {
    [self.videoPlayer play];
}

- (CMTime)currentTime {
  return [self.videoPlayer currentTime];
}

- (void)stop{
    JODispatchSyncOnMainThread(^{
        [self.videoDownloader cancel];
        [self.videoPlayer stop];
        [self reset];
    });
}

#pragma mark - JOVideoPlayerDownloaderDelegate
- (void)downloader:(JOVideoPlayerDownloader *)downloader
didReceiveResponse:(NSURLResponse *)response {
    NSUInteger fileLength = self.videoPlayer.playerModel.resourceLoader.cacheFile.fileLength;
    self.managerModel.fileLength = fileLength;
    [self callVideoLengthDelegateMethodWithVideoLength:fileLength];
}

- (void)downloader:(JOVideoPlayerDownloader *)downloader
    didReceiveData:(NSData *)data
      receivedSize:(NSUInteger)receivedSize
      expectedSize:(NSUInteger)expectedSize {
    NSUInteger fileLength = self.videoPlayer.playerModel.resourceLoader.cacheFile.fileLength;
    NSArray<NSValue *> *fragmentRanges = self.videoPlayer.playerModel.resourceLoader.cacheFile.fragmentRanges;
    self.managerModel.cacheType = JOVideoPlayerCacheTypeFragment;
    self.managerModel.fragmentRanges = fragmentRanges;
    [self callDownloadDelegateMethodWithFragmentRanges:fragmentRanges
                                          expectedSize:fileLength
                                             cacheType:self.managerModel.cacheType
                                                 error:nil];
}

- (void)downloader:(JOVideoPlayerDownloader *)downloader
didCompleteWithError:(NSError *)error {
    if (error){
        [self callDownloadDelegateMethodWithFragmentRanges:nil
                                              expectedSize:1
                                                 cacheType:JOVideoPlayerCacheTypeNone
                                                     error:error];
        
        if (error.code != NSURLErrorNotConnectedToInternet
            && error.code != NSURLErrorCancelled
            && error.code != NSURLErrorTimedOut
            && error.code != NSURLErrorInternationalRoamingOff
            && error.code != NSURLErrorDataNotAllowed
            && error.code != NSURLErrorCannotFindHost
            && error.code != NSURLErrorCannotConnectToHost) {
            int lock = pthread_mutex_trylock(&_lock);
            if(self.managerModel.videoURL){
                [self.failedURLs addObject:self.managerModel.videoURL];
            }
            if (!lock) {
                pthread_mutex_unlock(&_lock);
            }
        }
        [self stop];
    } else {
        int lock = pthread_mutex_trylock(&_lock);
        if ([self.failedURLs containsObject:self.managerModel.videoURL]) {
            [self.failedURLs removeObject:self.managerModel.videoURL];
        }
        if (!lock) {
            pthread_mutex_unlock(&_lock);
        }
    }
}

#pragma mark - JPVideoPlayerDelegate

/**
 播放器状态改变通知
 */
- (void)videoPlayer:(nonnull JOVideoPlayer *)videoPlayer playerStatusDidChange:(JOVideoPlayerStatus)playerStatus {
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayerManager:playerStatusDidChanged:)]) {
        [self.delegate videoPlayerManager:self playerStatusDidChanged:playerStatus];
    }
}
/**
 播放器播放失败
 */
- (void)videoPlayer:(nonnull JOVideoPlayer *)videoPlayer playFailedWithError:(NSError *)error {
    [self stop];
    [self callPlayDelegateMethodWithElapsedSeconds:0
                                      totalSeconds:0
                                             error:error];
}
/**
 播放器播放了多少
 */
- (void)videoPlayerPlayProgressDidChange:(nonnull JOVideoPlayer *)videoPlayer
                          elapsedSeconds:(double)elapsedSeconds
                            totalSeconds:(double)totalSeconds {
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayerManagerPlayProgressDidChange:elapsedSeconds:totalSeconds:error:)]) {
        [self.delegate videoPlayerManagerPlayProgressDidChange:self
                                                elapsedSeconds:elapsedSeconds
                                                  totalSeconds:totalSeconds
                                                         error:nil];
    }
}
/**
 播放器是否需要重复播放
 */
- (BOOL)videoPlayer:(nonnull JOVideoPlayer *)videoPlayer
shouldAutoReplayVideoForURL:(nonnull NSURL *)videoURL {
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayerManager:shouldAutoReplayForURL:)]) {
        return [self.delegate videoPlayerManager:self shouldAutoReplayForURL:videoURL];
    }
    return YES;
}

- (void)videoPlayer:(JOVideoPlayer *)videoPlayer didReceiveLoadingRequestTask:(JOResourceLoadingWebTask *)requestTask {
    JOVideoDownloaderOptions downloaderOptions = [self fetchDownloadOptionsWithOptions:videoPlayer.playerModel.playerOptions];
    [self downloadVideoWithRequestTask:requestTask downloadOptions:downloaderOptions];
}

@end
