//
//  AXDFilterAnimator+PageCurl.m
//  JODevelop
//
//  Created by JimmyOu on 17/4/27.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "AXDFilterAnimator+PageCurl.h"

@implementation AXDFilterAnimator (PageCurl)

- (void)pageCurlAnimationFor:(AXDFilterTransitionView *)filterView transitionContext:(id<UIViewControllerContextTransitioning>)transitionContext duration:(NSTimeInterval)duration toFlag:(BOOL)flag{
    CGFloat angle = self.revers && !flag ? self.startAngle + M_PI : self.startAngle;
    CIFilter *filter = [CIFilter filterWithName: @"CIPageCurlWithShadowTransition"
                                  keysAndValues:
                        kCIInputAngleKey, @(angle),
                        nil];
    filterView.filter = filter;
    [AXDFilterTransitionView animationWith:filterView duration:duration completion:^(BOOL finished) {
        [filterView removeFromSuperview];
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end
