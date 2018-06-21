//
//  JOPlayerModel.m
//  JODevelop
//
//  Created by JimmyOu on 2018/6/12.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "JOPlayerModel.h"
#import "JOVideoPlayer.h"

@implementation JOPlayerModel

#pragma mark - JOVideoPlayerPlayProtocol

- (void)setRate:(CGFloat)rate {
    self.player.rate = rate;
}

- (CGFloat)rate {
    return self.player.rate;
}

- (void)setMuted:(BOOL)muted {
    self.player.muted = muted;
}

- (BOOL)muted {
    return self.player.muted;
}

- (void)setVolume:(CGFloat)volume {
    self.player.volume = volume;
}

- (CGFloat)volume {
    return self.player.volume;
}

- (void)seekToTime:(CMTime)time {
    NSAssert(NO, @"You cannot call this method.");
}

- (void)play {
    [self.player play];
}
- (void)pause {
    [self.player pause];
}

- (void)resume {
    [self.player play];
}

- (CMTime)currentTime {
    return self.player.currentTime;
}


- (void)stop {
    self.cancelled = YES;
    [self reset];
}

- (void)reset {
    // remove video layer from superlayer.
    if (self.playerLayer.superlayer) {
        [self.playerLayer removeFromSuperlayer];
    }
    
    // remove observer.
    [self.playerItem removeObserver:self.videoPlayer forKeyPath:@"status"];
    [self.player removeTimeObserver:self.timeObserver];
    [self.player removeObserver:self.videoPlayer forKeyPath:@"rate"];
    
    // remove player
    [self.player pause];
    [self.player cancelPendingPrerolls];
    self.player = nil;
    [self.videoURLAsset.resourceLoader setDelegate:nil queue:dispatch_get_main_queue()];
    self.playerItem = nil;
    self.playerLayer = nil;
    self.videoURLAsset = nil;
    self.resourceLoader = nil;
    self.elapsedSeconds = 0;
    self.totalSeconds = 0;
}


@end
