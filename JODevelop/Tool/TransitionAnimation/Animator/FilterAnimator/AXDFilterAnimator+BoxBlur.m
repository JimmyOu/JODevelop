//
//  AXDFilterAnimator+BoxBlur.m
//  JODevelop
//
//  Created by JimmyOu on 17/4/27.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "AXDFilterAnimator+BoxBlur.h"

@implementation AXDFilterAnimator (BoxBlur)

- (void)boxBlurAnimationFor:(AXDFilterTransitionView *)filterView transitionContext:(id<UIViewControllerContextTransitioning>)transitionContext duration:(NSTimeInterval)duration {
    CIFilter *filter = [CIFilter filterWithName: @"CIBoxBlur"];
    filterView.filter = filter;
    filterView.blurType = YES;
    [AXDFilterTransitionView animationWith:filterView duration:duration completion:^(BOOL finished) {
        [filterView removeFromSuperview];
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        
    }];
}

@end
