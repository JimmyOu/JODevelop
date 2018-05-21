//
//  VideoControlView.h
//  边下边播Demo
//
//  Created by JimmyOu on 2018/5/8.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JOConst.h"
#import "JOPlayer.h"
@interface VideoControlView : UIView

@property (nonatomic, strong) UIView         *navBar;
@property (nonatomic, strong) UILabel        *currentTimeLabel;
@property (nonatomic, strong) UILabel        *totolTimeLabel;
@property (nonatomic, strong) UIProgressView *videoProgressView;  //缓冲进度条
@property (nonatomic, strong) UISlider       *playSlider;  //滑竿
@property (nonatomic, strong) UIButton       *stopButton;//播放暂停按钮
@property (nonatomic, strong) UIButton       *screenBUtton;//全屏按钮
@property (weak, nonatomic)  JOPlayer *player;

- (void)setStopButtonPause:(BOOL)pause;
- (void)setPlaySliderValue:(CGFloat)time;

- (void)updateCurrentTime:(CGFloat)time;
- (void)updateTotolTime:(CGFloat)time;
- (void)updateVideoSlider:(CGFloat)currentSecond ;

@end
