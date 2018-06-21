//
//  JOVideoBufferingIndicator.m
//  JODevelop
//
//  Created by JimmyOu on 2018/6/20.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "JOVideoBufferingIndicator.h"

@interface JOVideoBufferingIndicator()

@property(nonatomic, strong)UIActivityIndicatorView *activityIndicator;

@property(nonatomic, strong)UIVisualEffectView *blurView;

@property(nonatomic, assign, getter=isAnimating)BOOL animating;

@property (nonatomic, strong) UIView *blurBackgroundView;
@end

CGFloat const JOVideoPlayerBufferingIndicatorWidthHeight = 46;
@implementation JOVideoBufferingIndicator

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.blurBackgroundView];
    [self.blurBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(JOVideoPlayerBufferingIndicatorWidthHeight, JOVideoPlayerBufferingIndicatorWidthHeight));
        make.center.mas_equalTo(self);
    }];
    
    [self.blurBackgroundView addSubview:self.blurView];
    [self.blurView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.blurBackgroundView);
    }];
    
    [self.blurBackgroundView addSubview:self.activityIndicator];
    [self.activityIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.blurBackgroundView);
    }];
    
    self.animating = NO;
    
}

- (void)startAnimation {
    if (!self.isAnimating) {
        self.hidden = NO;
        [self.activityIndicator startAnimating];
        self.animating = YES;
    }
}
- (void)stopAnimation {
    if (self.isAnimating) {
        self.hidden = YES;
        [self.activityIndicator stopAnimating];
        self.animating = NO;
    }
}
#pragma mark - JOVideoPlayerBufferingProtocol
- (void)didStartBufferingVideoURL:(NSURL *)videoURL {
    [self startAnimation];
}
- (void)didFinishBufferingVideoURL:(NSURL *)videoURL {
    [self stopAnimation];
    
}

- (UIView *)blurBackgroundView {
    if (!_blurBackgroundView) {
        _blurBackgroundView = [UIView new];
        _blurBackgroundView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.6];
        _blurBackgroundView.layer.cornerRadius = 10;
        _blurBackgroundView.clipsToBounds = YES;
    }
    return _blurBackgroundView;
}
- (UIVisualEffectView *)blurView {
    if (!_blurView) {
        _blurView = [[UIVisualEffectView alloc]initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    }
    return _blurView;
}
- (UIActivityIndicatorView *)activityIndicator {
    if (!_activityIndicator) {
        _activityIndicator = [UIActivityIndicatorView new];
        _activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        _activityIndicator.color = [UIColor colorWithRed:35.0/255 green:35.0/255 blue:35.0/255 alpha:1];
    }
    return _activityIndicator;
}

@end
