//
//  JOVideoControlBar.m
//  JODevelop
//
//  Created by JimmyOu on 2018/6/20.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "JOVideoControlBar.h"
#import "UIView+JOWebVideoPlayer.h"
#import "JOVideoControlProgressView.h"
#import "UIView+JOWebVideoPlayer.h"

@interface JOVideoControlBar()

@property (nonatomic, strong) UIButton *playButton;

@property (nonatomic, strong) UIView<JOVideoPlayerControlProgressProtocol> *progressView;

@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UIButton *landscapeButton;

@property(nonatomic, assign) NSTimeInterval totalSeconds;

@end

static const CGFloat kJOVideoPlayerControlBarButtonWidthHeight = 22;
static const CGFloat kJOVideoPlayerControlBarElementGap = 16;
static const CGFloat kJOVideoPlayerControlBarTimeLabelWidth = 68;

@implementation JOVideoControlBar

- (void)dealloc {
    [self.progressView removeObserver:self forKeyPath:@"userDragTimeInterval"];
}

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
    [self addSubview:self.playButton];
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kJOVideoPlayerControlBarButtonWidthHeight, kJOVideoPlayerControlBarButtonWidthHeight));
        make.left.mas_equalTo(self).offset(kJOVideoPlayerControlBarElementGap);
        make.centerY.mas_equalTo(self);
    }];
    
    [self addSubview:self.landscapeButton];
    [self.landscapeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kJOVideoPlayerControlBarButtonWidthHeight, kJOVideoPlayerControlBarButtonWidthHeight));
        make.right.mas_equalTo(self).offset(-kJOVideoPlayerControlBarElementGap);
        make.centerY.mas_equalTo(self);
    }];
    
    [self addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.right.mas_equalTo(self.landscapeButton.mas_left).offset(-kJOVideoPlayerControlBarElementGap);
        make.size.mas_equalTo(CGSizeMake(kJOVideoPlayerControlBarTimeLabelWidth, kJOVideoPlayerControlBarButtonWidthHeight));
    }];
    
    [self addSubview:self.progressView];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.playButton.mas_right).offset(kJOVideoPlayerControlBarElementGap);
        make.right.mas_equalTo(self.timeLabel.mas_left).offset(-kJOVideoPlayerControlBarElementGap);
        make.centerY.mas_equalTo(self);
        make.height.mas_equalTo(kJOVideoPlayerControlBarButtonWidthHeight);
    }];
    
}

#pragma mark - Private
- (void)updateTimeLabelWithElapsedSeconds:(NSTimeInterval)elapsedSeconds
                             totalSeconds:(NSTimeInterval)totalSeconds {
    NSString *elapsedString = [self convertSecondsToTimeString:elapsedSeconds];
    NSString *totalString = [self convertSecondsToTimeString:totalSeconds];
    self.timeLabel.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@/%@", elapsedString, totalString]
                                                                    attributes:@{
                                                                                 NSFontAttributeName : [UIFont systemFontOfSize:10],
                                                                                 NSForegroundColorAttributeName : [UIColor whiteColor]
                                                                                 }];
}
- (NSString *)convertSecondsToTimeString:(NSTimeInterval)seconds {
    NSUInteger minute = (NSUInteger)(seconds / 60);
    NSUInteger second = (NSUInteger)((NSUInteger)seconds % 60);
    return [NSString stringWithFormat:@"%02d:%02d", (int)minute, (int)second];
}

#pragma mark - action
- (void)playButtonDidClick:(UIButton *)button {
    button.selected = !button.selected;
    BOOL isPlay = self.playerView.jo_videoPlayerStatus == JOVideoPlayerStatusBuffering ||
    self.playerView.jo_videoPlayerStatus == JOVideoPlayerStatusPlaying;
    isPlay ? [self.playerView jo_pause] : [self.playerView jo_resume];
}

- (void)landscapeButtonDidClick:(UIButton *)button {
    button.selected = !button.selected;
    self.playerView.jo_InterfaceOrientation == JOVideoPlayViewInterfaceOrientationPortrait ? [self.playerView jo_gotoLandscape] : [self.playerView jo_gotoPortrait];
}

