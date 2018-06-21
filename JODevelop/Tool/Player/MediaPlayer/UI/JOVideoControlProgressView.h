//
//  JOVideoControlProgressView.h
//  JODevelop
//
//  Created by JimmyOu on 2018/6/20.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JOVideoPlayerProtocol.h"

@interface JOVideoControlProgressView : UIView<JOVideoPlayerControlProgressProtocol>

@property (nonatomic, strong, readonly) NSArray<NSValue *> *rangesValue;

@property (nonatomic, assign, readonly) NSUInteger fileLength;

@property (nonatomic, assign, readonly) NSTimeInterval totalSeconds;

@property (nonatomic, assign, readonly) NSTimeInterval elapsedSeconds;

@property (nonatomic, weak) UIView *playerView;

@property (nonatomic, strong, readonly) UISlider *dragSlider;

@property (nonatomic, strong, readonly) UIView *cachedProgressView;

@property (nonatomic, strong, readonly) UIProgressView *trackProgressView;


@end
