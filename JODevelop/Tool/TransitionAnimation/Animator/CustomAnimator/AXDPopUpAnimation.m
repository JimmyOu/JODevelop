//
//  AXDPopUpAnimation.m
//  JODevelop
//
//  Created by JimmyOu on 17/4/27.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "AXDPopUpAnimation.h"

@interface AXDPopUpAnimation ()

@property (nonatomic, weak) UIView *shadowV;

@end

@implementation AXDPopUpAnimation

- (void)setToAnimation:(id<UIViewControllerContextTransitioning>)transitionContext fromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC fromView:(UIView *)fromView toView:(UIView *)toView {
    UIView *containerV = [transitionContext containerView];
    
    UIView *shadow = [[UIView alloc] initWithFrame:containerV.bounds];
    shadow.backgroundColor =  [UIColor colorWithRed:(float)(84/255.f)
                                              green:(float)(84/255.f)
                                               blue:(float)(84/255.f)
                                              alpha:1.f];
    shadow.alpha = 0.0;
    _shadowV = shadow;
    

    [containerV addSubview:shadow];
    [containerV addSubview:toView];
    toView.frame = CGRectMake(0, containerV.bounds.size.height, containerV.bounds.size.width, containerV.bounds.size.height - 200);
    
    [UIView animateWithDuration:self.toDuration animations:^{
        _shadowV.alpha = 0.2;
        toView.frame = CGRectMake(0, 200, containerV.bounds.size.width, containerV.bounds.size.height - 200);
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
    
    
}

- (void)setBackAnimation:(id<UIViewControllerContextTransitioning>)transitionContext fromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC fromView:(UIView *)fromView toView:(UIView *)toView {
    
    UIView *containerV = [transitionContext containerView];
    
    [UIView animateWithDuration:self.toDuration animations:^{
        _shadowV.alpha = 0;
        fromView.frame = CGRectMake(0, containerV.bounds.size.height, containerV.bounds.size.width, containerV.bounds.size.height - 200);
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        [_shadowV removeFromSuperview];
    }];

}

@end
