//
//  JOVideoControlProgressView.m
//  JODevelop
//
//  Created by JimmyOu on 2018/6/20.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "JOVideoControlProgressView.h"
#import "Masonry.h"
#import "JOVideoPlayerCompat.h"
#import "UIView+JOWebVideoPlayer.h"
@interface JOVideoControlProgressView()
@property (nonatomic, strong) NSArray<NSValue *> *rangesValue;

@property(nonatomic, assign) NSUInteger fileLength;

@property(nonatomic, assign) NSTimeInterval totalSeconds;

@property(nonatomic, assign) NSTimeInterval elapsedSeconds;

@property (nonatomic, strong) UISlider *dragSlider;

@property (nonatomic, strong) UIView *cachedProgressView;

@property (nonatomic, strong) UIProgressView *trackProgressView;
@end

static const CGFloat kJOVideoPlayerDragSliderLeftEdge = 2;
static const CGFloat kJOideoPlayerCachedProgressViewHeight = 2;

@implementation JOVideoControlProgressView{
    BOOL _userDragging;
    NSTimeInterval _userDragTimeInterval;
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
    [self addSubview:self.trackProgressView];
    [self.trackProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(kJOVideoPlayerDragSliderLeftEdge);
        make.centerY.mas_equalTo(self);
        make.right.mas_equalTo(self).offset(-kJOVideoPlayerDragSliderLeftEdge);
        make.height.mas_equalTo(kJOideoPlayerCachedProgressViewHeight);
    }];
    
    [self addSubview:self.dragSlider];
    [self.dragSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    
}

