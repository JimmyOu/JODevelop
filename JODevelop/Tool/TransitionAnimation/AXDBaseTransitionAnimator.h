//
//  AXDBaseTransitionAnimator.h
//  JODevelop
//
//  Created by JimmyOu on 17/4/27.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AXDTransitionConst.h"
#import "AXDInteractiveTransition.h"

@interface AXDBaseTransitionAnimator : NSObject<UIViewControllerTransitioningDelegate, UINavigationControllerDelegate, UITabBarControllerDelegate, AXDInteractiveTransitionDelegate>


//to转场时间 默认0.5
@property (nonatomic, assign) NSTimeInterval toDuration;
//back转场时间 默认0.5
@property (nonatomic, assign) NSTimeInterval backDuration;
//是否需要开启手势timer，某些转场如果在转成过程中所开手指，不会有动画过渡，显得很生硬，开启timer后，松开手指，会用timer不断的刷新转场百分比，消除生硬的缺点
@property (nonatomic, assign) BOOL needInteractiveTimer;

/**
 *  配置To过程动画(push, present),自定义转场动画应该复写该方法
 */
- (void)setToAnimation:(id<UIViewControllerContextTransitioning>)transitionContext fromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC fromView:(UIView *)fromView toView:(UIView *)toView;
/**
 *  配置back过程动画（pop, dismiss）,自定义转场动画应该复写该方法
 */
- (void)setBackAnimation:(id<UIViewControllerContextTransitioning>)transitionContext fromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC fromView:(UIView *)fromView toView:(UIView *)toView;

@end
