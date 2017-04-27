//
//  AXDCoolAnimator+Fold.h
//  JODevelop
//
//  Created by JimmyOu on 17/4/27.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "AXDCoolAnimator.h"

@interface AXDCoolAnimator (Fold)

- (void)setFoldToAnimation:(id<UIViewControllerContextTransitioning>)transitionContext leftFlag:(BOOL)left;

- (void)setFoldBackAnimation:(id<UIViewControllerContextTransitioning>)transitionContext leftFlag:(BOOL)left;

@end
