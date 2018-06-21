//
//  JOVideoPlayerView.h
//  JODevelop
//
//  Created by JimmyOu on 2018/6/15.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JOVideoPlayerView : UIView

/**
 * A placeholderView to custom your own business.
 */
@property (nonatomic, strong, readonly) UIView *placeholderView;

/**
 * A layer to display video layer.
 */
@property (nonatomic, strong, readonly) CALayer *videoContainerLayer;

/**
* A placeholder view to display controlView
*/
@property (nonatomic, strong, readonly) UIView *controlContainerView;

/**
 * A placeholder view to display progress view.
 */
@property (nonatomic, strong, readonly) UIView *progressContainerView;

/**
 * A placeholder view to display buffering indicator view.
 */
@property (nonatomic, strong, readonly) UIView *bufferingIndicatorContainerView;

/**
 * A view to receive user interaction.
 */
@property (nonatomic, strong, readonly) UIView *userInteractionContainerView;

/**
 * To control need automatic hide controlView when user touched.
 */
@property (nonatomic, assign, readonly) BOOL needAutoHideControlViewWhenUserTapping;


- (instancetype)initWithNeedAutoHideControlViewWhenUserTapping:(BOOL)needAutoHideControlViewWhenUserTapping;

@end
