//
//  JOVideoPlayerView.m
//  JODevelop
//
//  Created by JimmyOu on 2018/6/15.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "JOVideoPlayerView.h"
#import "JOVideoPlayerCompat.h"

@interface JOVideoPlayerView()

@property (nonatomic, strong) UIView *placeholderView;

@property (nonatomic, strong) UIView *videoContainerView;

@property (nonatomic, strong) UIView *controlContainerView;

@property (nonatomic, strong) UIView *progressContainerView;

@property (nonatomic, strong) UIView *bufferingIndicatorContainerView;

@property (nonatomic, strong) UIView *userInteractionContainerView;

@property (nonatomic, strong) NSTimer *timer;

@property(nonatomic, assign) BOOL isInterruptTimer;

@end

static const NSTimeInterval kJOControlViewAutoHiddenTimeInterval = 5;

@implementation JOVideoPlayerView

- (instancetype)initWithNeedAutoHideControlViewWhenUserTapping:(BOOL)needAutoHideControlViewWhenUserTapping{
    self = [super init];
    if(self){
        _needAutoHideControlViewWhenUserTapping = needAutoHideControlViewWhenUserTapping;
        [self setupUI];
    }
    return self;

}
- (void)setupUI {
    [self addSubview:self.placeholderView];
    [self.placeholderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self addSubview:self.videoContainerView];
    [self.videoContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self addSubview:self.bufferingIndicatorContainerView];
    [self.bufferingIndicatorContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self addSubview:self.progressContainerView];
    [self.progressContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self addSubview:self.controlContainerView];
    [self.controlContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self addSubview:self.userInteractionContainerView];
    [self.userInteractionContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self);
        make.top.mas_equalTo(self);
        make.bottom.mas_equalTo(self).offset(-kJOVideoPlayerControlBarHeight);
        make.right.mas_equalTo(self);
    }];
    
    if (self.needAutoHideControlViewWhenUserTapping) {
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureDidTap)];
        [self.userInteractionContainerView addGestureRecognizer:tapGestureRecognizer];
        [self startTimer];
    }
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(didReceiveUserStartDragNotification)
                                               name:JOVideoPlayerControlUserDidStartDragNotification
                                             object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(didReceiveUserEndDragNotification)
                                               name:JOVideoPlayerControlUserDidEndDragNotification
                                             object:nil];
}
- (CALayer *)videoContainerLayer {
    return self.videoContainerView.layer;
}

- (void)didReceiveUserStartDragNotification {
    if(self.timer){
        self.isInterruptTimer = YES;
        [self endTimer];
    }
}

- (void)didReceiveUserEndDragNotification {
    if(self.isInterruptTimer){
        [self startTimer];
    }
}

- (void)startTimer {
    if(!self.timer){
        self.timer = [NSTimer timerWithTimeInterval:kJOControlViewAutoHiddenTimeInterval
                                             target:self
                                           selector:@selector(timeDidChange:)
                                           userInfo:nil
                                            repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
    
}
- (void)endTimer {
    if(self.timer){
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)timeDidChange:(NSTimer *)timer {
    [self tapGestureDidTap];
    [self endTimer];
}
#pragma mark - action
- (void)tapGestureDidTap {
    [UIView animateWithDuration:0.35
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         if(self.controlContainerView.alpha == 0){
                             self.controlContainerView.alpha = 1;
                             self.progressContainerView.alpha = 0;
                             [self startTimer];
                         }
                         else {
                             self.controlContainerView.alpha = 0;
                             self.progressContainerView.alpha = 1;
                             [self endTimer];
                         }
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

#pragma mark - get & set
- (UIView *)placeholderView  {
    if (!_placeholderView) {
        _placeholderView = [UIView new];
        _placeholderView.backgroundColor = [UIColor clearColor];
    }
    return _placeholderView;
}
- (UIView *)videoContainerView {
    if (!_videoContainerView) {
        _videoContainerView = [UIView new];
        _videoContainerView.backgroundColor = [UIColor clearColor];
        _videoContainerView.userInteractionEnabled = NO;
    }
    return _videoContainerView;
    
}
- (UIView *)bufferingIndicatorContainerView {
    if (!_bufferingIndicatorContainerView) {
        _bufferingIndicatorContainerView = [UIView new];
        _bufferingIndicatorContainerView.backgroundColor = [UIColor clearColor];
        _bufferingIndicatorContainerView.userInteractionEnabled = NO;
    }
    return _bufferingIndicatorContainerView;
}
- (UIView *)progressContainerView {
    if (!_progressContainerView) {
        _progressContainerView = [UIView new];
        _progressContainerView.backgroundColor = [UIColor clearColor];
    }
    return _progressContainerView;
}
- (UIView *)controlContainerView {
    if (!_controlContainerView) {
        _controlContainerView = [UIView new];
        _controlContainerView.backgroundColor = [UIColor clearColor];
        [self addSubview:_controlContainerView];
    }
    return _controlContainerView;
}
- (UIView *)userInteractionContainerView {
    if (!_userInteractionContainerView) {
        _userInteractionContainerView = [UIView new];
        _userInteractionContainerView.backgroundColor = [UIColor clearColor];
    }
    return _userInteractionContainerView;
}


- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

@end
