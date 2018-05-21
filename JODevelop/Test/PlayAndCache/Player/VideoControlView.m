//
//  VideoControlView.m
//  边下边播Demo
//
//  Created by JimmyOu on 2018/5/8.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "VideoControlView.h"
#import "UIColor+Extension.h"
#import "NSString+FormatTime.h"

@implementation VideoControlView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(halfScreen)];
        
        [self addGestureRecognizer:tap];
        [self setupUI];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.navBar.frame = CGRectMake(0, self.frame.size.height - 44, kScreenWidth, 44);
}
- (void)setupUI {
    if (!self.navBar) {
        self.navBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)];
        self.navBar.backgroundColor = [UIColor colorWithHex:0x000000 alpha:0.5];
        [self addSubview:self.navBar];
    }
    //当前时间
    if (!self.currentTimeLabel) {
        self.currentTimeLabel = [[UILabel alloc] init];
        _currentTimeLabel.textColor = [UIColor colorWithHex:0xffffff alpha:1.0];
        _currentTimeLabel.font = [UIFont systemFontOfSize:10.0];
        _currentTimeLabel.frame = CGRectMake(30, 0, 52, 44);
        _currentTimeLabel.textAlignment = NSTextAlignmentRight;
        [_navBar addSubview:_currentTimeLabel];
    }
    
    
    //总时间
    if (!self.totolTimeLabel) {
        self.totolTimeLabel = [[UILabel alloc] init];
        _totolTimeLabel.textColor = [UIColor colorWithHex:0xffffff alpha:1.0];
        _totolTimeLabel.font = [UIFont systemFontOfSize:10.0];
        _totolTimeLabel.frame = CGRectMake(kScreenWidth-52-15, 0, 52, 44);
        _totolTimeLabel.textAlignment = NSTextAlignmentLeft;
        [_navBar addSubview:_totolTimeLabel];
    }
    
    
    //进度条
    if (!self.videoProgressView) {
        self.videoProgressView = [[UIProgressView alloc] init];
        _videoProgressView.progressTintColor = [UIColor colorWithHex:0xffffff alpha:1.0];  //填充部分颜色
        _videoProgressView.trackTintColor = [UIColor colorWithHex:0xffffff alpha:0.18];   // 未填充部分颜色
        _videoProgressView.frame = CGRectMake(62+30, 21, kScreenWidth-124-44, 20);
        _videoProgressView.layer.cornerRadius = 1.5;
        _videoProgressView.layer.masksToBounds = YES;
        CGAffineTransform transform = CGAffineTransformMakeScale(1.0, 1.5);
        _videoProgressView.transform = transform;
        [_navBar addSubview:_videoProgressView];
    }
    
    
    //滑竿
    if (!self.playSlider) {
        
        self.playSlider = [[UISlider alloc] init];
        _playSlider.frame = CGRectMake(62+30, 0, kScreenWidth-124-44, 44);
        [_playSlider setThumbImage:[UIImage imageNamed:@"icon_progress"] forState:UIControlStateNormal];
        _playSlider.minimumTrackTintColor = [UIColor clearColor];
        _playSlider.maximumTrackTintColor = [UIColor clearColor];
        [_playSlider addTarget:self action:@selector(playSliderChange:) forControlEvents:UIControlEventValueChanged]; //拖动滑竿更新时间
        [_playSlider addTarget:self action:@selector(playSliderChangeEnd:) forControlEvents:UIControlEventTouchUpInside];  //松手,滑块拖动停止
        [_playSlider addTarget:self action:@selector(playSliderChangeEnd:) forControlEvents:UIControlEventTouchUpOutside];
        [_playSlider addTarget:self action:@selector(playSliderChangeEnd:) forControlEvents:UIControlEventTouchCancel];
        
        [_navBar addSubview:_playSlider];
    }
    
    //暂停按钮
    if (!self.stopButton) {
        self.stopButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _stopButton.frame = CGRectMake(0, 0, 44, 44);
        [_stopButton addTarget:self action:@selector(resumeOrPause) forControlEvents:UIControlEventTouchUpInside];
        [_stopButton setImage:[UIImage imageNamed:@"icon_pause"] forState:UIControlStateNormal];
        [_stopButton setImage:[UIImage imageNamed:@"icon_pause_hl"] forState:UIControlStateHighlighted];
        [_navBar addSubview:_stopButton];
    }
    
    //全屏按钮
    if (!self.screenBUtton) {
        self.screenBUtton = [[UIButton alloc] init];
        _screenBUtton.frame = CGRectMake(kScreenWidth - 40, 0, 44, 44);
        [_screenBUtton addTarget:self action:@selector(fullScreen) forControlEvents:UIControlEventTouchUpInside];
        [_screenBUtton setImage:[UIImage imageNamed:@"quanping"] forState:UIControlStateNormal];
        [_screenBUtton setImage:[UIImage imageNamed:@"quanping"] forState:UIControlStateHighlighted];
        [_navBar addSubview:_screenBUtton];
    }
}
- (void)fullScreen {
    _navBar.hidden = YES;
    [self.player fullScreen];
}

