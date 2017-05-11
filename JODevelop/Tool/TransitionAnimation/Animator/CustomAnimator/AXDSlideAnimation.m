//
//  AXDSlideAnimation.m
//  JODevelop
//
//  Created by JimmyOu on 17/5/4.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "AXDSlideAnimation.h"

@implementation AXDSlideAnimation


- (void)setToAnimation:(id<UIViewControllerContextTransitioning>)transitionContext fromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC fromView:(UIView *)fromView toView:(UIView *)toView {
    UIView *containerV = [transitionContext containerView];
    
    [containerV addSubview:toView];
    toView.frame = CGRectMake(kScreenWidth, 0, kScreenWidth, kScreenHeight);
    [UIView animateWithDuration:self.toDuration animations:^{
        toView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        fromView.frame = CGRectMake(-kScreenWidth, 0, kScreenWidth, kScreenHeight);
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
    
    
}

- (void)setBackAnimation:(id<UIViewControllerContextTransitioning>)transitionContext fromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC fromView:(UIView *)fromView toView:(UIView *)toView {
    
    UIView *containerV = [transitionContext containerView];
    [containerV addSubview:toView];
    toView.frame = CGRectMake(-kScreenWidth, 0, kScreenWidth, kScreenHeight);
    
    [UIView animateWithDuration:self.toDuration animations:^{
        toView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        fromView.frame = CGRectMake(kScreenWidth, 0, kScreenWidth, kScreenHeight);
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
    
}

@end
