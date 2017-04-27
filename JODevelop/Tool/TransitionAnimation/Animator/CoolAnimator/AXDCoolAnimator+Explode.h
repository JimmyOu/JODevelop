//
//  AXDCoolAnimator+Explode.h
//  JODevelop
//
//  Created by JimmyOu on 17/4/27.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "AXDCoolAnimator.h"

@interface AXDCoolAnimator (Explode)

- (void)setExplodeToAnimation:(id<UIViewControllerContextTransitioning>)transitionContext;

- (void)setExplodeBackAnimation:(id<UIViewControllerContextTransitioning>)transitionContext;

@end
