//
//  AXDFilterAnimator+CopyMachine.m
//  JODevelop
//
//  Created by JimmyOu on 17/4/27.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "AXDFilterAnimator+CopyMachine.h"

@implementation AXDFilterAnimator (CopyMachine)

- (void)copyMachineAnimationFor:(AXDFilterTransitionView *)filterView transitionContext:(id<UIViewControllerContextTransitioning>)transitionContext duration:(NSTimeInterval)duration toFlag:(BOOL)flag{
    CGFloat angle = self.revers && !flag ? self.startAngle + M_PI : self.startAngle;
    CIVector *vector = [filterView xw_getInnerVector];
    CIFilter *filter = [CIFilter filterWithName:@"CICopyMachineTransition"
                                  keysAndValues:
                        kCIInputExtentKey, vector,
                        kCIInputColorKey, [CIColor colorWithRed:.6 green:1 blue:.8 alpha:1],
                        kCIInputAngleKey, @(angle),
                        kCIInputWidthKey, @50.0,
                        @"inputOpacity", @1.0,
                        nil];
    filterView.filter = filter;
    [AXDFilterTransitionView animationWith:filterView duration:duration completion:^(BOOL finished) {
        [filterView removeFromSuperview];
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end
