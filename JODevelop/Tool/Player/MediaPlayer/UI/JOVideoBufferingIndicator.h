//
//  JOVideoBufferingIndicator.h
//  JODevelop
//
//  Created by JimmyOu on 2018/6/20.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JOVideoPlayerProtocol.h"

@interface JOVideoBufferingIndicator : UIView<JOVideoPlayerBufferingProtocol>

@property (nonatomic, strong, readonly)UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong, readonly)UIVisualEffectView *blurView;

@property (nonatomic, assign, readonly, getter=isAnimating)BOOL animating;

@end
