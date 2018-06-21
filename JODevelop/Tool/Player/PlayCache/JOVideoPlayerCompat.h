//
//  JOVideoPlayerCompat.h
//  JODevelop
//
//  Created by JimmyOu on 2018/5/15.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
@class JOPlayerModel;

typedef NS_ENUM(NSInteger, JOVideoPlayViewInterfaceOrientation) {
    JOVideoPlayViewInterfaceOrientationUnknown = 0,
    JOVideoPlayViewInterfaceOrientationPortrait,
    JOVideoPlayViewInterfaceOrientationLandscape,
};

typedef NS_ENUM(NSUInteger, JOVideoPlayerStatus)  { //播放器状态
    JOVideoPlayerStatusUnknown = 0,
    JOVideoPlayerStatusBuffering, //缓冲中
    JOVideoPlayerStatusReadyToPlay,//可以播放
    JOVideoPlayerStatusPlaying,//正在播放
    JOVideoPlayerStatusPause,//暂停
    JOVideoPlayerStatusFailed,//播放失败
    JOVideoPlayerStatusStop,//停止播放
};
typedef void(^JOPlayVideoConfigurationCompletion)(UIView *_Nonnull view, JOPlayerModel *_Nonnull playerModel);

UIKIT_EXTERN NSString *const JOVideoPlayerDownloadStartNotification;
UIKIT_EXTERN NSString *const JOVideoPlayerDownloadReceiveResponseNotification;
UIKIT_EXTERN NSString *const JOVideoPlayerDownloadStopNotification;
UIKIT_EXTERN NSString *const JOVideoPlayerDownloadFinishNotification;
UIKIT_EXTERN NSString *const JOVideoPlayerControlUserDidStartDragNotification;
UIKIT_EXTERN NSString *const JOVideoPlayerControlUserDidEndDragNotification;
UIKIT_EXTERN const CGFloat kJOVideoPlayerControlBarHeight;

UIKIT_EXTERN NSString *const JOVideoPlayerErrorDomain;
FOUNDATION_EXTERN const NSRange JOInvalidRange;
void JODispatchSyncOnMainThread(dispatch_block_t block);

void JODispatchASyncOnMainThread(dispatch_block_t block);

BOOL JOValidByteRange(NSRange range);

BOOL JOValidFileRange(NSRange range);

BOOL JORangeCanMerge(NSRange range1, NSRange range2);

NSString* JORangeToHTTPRangeHeader(NSRange range);

NSError *JOErrorWithDescription(NSString *description);

#define JOMainThreadAssert NSParameterAssert([[NSThread currentThread] isMainThread])
#define JOImage(name) [UIImage imageNamed:name]

#define Init_PThread_Lock(lock)\
        pthread_mutexattr_t mutexattr;\
        pthread_mutexattr_init(&mutexattr);\
        pthread_mutexattr_settype(&mutexattr, PTHREAD_MUTEX_RECURSIVE);\
        pthread_mutex_init(lock, &mutexattr)\


typedef NS_OPTIONS(NSUInteger, JOVideoDownloaderOptions) {
    /*
     ignore data from NSURLCache
     */
    JOVideoDownloaderIgnoreCachedResponse = 1 << 0,
    /*
     ask for extra time in background for downloading
     */
    JOVideoDownloaderContinueInBackground = 1 << 1,
    /*
     should handle cookies
     */
    JOVideoDownloaderHandleCookies = 1 << 2,
    /*
     enable to allow untrusted ssl certificates
     */
    JOVideoDownloaderAllowInvalidSSLCertificates = 1 << 3,

};

typedef NS_OPTIONS(NSUInteger, JOVideoPlayerOptions) {
    /**
     * By default, when a URL fail to be downloaded, the URL is blacklisted so the library won't keep trying.
     * This flag disable this blacklisting.
     */
    JOVideoPlayerRetryFailed = 1 << 0,
    
    /**
     play in background
     */
    JOVideoPlayerContinueInBackground = 1 << 1,
    
    /**
     should handle cookies
     */
    JOVideoPlayerHandleCookies = 1 << 2,
    
    /**
     enable to allow untrusted ssl certificates
     */
    JOVideoPlayerAllowInvalidSSLCertificates = 1 << 3,
    
    /**
     * Playing video muted.
     */
    JOVideoPlayerMutedPlay = 1 << 4,
    
    /**
     * Stretch to fill layer bounds.
     */
    JOVideoPlayerLayerVideoGravityResize = 1 << 5,
    
    /**
     * Preserve aspect ratio; fit within layer bounds.
     * Default value.
     */
    JOVideoPlayerLayerVideoGravityResizeAspect = 1 << 6,
    
    /**
     * Preserve aspect ratio; fill layer bounds.
     */
    JOVideoPlayerLayerVideoGravityResizeAspectFill = 1 << 7,
};


@interface NSURL (StripQuery)

- (NSString *)absoluteStringByStrippingQuery;

@end

@interface NSHTTPURLResponse (JOVideoPlayer)

- (long long)jo_fileLength;
- (BOOL)jo_supportRange;

@end

@interface NSFileHandle (JOVideoPlayer)
- (BOOL)jo_safeWriteData:(NSData *)data;
@end

@interface AVAssetResourceLoadingRequest (JOVideoPlayer)
- (void)jo_fillContentInformationWithResponse:(NSHTTPURLResponse *)response;
@end 

