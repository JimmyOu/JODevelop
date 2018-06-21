//
//  JOVideoProgressView.m
//  JODevelop
//
//  Created by JimmyOu on 2018/6/20.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "JOVideoProgressView.h"

@interface JOVideoProgressView()

@property (nonatomic, strong) UIProgressView *trackProgressView;

@property (nonatomic, strong) UIView *cachedProgressView;

@property (nonatomic, strong) UIProgressView *elapsedProgressView;

@property (nonatomic, strong) NSArray<NSValue *> *rangesValue;

@property(nonatomic, assign) NSUInteger fileLength;

@property(nonatomic, assign) NSTimeInterval totalSeconds;

@property(nonatomic, assign) NSTimeInterval elapsedSeconds;

@end

const CGFloat JOVideoPlayerProgressViewElementHeight = 2;

@implementation JOVideoProgressView

- (instancetype)init {
    self = [super init];
    if(self){
        [self setupUI];
    }
    return self;
}

- (void)setupUI {

    [self addSubview:self.trackProgressView];
    [self.trackProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self);
        make.right.mas_equalTo(self);
        make.height.mas_equalTo(JOVideoPlayerProgressViewElementHeight);
        make.bottom.mas_equalTo(self);
    }];
    
    [self.trackProgressView addSubview:self.cachedProgressView];
    [self.cachedProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.trackProgressView);
    }];
    
    [self.trackProgressView addSubview:self.elapsedProgressView];
    [self.elapsedProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.trackProgressView);
    }];
    
}

#pragma mark - JOVideoPlayerProtocol

/**
 called when the downloader fetched the file length or read from disk.
 */
- (void)didFetchVideoFileLength:(NSInteger)videoLength videoURL:(NSURL *)videoURL {
    self.fileLength = videoLength;
}
/*
 called when recived new video data from web
 */
- (void)cacheRangeDidChange:(NSArray<NSValue *> *)cacheRanges videoURL:(NSURL *)videoURL {
    _rangesValue = cacheRanges;
    [self displayCacheProgressViewIfNeed];
}

/**
 called when play progress changed
 
 @param elapsedSecounds elapsed time
 @param totalSeconds total time
 @param videoURL video url
 */
- (void)playProgressDidChangeElapsedSeconds:(NSTimeInterval)elapsedSecounds totalSeconds:(NSTimeInterval)totalSeconds videoURL:(NSURL *)videoURL {
    if(totalSeconds == 0){
        totalSeconds = 1;
    }
    
    float delta = elapsedSecounds / totalSeconds;
    delta = MAX(MIN(1, delta), 0);
    [self.elapsedProgressView setProgress:delta animated:YES];
    self.totalSeconds = totalSeconds;
    self.elapsedSeconds = elapsedSecounds;
    
}

#pragma mark - private
- (void)displayCacheProgressViewIfNeed {
    if(!self.rangesValue.count){
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
    self.cachedProgressView.frame = CGRectMake(cacheProgressViewOriginX, 0, cacheProgressViewWidth, self.trackProgressView.bounds.size.height);
    [self.trackProgressView addSubview:self.cachedProgressView];
}

- (void)removeCacheProgressViewIfNeed {
    if(self.cachedProgressView.superview){
        [self.cachedProgressView removeFromSuperview];
    }
}

- (NSUInteger)fetchDragStartLocation {
    return self.fileLength * self.elapsedProgressView.progress;
}


- (UIProgressView *)trackProgressView {
    if (!_trackProgressView) {
        _trackProgressView = [UIProgressView new];
        _trackProgressView.trackTintColor = [UIColor colorWithWhite:1 alpha:0.15];
    }
    return _trackProgressView;
}
- (UIView *)cachedProgressView {
    if(!_cachedProgressView) {
        _cachedProgressView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
    }
    return _cachedProgressView;
}
- (UIProgressView *)elapsedProgressView {
    if (!_elapsedProgressView) {
        _elapsedProgressView = [UIProgressView new];
        _elapsedProgressView.trackTintColor = [UIColor clearColor];
    }
    return _elapsedProgressView;
}

@end
