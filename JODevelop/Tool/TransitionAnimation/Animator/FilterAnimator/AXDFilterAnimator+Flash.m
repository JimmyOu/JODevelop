//
//  AXDFilterAnimator+Flash.m
//  JODevelop
//
//  Created by JimmyOu on 17/4/27.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "AXDFilterAnimator+Flash.h"

@implementation AXDFilterAnimator (Flash)
- (void)flashAnimationFor:(AXDFilterTransitionView *)filterView transitionContext:(id<UIViewControllerContextTransitioning>)transitionContext duration:(NSTimeInterval)duration{
    CGSize size = filterView.frame.size;
    CIFilter *filter = [CIFilter filterWithName:@"CIFlashTransition"
                                  keysAndValues:
                        kCIInputCenterKey, [CIVector vectorWithCGPoint:CGPointMake(size.width, size.height)],
                        kCIInputColorKey, [CIColor colorWithRed:1.0 green:0.8 blue:0.6 alpha:1],
                        @"inputMaxStriationRadius", @2.5,
                        @"inputStriationStrength", @0.5,
                        @"inputStriationContrast", @1.37,
                        @"inputFadeThreshold", @0.5,
                        nil];
    filterView.filter = filter;
    [AXDFilterTransitionView animationWith:filterView duration:duration completion:^(BOOL finished) {
        [filterView removeFromSuperview];
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end
