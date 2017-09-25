//
//  AXDFilterAnimator+Mask.m
//  JODevelop
//
//  Created by JimmyOu on 17/4/27.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "AXDFilterAnimator+Mask.h"

@implementation AXDFilterAnimator (Mask)

- (void)maskAnimationFor:(AXDFilterTransitionView *)filterView transitionContext:(id<UIViewControllerContextTransitioning>)transitionContext duration:(NSTimeInterval)duration {
    CGFloat height = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.frame.size.height;
    CIImage *maskImg = self.maskImg ? [CIImage imageWithCGImage:self.maskImg.CGImage] : [CIImage imageWithCGImage:[UIImage imageNamed:@"mask.jpg"].CGImage];
    CIFilter *filter = [CIFilter filterWithName: @"CIDisintegrateWithMaskTransition"
                                  keysAndValues:
                        kCIInputMaskImageKey, maskImg,
                        @"inputShadowRadius", @10.0,
                        @"inputShadowDensity", @0.7,
                        @"inputShadowOffset", [CIVector vectorWithX:0.0  Y:-0.05 * height],
                        nil];
    filterView.filter = filter;
    [AXDFilterTransitionView animationWith:filterView duration:duration completion:^(BOOL finished) {
        [filterView removeFromSuperview];
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end
