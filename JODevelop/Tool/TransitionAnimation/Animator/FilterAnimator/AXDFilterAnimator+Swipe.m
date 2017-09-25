//
//  AXDFilterAnimator+Swipe.m
//  JODevelop
//
//  Created by JimmyOu on 17/4/27.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "AXDFilterAnimator+Swipe.h"

@implementation AXDFilterAnimator (Swipe)

- (void)swipeAnimationFor:(AXDFilterTransitionView *)filterView transitionContext:(id<UIViewControllerContextTransitioning>)transitionContext duration:(NSTimeInterval)duration toFlag:(BOOL)flag {
    CGFloat angle = self.revers && !flag ? self.startAngle + M_PI : self.startAngle;
    CIVector *vector = [filterView xw_getInnerVector];
    CIFilter *filter = [CIFilter filterWithName:@"CISwipeTransition"
                                  keysAndValues:
                        kCIInputExtentKey, vector,
                        kCIInputColorKey, [CIColor colorWithRed:0 green:0 blue:0 alpha:0],
                        kCIInputAngleKey, @(angle),
                        kCIInputWidthKey, @80.0,
                        @"inputOpacity", @0.0,
                        nil];
    filterView.filter = filter;
    [AXDFilterTransitionView animationWith:filterView duration:duration completion:^(BOOL finished) {
        [filterView removeFromSuperview];
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end
