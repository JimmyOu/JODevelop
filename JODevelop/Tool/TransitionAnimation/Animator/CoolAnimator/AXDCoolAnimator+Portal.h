//
//  AXDCoolAnimator+Portal.h
//  JODevelop
//
//  Created by JimmyOu on 17/4/27.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "AXDCoolAnimator.h"

@interface AXDCoolAnimator (Portal)

- (void)setPortalToAnimation:(id<UIViewControllerContextTransitioning>)transitionContext;

- (void)setPortalBackAnimation:(id<UIViewControllerContextTransitioning>)transitionContext;

@end
