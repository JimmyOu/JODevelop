//
//  AXDFilterAnimator+Mod.m
//  JODevelop
//
//  Created by JimmyOu on 17/4/27.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "AXDFilterAnimator+Mod.h"

@implementation AXDFilterAnimator (Mod)

- (void)modAnimationFor:(AXDFilterTransitionView *)filterView transitionContext:(id<UIViewControllerContextTransitioning>)transitionContext duration:(NSTimeInterval)duration toFlag:(BOOL)flag{
    CGFloat angle = self.revers && !flag ? self.startAngle + M_PI : self.startAngle;
    CIVector *vector = [filterView xw_getInnerVector];
    CIFilter *filter = [CIFilter filterWithName: @"CIModTransition"
                                  keysAndValues:
                        kCIInputCenterKey,[CIVector vectorWithX:0.5 * vector.CGRectValue.size.width
                                                              Y:0.5 * vector.CGRectValue.size.height],
                        kCIInputAngleKey, @(angle),
                        kCIInputRadiusKey, @30.0,
                        @"inputCompression", @10.0,
                        nil];
    filterView.filter = filter;
    [AXDFilterTransitionView animationWith:filterView duration:duration completion:^(BOOL finished) {
        [filterView removeFromSuperview];
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end
