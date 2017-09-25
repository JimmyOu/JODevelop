//
//  AXDSlideAnimation.m
//  JODevelop
//
//  Created by JimmyOu on 17/5/4.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "AXDSlideAnimation.h"

@interface AXDSlideAnimation ()<CAAnimationDelegate>

@end
@implementation AXDSlideAnimation

/*
 
 UIView *containerV = [transitionContext containerView];
 [containerV addSubview:toView];
 toView.frame = CGRectMake(kScreenWidth, 0, kScreenWidth, kScreenHeight);
 UIView *shadow = [[UIView alloc] initWithFrame:fromView.bounds];
 shadow.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
 [fromView addSubview:shadow];
 
 
 toView.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1].CGColor;
 toView.layer.shadowOffset = CGSizeMake(-2, 0);
 toView.layer.shadowOpacity = 1;
 
 CABasicAnimation *shadowAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
 shadowAnimation.removedOnCompletion = YES;
 shadowAnimation.fromValue = @(0);
 shadowAnimation.toValue = @(1);
 shadowAnimation.duration = self.toDuration;
 shadowAnimation.delegate = self;
 [toView.layer addAnimation:shadowAnimation forKey:@"shadowAnimation"];
 
 
 
 [UIView animateWithDuration:self.toDuration animations:^{
 toView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
 fromView.frame = CGRectMake(-kScreenWidth * 1/3, 0, kScreenWidth, kScreenHeight);
 shadow.alpha = 0.1;
 } completion:^(BOOL finished) {
 [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
 [shadow removeFromSuperview];
 }];


 
 
 */
- (void)setToAnimation:(id<UIViewControllerContextTransitioning>)transitionContext fromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC fromView:(UIView *)fromView toView:(UIView *)toView {
    UIView *containerV = [transitionContext containerView];
    [containerV addSubview:toView];
    toView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, kScreenHeight);
    UIView *shadow = [[UIView alloc] initWithFrame:fromView.bounds];
    shadow.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    [fromView addSubview:shadow];
    
    
    toView.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1].CGColor;
    toView.layer.shadowOffset = CGSizeMake(-2, 0);
    toView.layer.shadowOpacity = 1;
    
    CABasicAnimation *shadowAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
    shadowAnimation.removedOnCompletion = YES;
    shadowAnimation.fromValue = @(0);
    shadowAnimation.toValue = @(1);
    shadowAnimation.duration = self.toDuration;
    shadowAnimation.delegate = self;
    [toView.layer addAnimation:shadowAnimation forKey:@"shadowAnimation"];
    
    
    
    [UIView animateWithDuration:self.toDuration animations:^{
        toView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        fromView.frame = CGRectMake(0, kScreenHeight * -1/3, kScreenWidth, kScreenHeight);
        shadow.alpha = 0.1;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        [shadow removeFromSuperview];
    }];
    
    
}

/*
 UIView *containerV = [transitionContext containerView];
 [containerV insertSubview:toView atIndex:0];
 toView.frame = CGRectMake(-kScreenWidth * 1/3, 0, kScreenWidth, kScreenHeight);
 UIView *shadow = [[UIView alloc] initWithFrame:toView.bounds];
 shadow.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
 [toView addSubview:shadow];
 
 fromView.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1].CGColor;
 fromView.layer.shadowOffset = CGSizeMake(-2, 0);
 fromView.layer.shadowOpacity = 0;
 
 CABasicAnimation *shadowAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
 shadowAnimation.removedOnCompletion = YES;
 shadowAnimation.fromValue = @(1);
 shadowAnimation.toValue = @(0);
 shadowAnimation.duration = self.toDuration;
 shadowAnimation.delegate = self;
 [fromView.layer addAnimation:shadowAnimation forKey:@"shadowAnimation"];
 
 
 [UIView animateWithDuration:self.toDuration animations:^{
 toView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
 fromView.frame = CGRectMake(kScreenWidth, 0, kScreenWidth, kScreenHeight);
 shadow.alpha = 0;
 } completion:^(BOOL finished) {
 [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
 [shadow removeFromSuperview];
 
 }];
 
 */
- (void)setBackAnimation:(id<UIViewControllerContextTransitioning>)transitionContext fromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC fromView:(UIView *)fromView toView:(UIView *)toView {
    
    UIView *containerV = [transitionContext containerView];
    [containerV insertSubview:toView atIndex:0];
    toView.frame = CGRectMake(0, kScreenHeight * -1/3, kScreenWidth, kScreenHeight);
    UIView *shadow = [[UIView alloc] initWithFrame:toView.bounds];
    shadow.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
    [toView addSubview:shadow];
    
    fromView.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1].CGColor;
    fromView.layer.shadowOffset = CGSizeMake(-2, 0);
    fromView.layer.shadowOpacity = 0;
    
    CABasicAnimation *shadowAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
    shadowAnimation.removedOnCompletion = YES;
    shadowAnimation.fromValue = @(1);
    shadowAnimation.toValue = @(0);
    shadowAnimation.duration = self.toDuration;
    shadowAnimation.delegate = self;
    [fromView.layer addAnimation:shadowAnimation forKey:@"shadowAnimation"];
    
    
    [UIView animateWithDuration:self.toDuration animations:^{
        toView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        fromView.frame = CGRectMake(0 , kScreenHeight, kScreenWidth, kScreenHeight);
        shadow.alpha = 0;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        [shadow removeFromSuperview];

    }];
    
}

@end
