//
//  AXDCoolAnimator+Lines.h
//  JODevelop
//
//  Created by JimmyOu on 17/4/27.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "AXDCoolAnimator.h"

@interface AXDCoolAnimator (Lines)

- (void)setLinesToAnimation:(id<UIViewControllerContextTransitioning>)transitionContext vertical:(BOOL)vertical;

- (void)setLinesBackAnimation:(id<UIViewControllerContextTransitioning>)transitionContext vertical:(BOOL)vertical;

@end
