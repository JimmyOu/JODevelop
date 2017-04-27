//
//  AXDCoolAnimator+MiddlePageFlip.h
//  JODevelop
//
//  Created by JimmyOu on 17/4/27.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "AXDCoolAnimator.h"

typedef NS_ENUM(NSUInteger, AXDMiddlePageFlipDirection) {
    AXDMiddlePageFlipDirectionLeft,
    AXDMiddlePageFlipDirectionRight,
    AXDMiddlePageFlipDirectionTop,
    AXDMiddlePageFlipDirectionBottom
};

@interface AXDCoolAnimator (MiddlePageFlip)

- (void)setMiddlePageFlipToAnimation:(id<UIViewControllerContextTransitioning>)transitionContext direction:(AXDMiddlePageFlipDirection)direction;

- (void)setMiddlePageFlipBackAnimation:(id<UIViewControllerContextTransitioning>)transitionContext direction:(AXDMiddlePageFlipDirection)direction;

@end
