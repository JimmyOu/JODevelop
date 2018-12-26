//
//  JOVideoControlView.m
//  JODevelop
//
//  Created by JimmyOu on 2018/6/20.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "JOVideoControlView.h"
#import "JOVideoControlBar.h"
#import "Masonry.h"

@interface JOVideoControlView()
@property (nonatomic, strong) UIView<JOVideoPlayerProtocol> *controlBar;

@property (nonatomic, strong) UIImageView *blurImageView;
@end
@implementation JOVideoControlView

- (instancetype)initWithControlBar:(UIView<JOVideoPlayerProtocol> *)controlBar blurImage:(UIImage *)blurImage {
    if (self = [super initWithFrame:CGRectZero]) {
        _controlBar = controlBar;
        _blurImage = blurImage;
        [self setupUI];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    NSAssert(NO, @"Please use given method to initialize this class.");
    return [self initWithControlBar:nil blurImage:nil];
}
- (instancetype)initWithFrame:(CGRect)frame {
    NSAssert(NO, @"Please use given method to initialize this class.");
    return [self initWithControlBar:nil blurImage:nil];
}

- (void)setupUI {
    
    [self addSubview:self.blurImageView];
    [self.blurImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self addSubview:self.controlBar];
    [self.controlBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self);
        make.bottom.mas_equalTo(self);
        make.right.mas_equalTo(self);
        make.height.mas_equalTo(kJOVideoPlayerControlBarHeight);
    }];
}

#pragma JOVideoPlayerProtocol

- (void)viewWillPrepareToReuse {
    [self.controlBar viewWillPrepareToReuse];
}

- (void)viewWillAddToPlayerView:(UIView *)playerView {
    [self.controlBar viewWillAddToPlayerView:playerView];
}
/**
 called when the downloader fetched the file length or read from disk.
 */
- (void)didFetchVideoFileLength:(NSInteger)videoLength videoURL:(NSURL *)videoURL {
    [self.controlBar didFetchVideoFileLength:videoLength
                                    videoURL:videoURL];
}
/*
 called when recived new video data from web
 */
- (void)cacheRangeDidChange:(NSArray<NSValue *> *)cacheRanges videoURL:(NSURL *)videoURL {
    [self.controlBar cacheRangeDidChange:cacheRanges
                                videoURL:videoURL];
}

/**
 called when play progress changed
 
 @param elapsedSeconds elapsed time
 @param totalSeconds total time
 @param videoURL video url
 */
- (void)playProgressDidChangeElapsedSeconds:(NSTimeInterval)elapsedSeconds totalSeconds:(NSTimeInterval)totalSeconds videoURL:(NSURL *)videoURL {
    [self.controlBar playProgressDidChangeElapsedSeconds:elapsedSeconds
                                            totalSeconds:totalSeconds
                                                videoURL:videoURL];
}

/**
 called when play status changed
 */
- (void)videoplayerStatusDidChange:(JOVideoPlayerStatus)playerStatus videoURL:(NSURL *)videoURL {
    [self.controlBar videoplayerStatusDidChange:playerStatus
                                       videoURL:videoURL];
}
/**
 called when play orientation did changed
 */
- (void)videoPlayerInterfaceOrientationDidChange:(JOVideoPlayViewInterfaceOrientation)interfaceOrientation videoURL:(NSURL *)videoURL {
    [self.controlBar videoPlayerInterfaceOrientationDidChange:interfaceOrientation
                                                     videoURL:videoURL];
}
- (UIImageView *)blurImageView {
    if (!_blurImageView) {
        _blurImageView = [UIImageView new];
        _blurImageView.image = (self.blurImage == nil) ? JOImage(@"jo_videoplayer_blur"): self.blurImage;
    }
    return _blurImageView;
}
- (UIView<JOVideoPlayerProtocol> *)controlBar {
    if (!_controlBar) {
        _controlBar = [[JOVideoControlBar alloc] init];
    }
    return _controlBar;
}
@end
