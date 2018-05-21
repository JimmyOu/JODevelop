//
//  JOPlayer.h
//  边下边播Demo
//
//  Created by JimmyOu on 2018/5/8.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "JOConst.h"
#import <AVFoundation/AVFoundation.h>

@interface JOPlayer : NSObject

@property (nonatomic, readonly) AVPlayerItem   *currentPlayerItem;
@property (nonatomic, readonly) JOPlayerState state;
@property (nonatomic, readonly) CGFloat       loadedProgress;   //缓冲进度
@property (nonatomic, readonly) CGFloat       duration;         //视频总时间
@property (nonatomic, readonly) CGFloat       current;          //当前播放时间
@property (nonatomic, readonly) CGFloat       progress;         //播放进度 0~1
@property (nonatomic) BOOL           isPauseByUser; //是否被用户暂停
@property (nonatomic) BOOL          stopWhenAppDidEnterBackground;// default is YES
@property (nonatomic, readonly) AVPlayerLayer  *currentPlayerLayer;


+ (instancetype)sharedInstance;
- (void)playWithUrl:(NSURL *)url showView:(UIView *)showView;
- (void)seekToTime:(CGFloat)seconds;

- (void)resume;
- (void)pause;
- (void)stop;

- (void)fullScreen;  //全屏
- (void)halfScreen;   //半屏


@end
