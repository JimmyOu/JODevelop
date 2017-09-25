//
//  UINavigationController+AXDTransition.h
//  JODevelop
//
//  Created by JimmyOu on 17/4/27.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AXDBaseTransitionAnimator;
@interface UINavigationController (AXDTransition)

/**
 *  通过指定的转场animator来push控制器，达到不同的转场效果
 *
 *  @param viewController 被push的控制器
 *  @param animator       转场Animator
 */
- (void)axd_pushViewController:(UIViewController *)viewController withAnimator:(AXDBaseTransitionAnimator *)animator;

@end