#pragma mark - kvo
- (void)observeValueForKeyPath:(nullable NSString *)keyPath
                      ofObject:(nullable id)object
                        change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change
                       context:(nullable void *)context {
    if([keyPath isEqualToString:@"userDragTimeInterval"]) {
        NSNumber *timeIntervalNumber = change[NSKeyValueChangeNewKey];
        NSTimeInterval timeInterval = timeIntervalNumber.floatValue;
        [self updateTimeLabelWithElapsedSeconds:timeInterval totalSeconds:self.totalSeconds];
    }
}

#pragma mark - getter & setter
- (UIButton *)landscapeButton {
    if (!_landscapeButton) {
        _landscapeButton = [UIButton new];
        [_landscapeButton setImage:JOImage(@"jo_videoplayer_landscape") forState:UIControlStateNormal];
        [_landscapeButton setImage:JOImage(@"jo_videoplayer_portrait") forState:UIControlStateSelected];
        [_landscapeButton addTarget:self action:@selector(landscapeButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _landscapeButton;
}
- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _timeLabel;
}
- (UIView<JOVideoPlayerControlProgressProtocol> *)progressView {
    if(!_progressView) {
        _progressView = [JOVideoControlProgressView new];
        [_progressView addObserver:self forKeyPath:@"userDragTimeInterval" options:NSKeyValueObservingOptionNew context:nil];
    }
    return _progressView;
}
- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [[UIButton alloc] init];
        [_playButton setImage:JOImage(@"jo_videoplayer_pause") forState:UIControlStateNormal];
        [_playButton setImage:JOImage(@"jo_videoplayer_play") forState:UIControlStateSelected];
        [_playButton addTarget:self action:@selector(playButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}

#pragma mark - JOVideoPlayerControlProgressProtocol

- (void)viewWillAddToPlayerView:(UIView *)playerView {
    self.playerView = playerView;
    [self updateTimeLabelWithElapsedSeconds:0 totalSeconds:0];
    [self.progressView viewWillAddToPlayerView:playerView];
}
/**
 called when the downloader fetched the file length or read from disk.
 */
- (void)didFetchVideoFileLength:(NSInteger)videoLength videoURL:(NSURL *)videoURL {
    [self.progressView didFetchVideoFileLength:videoLength
                                      videoURL:videoURL];
}
/*
 called when recived new video data from web
 */
- (void)cacheRangeDidChange:(NSArray<NSValue *> *)cacheRanges videoURL:(NSURL *)videoURL {
    [self.progressView cacheRangeDidChange:cacheRanges
                                  videoURL:videoURL];
}

/**
 called when play progress changed
 
 @param elapsedSeconds elapsed time
 @param totalSeconds total time
 @param videoURL video url
 */
- (void)playProgressDidChangeElapsedSeconds:(NSTimeInterval)elapsedSeconds totalSeconds:(NSTimeInterval)totalSeconds videoURL:(NSURL *)videoURL {
    self.totalSeconds = totalSeconds;
    if(!self.progressView.userDragging){
        [self updateTimeLabelWithElapsedSeconds:elapsedSeconds totalSeconds:totalSeconds];
    }
    [self.progressView playProgressDidChangeElapsedSeconds:elapsedSeconds
                                              totalSeconds:totalSeconds
                                                  videoURL:videoURL];
    
}

/**
 called when play status changed
 */
- (void)videoplayerStatusDidChange:(JOVideoPlayerStatus)playerStatus videoURL:(NSURL *)videoURL {
    BOOL isPlaying = playerStatus == JOVideoPlayerStatusBuffering || playerStatus == JOVideoPlayerStatusPlaying;
    self.playButton.selected = !isPlaying;
}
/**
 called when play orientation did changed
 */
- (void)videoPlayerInterfaceOrientationDidChange:(JOVideoPlayViewInterfaceOrientation)interfaceOrientation videoURL:(NSURL *)videoURL {
    self.landscapeButton.selected = interfaceOrientation == JOVideoPlayViewInterfaceOrientationLandscape;
}



@end
