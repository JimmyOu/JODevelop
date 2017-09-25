//
//  AXDFilterAnimator+Ripple.m
//  JODevelop
//
//  Created by JimmyOu on 17/4/27.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "AXDFilterAnimator+Ripple.h"

@implementation AXDFilterAnimator (Ripple)

- (void)rippleAnimationFor:(AXDFilterTransitionView *)filterView transitionContext:(id<UIViewControllerContextTransitioning>)transitionContext duration:(NSTimeInterval)duration{
    CIImage *img = [CIImage imageWithCGImage:[UIImage imageNamed:@"restrictedshine.tiff"].CGImage];
    CIVector *vector = [filterView xw_getInnerVector];
    CIFilter *filter = [CIFilter filterWithName: @"CIRippleTransition"
                                  keysAndValues:
                        kCIInputShadingImageKey, img,
                        kCIInputCenterKey, [CIVector vectorWithX:0.5 * vector.CGRectValue.size.width
                                                               Y:0.5 * vector.CGRectValue.size.height],
                        nil];
    filterView.filter = filter;
    [AXDFilterTransitionView animationWith:filterView duration:duration completion:^(BOOL finished) {
        [filterView removeFromSuperview];
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end
