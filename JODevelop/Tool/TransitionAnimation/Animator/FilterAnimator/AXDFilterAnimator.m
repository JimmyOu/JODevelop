//
//  AXDFilterAnimator.m
//  JODevelop
//
//  Created by JimmyOu on 17/4/27.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "AXDFilterAnimator.h"
#import "AXDFilterAnimator+BarSwipe.h"
#import "AXDFilterAnimator+BoxBlur.h"
#import "AXDFilterAnimator+CopyMachine.h"
#import "AXDFilterAnimator+Flash.h"
#import "AXDFilterAnimator+Mask.h"
#import "AXDFilterAnimator+Mod.h"
#import "AXDFilterAnimator+PageCurl.h"
#import "AXDFilterAnimator+Ripple.h"
#import "AXDFilterAnimator+Swipe.h"

@implementation AXDFilterAnimator{
    UIView *_containerView;
    AXDFilterAnimatorType _type;
}

+ (instancetype)animatorWithType:(AXDFilterAnimatorType)type {
    return[[self alloc] _initWithType:type];
}

- (instancetype)_initWithType:(AXDFilterAnimatorType)type{
    self = [super init];
    if (self) {
        _type = type;
        self.needInteractiveTimer = YES;
        _revers = YES;
    }
    return self;
}

- (void)setToAnimation:(id<UIViewControllerContextTransitioning>)transitionContext fromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC fromView:(UIView *)fromView toView:(UIView *)toView {
    
    UIView *containerView = [transitionContext containerView];
    _containerView = containerView;
    [containerView addSubview:toVC.view];
    AXDFilterTransitionView *filterView = [[AXDFilterTransitionView alloc] initWithFrame:containerView.bounds fromImage:[self p_ImageFromsnapshotView:fromVC.view] toImage:[self p_ImageFromsnapshotView:toVC.view]];
    switch (_type) {
        case AXDFilterAnimatorTypeBoxBlur: {
            [self boxBlurAnimationFor:filterView transitionContext:transitionContext duration:self.toDuration];
            break;
        }
        case AXDFilterAnimatorTypeSwipe: {
            [self swipeAnimationFor:filterView transitionContext:transitionContext duration:self.toDuration toFlag:YES];
            break;
        }
        case AXDFilterAnimatorTypeBarSwipe:{
            [self barSwipeAnimationFor:filterView transitionContext:transitionContext duration:self.toDuration toFlag:YES];
            break;
        }
        case AXDFilterAnimatorTypeMask:{
            [self maskAnimationFor:filterView transitionContext:transitionContext duration:self.toDuration];
            break;
        }
        case AXDFilterAnimatorTypeFlash:{
            [self flashAnimationFor:filterView transitionContext:transitionContext duration:self.toDuration];
            break;
        }
        case AXDFilterAnimatorTypeMod:{
            [self modAnimationFor:filterView transitionContext:transitionContext duration:self.toDuration toFlag:YES];
            break;
        }
        case AXDFilterAnimatorTypePageCurl:{
            [self pageCurlAnimationFor:filterView transitionContext:transitionContext duration:self.toDuration toFlag:YES];
            break;
        }
        case AXDFilterAnimatorTypeRipple:{
            [self rippleAnimationFor:filterView transitionContext:transitionContext duration:self.toDuration];
            break;
        }
        case AXDFilterAnimatorTypeCopyMachine:{
            [self copyMachineAnimationFor:filterView transitionContext:transitionContext duration:self.toDuration toFlag:YES];
            break;
        }
    }
    [containerView addSubview:filterView];

}

- (void)setBackAnimation:(id<UIViewControllerContextTransitioning>)transitionContext fromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC fromView:(UIView *)fromView toView:(UIView *)toView {
    UIView *containerView = [transitionContext containerView];
    [containerView insertSubview:toVC.view atIndex:0];
    _containerView = containerView;
    AXDFilterTransitionView *filterView = [[AXDFilterTransitionView alloc] initWithFrame:containerView.bounds fromImage:[self p_ImageFromsnapshotView:fromVC.view] toImage:[self p_ImageFromsnapshotView:toVC.view]];
    switch (_type) {
        case AXDFilterAnimatorTypeBoxBlur: {
            [self boxBlurAnimationFor:filterView transitionContext:transitionContext duration:self.backDuration];
            break;
        }
        case AXDFilterAnimatorTypeSwipe: {
            [self swipeAnimationFor:filterView transitionContext:transitionContext duration:self.backDuration toFlag:NO];
            break;
        }
        case AXDFilterAnimatorTypeBarSwipe:{
            [self barSwipeAnimationFor:filterView transitionContext:transitionContext duration:self.backDuration toFlag:NO];
            break;
        }
        case AXDFilterAnimatorTypeMask:{
            [self maskAnimationFor:filterView transitionContext:transitionContext duration:self.backDuration];
            break;
        }
        case AXDFilterAnimatorTypeFlash:{
            [self flashAnimationFor:filterView transitionContext:transitionContext duration:self.backDuration];
            break;
        }
        case AXDFilterAnimatorTypeMod:{
            [self modAnimationFor:filterView transitionContext:transitionContext duration:self.backDuration toFlag:NO];
            break;
        }
        case AXDFilterAnimatorTypePageCurl:{
            [self pageCurlAnimationFor:filterView transitionContext:transitionContext duration:self.backDuration toFlag:NO];
            break;
        }
        case AXDFilterAnimatorTypeRipple:{
            [self rippleAnimationFor:filterView transitionContext:transitionContext duration:self.backDuration];
            break;
        }
        case AXDFilterAnimatorTypeCopyMachine:{
            [self copyMachineAnimationFor:filterView transitionContext:transitionContext duration:self.backDuration toFlag:NO];
            break;
        }
    }
    [containerView addSubview:filterView];

}

- (UIImage *)p_ImageFromsnapshotView:(UIView *)view{
    CALayer *layer = view.layer;
    UIGraphicsBeginImageContextWithOptions(layer.bounds.size, layer.opaque, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)interactiveTransitionWillBeginTimerAnimation:(AXDInteractiveTransition *)interactiveTransition{
    _containerView.userInteractionEnabled = NO;
}

- (void)interactiveTransition:(AXDInteractiveTransition *)interactiveTransition willEndWithSuccessFlag:(BOOL)flag percent:(CGFloat)percent{
    _containerView.userInteractionEnabled = YES;
}



@end
