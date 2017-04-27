//
//  AXDCoolAnimator+Scanning.h
//  JODevelop
//
//  Created by JimmyOu on 17/4/27.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "AXDCoolAnimator.h"

@interface AXDCoolAnimator (Scanning)

- (void)setScanningToAnimation:(id<UIViewControllerContextTransitioning>)transitionContext direction:(NSUInteger)direction;

- (void)setScanningBackAnimation:(id<UIViewControllerContextTransitioning>)transitionContext direction:(NSUInteger)direction;

@end
