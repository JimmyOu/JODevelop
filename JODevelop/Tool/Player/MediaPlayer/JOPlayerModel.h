//
//  JOPlayerModel.h
//  JODevelop
//
//  Created by JimmyOu on 2018/6/12.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JOVideoPlayerProtocol.h"
#import "JOVideoPlayerResourceLoader.h"
#import "JOVideoPlayerCompat.h"
#import "JOVideoPlayer.h"
@class JOVideoPlayer;

@interface JOPlayerModel : NSObject<JOVideoPlayerPlayProtocol>

/**
 * 当前资源的url
 */
@property(nonatomic, strong, nullable)NSURL *url;
/**
 * 视频layer 所在的layer
 */
@property(nonatomic, weak, nullable)CALayer *unownedShowLayer;

/**
 * options,
 */
@property(nonatomic, assign)JOVideoPlayerOptions playerOptions;

/**
 * The Player to play video.
 */
@property(nonatomic, strong, nullable)AVPlayer *player;

/**
 * The current player's layer.
 */
@property(nonatomic, strong, nullable)AVPlayerLayer *playerLayer;

/**
 * The current player's item.
 */
@property(nonatomic, strong, nullable)AVPlayerItem *playerItem;

/**
 * The current player's urlAsset.
 */
@property(nonatomic, strong, nullable)AVURLAsset *videoURLAsset;


/**
 * The resourceLoader for the videoPlayer.
 */
@property(nonatomic, strong, nullable)JOVideoPlayerResourceLoader *resourceLoader;

/**
 * The last play time for player.
 */
@property(nonatomic, assign)NSTimeInterval lastTime;

/**
 * The play progress observer.
 */
@property(nonatomic, strong)id timeObserver;

/**
 * A flag to book is cancel play or not.
 */
@property(nonatomic, assign, getter=isCancelled)BOOL cancelled;

/*
 * videoPlayer.
 */
@property(nonatomic, weak) JOVideoPlayer *videoPlayer;

@property(nonatomic, assign) NSTimeInterval elapsedSeconds;

@property(nonatomic, assign) NSTimeInterval totalSeconds;

- (void)reset;

@end
