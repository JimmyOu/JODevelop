//
//  AXDFilterAnimator+CopyMachine.h
//  JODevelop
//
//  Created by JimmyOu on 17/4/27.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "AXDFilterAnimator.h"

@interface AXDFilterAnimator (CopyMachine)

- (void)copyMachineAnimationFor:(AXDFilterTransitionView *)filterView transitionContext:(id<UIViewControllerContextTransitioning>)transitionContext duration:(NSTimeInterval)duration toFlag:(BOOL)flag;

@end
