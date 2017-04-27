//
//  AXDCoolAnimator+PageFlip.h
//  JODevelop
//
//  Created by JimmyOu on 17/4/27.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "AXDCoolAnimator.h"

@interface AXDCoolAnimator (PageFlip)

- (void)setPageFlipToAnimation:(id<UIViewControllerContextTransitioning>)transitionContext;

- (void)setPageFlipBackAnimation:(id<UIViewControllerContextTransitioning>)transitionContext;

@end
