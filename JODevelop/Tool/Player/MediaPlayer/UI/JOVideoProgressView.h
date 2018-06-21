//
//  JOVideoProgressView.h
//  JODevelop
//
//  Created by JimmyOu on 2018/6/20.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JOVideoPlayerProtocol.h"

@interface JOVideoProgressView : UIView<JOVideoPlayerProtocol>

@property (nonatomic, strong, readonly) NSArray<NSValue *> *rangesValue;

@property (nonatomic, assign, readonly) NSUInteger fileLength;

@property (nonatomic, assign, readonly) NSTimeInterval totalSeconds;

@property (nonatomic, assign, readonly) NSTimeInterval elapsedSeconds;

@property (nonatomic, strong, readonly) UIProgressView *trackProgressView;

@property (nonatomic, strong, readonly) UIView *cachedProgressView;

@property (nonatomic, strong, readonly) UIProgressView *elapsedProgressView;

@end