- (void)halfScreen
{
    _navBar.hidden = NO;
    [self.player halfScreen];
}

//手指结束拖动，播放器从当前点开始播放，开启滑竿的时间走动
- (void)playSliderChangeEnd:(UISlider *)slider
{
    [self.player seekToTime:slider.value];
    [self updateCurrentTime:slider.value];
    [_stopButton setImage:[UIImage imageNamed:@"icon_pause"] forState:UIControlStateNormal];
    [_stopButton setImage:[UIImage imageNamed:@"icon_pause_hl"] forState:UIControlStateHighlighted];
}

//手指正在拖动，播放器继续播放，但是停止滑竿的时间走动
- (void)playSliderChange:(UISlider *)slider
{
    [self updateCurrentTime:slider.value];
}
- (void)resumeOrPause
{
    if (!self.player.currentPlayerItem) {
        return;
    }
    if (self.player.state == JOPlayerStatePlaying) {
        [_stopButton setImage:[UIImage imageNamed:@"icon_play"] forState:UIControlStateNormal];
        [_stopButton setImage:[UIImage imageNamed:@"icon_play_hl"] forState:UIControlStateHighlighted];
        [self.player pause];
        self.player.isPauseByUser = YES;
    } else if (self.player.state == JOPlayerStatePause) {
        [_stopButton setImage:[UIImage imageNamed:@"icon_pause"] forState:UIControlStateNormal];
        [_stopButton setImage:[UIImage imageNamed:@"icon_pause_hl"] forState:UIControlStateHighlighted];
        [self.player resume];
        self.player.isPauseByUser = NO;
    }
}


#pragma publick

- (void)updateCurrentTime:(CGFloat)time
{
    _currentTimeLabel.text = [NSString formatTime:time];
}

- (void)setPlaySliderValue:(CGFloat)time
{
    _playSlider.minimumValue = 0.0;
    _playSlider.maximumValue = (NSInteger)time;
}
- (void)updateTotolTime:(CGFloat)time
{
    _totolTimeLabel.text = [NSString formatTime:time];;
}

- (void)updateVideoSlider:(CGFloat)currentSecond {
    [self.playSlider setValue:currentSecond animated:YES];
}

- (void)setStopButtonPause:(BOOL)pause {
    if (pause) {
        [_stopButton setImage:[UIImage imageNamed:@"icon_play"] forState:UIControlStateNormal];
        [_stopButton setImage:[UIImage imageNamed:@"icon_play_hl"] forState:UIControlStateHighlighted];
    } else {
        [_stopButton setImage:[UIImage imageNamed:@"icon_pause"] forState:UIControlStateNormal];
        [_stopButton setImage:[UIImage imageNamed:@"icon_pause_hl"] forState:UIControlStateHighlighted];
    }
}



@end