#pragma mark - get && set
- (UIProgressView *)trackProgressView {
    if (!_trackProgressView) {
        _trackProgressView = [UIProgressView new];
        _trackProgressView.trackTintColor = [UIColor colorWithWhite:1 alpha:0.15];
    }
    return _trackProgressView;
}
- (UIView *)cachedProgressView {
    if (!_cachedProgressView) {
        _cachedProgressView = [UIView new];
        _cachedProgressView.clipsToBounds = YES;
        _cachedProgressView.layer.cornerRadius = 1;
        _cachedProgressView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
    }
    return _cachedProgressView;
}
- (UISlider *)dragSlider {
    if (!_dragSlider) {
        _dragSlider = [UISlider new];
        [_dragSlider setThumbImage:JOImage(@"jo_videoplayer_progress_handler_normal") forState:UIControlStateNormal];
        [_dragSlider setThumbImage:JOImage(@"jo_videoplayer_progress_handler_hightlight") forState:UIControlStateHighlighted];
        _dragSlider.maximumTrackTintColor = [UIColor clearColor];
        [_dragSlider addTarget:self action:@selector(dragSliderDidDrag:) forControlEvents:UIControlEventValueChanged];
        [_dragSlider addTarget:self action:@selector(dragSliderDidStart:) forControlEvents:UIControlEventTouchDown];
        [_dragSlider addTarget:self action:@selector(dragSliderDidEnd:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dragSlider;
}
#pragma mark action
- (void)dragSliderDidStart:(UISlider *)slider {
    self.userDragging = YES;
    [NSNotificationCenter.defaultCenter postNotificationName:JOVideoPlayerControlUserDidStartDragNotification object:self];
}

- (void)dragSliderDidDrag:(UISlider *)slider {
    self.userDragTimeInterval = slider.value * self.totalSeconds;
}

- (void)dragSliderDidEnd:(UISlider *)slider {
    self.userDragging = NO;
    [self userDidFinishDrag];
    [NSNotificationCenter.defaultCenter postNotificationName:JOVideoPlayerControlUserDidEndDragNotification object:self];
}

- (void)userDidFinishDrag {
    if(!self.totalSeconds){
        return;
    }
    [self displayCacheProgressViewIfNeed];
    [self.playerView jo_seekToTime:CMTimeMakeWithSeconds([self fetchElapsedTimeInterval], 1000)];
}

#pragma mark -private

- (void)displayCacheProgressViewIfNeed {
    if(self.userDragging || !self.rangesValue.count){
        return;
    }
    [self removeCacheProgressViewIfNeed];
    NSRange targetRange = JOInvalidRange;
    NSUInteger dragStartLocation = [self fetchDragStartLocation];
    if(self.rangesValue.count == 1){
        if(JOValidFileRange([self.rangesValue.firstObject rangeValue])){
            targetRange = [self.rangesValue.firstObject rangeValue];
        }
    }
    else {
        // find the range that the closest to dragStartLocation.
        for(NSValue *value in self.rangesValue){
            NSRange range = [value rangeValue];
            NSUInteger distance = NSUIntegerMax;
            if(JOValidFileRange(range)){
                if(NSLocationInRange(dragStartLocation, range)){
                    targetRange = range;
                    break;
                }
                else {
                    int deltaDistance = abs((int)(range.location - dragStartLocation));
                    deltaDistance = abs((int)(NSMaxRange(range) - dragStartLocation)) < deltaDistance ?: deltaDistance;
                    if(deltaDistance < distance){
                        distance = deltaDistance;
                        targetRange = range;
                    }
                }
            }
        }
    }
    
    if(!JOValidFileRange(targetRange)){
        return;
    }
    if(self.fileLength == 0){
        return;
    }
    CGFloat cacheProgressViewOriginX = targetRange.location * self.trackProgressView.bounds.size.width / self.fileLength;
    CGFloat cacheProgressViewWidth = targetRange.length * self.trackProgressView.bounds.size.width / self.fileLength;
    self.cachedProgressView.frame = CGRectMake(cacheProgressViewOriginX, 0, cacheProgressViewWidth, kJOideoPlayerCachedProgressViewHeight);
    [self.trackProgressView addSubview:self.cachedProgressView];
    
}

- (NSTimeInterval)fetchElapsedTimeInterval {
    return self.dragSlider.value * self.totalSeconds;
}
- (void)removeCacheProgressViewIfNeed {
    if(self.cachedProgressView.superview){
        [self.cachedProgressView removeFromSuperview];
    }
}
- (NSUInteger)fetchDragStartLocation {
    return self.fileLength * self.dragSlider.value;
}


#pragma mark - JPVideoPlayerControlProgressProtocol

- (void)viewWillAddToPlayerView:(UIView *)playerView {
    self.playerView = playerView;
}

- (void)cacheRangeDidChange:(NSArray<NSValue *> *)cacheRanges videoURL:(NSURL *)videoURL {
    _rangesValue = cacheRanges;
    [self displayCacheProgressViewIfNeed];
}

- (void)didFetchVideoFileLength:(NSInteger)videoLenth videoURL:(NSURL *)videoURL {
    self.fileLength = videoLenth;
}

/**
 called when play progress changed
 */
- (void)playProgressDidChangeElapsedSeconds:(NSTimeInterval)elapsedSecounds totalSeconds:(NSTimeInterval)totalSeconds videoURL:(NSURL *)videoURL {
    if (self.userDragging) {
        return;
    }
    if (totalSeconds == 0) {
        totalSeconds = 1;
    }
    float delta = elapsedSecounds / totalSeconds;
    delta = MAX(MIN(1, delta), 0);
    [self.dragSlider setValue:delta animated:YES];
    self.totalSeconds = totalSeconds;
    self.elapsedSeconds = elapsedSecounds;
    
}


- (void)setUserDragging:(BOOL)userDragging {
    [self willChangeValueForKey:@"userDragging"];
    _userDragging = userDragging;
    [self didChangeValueForKey:@"userDragging"];
}

- (BOOL)userDragging {
    return _userDragging;
}

- (void)setUserDragTimeInterval:(NSTimeInterval)userDragTimeInterval {
    [self willChangeValueForKey:@"userDragTimeInterval"];
    _userDragTimeInterval = userDragTimeInterval;
    [self didChangeValueForKey:@"userDragTimeInterval"];
}

- (NSTimeInterval)userDragTimeInterval {
    return _userDragTimeInterval;
}

@end
