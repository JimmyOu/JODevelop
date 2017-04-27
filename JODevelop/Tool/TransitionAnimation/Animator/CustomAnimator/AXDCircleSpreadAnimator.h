//
//  AXDCircleSpreadAnimator.h
//  JODevelop
//
//  Created by JimmyOu on 17/4/27.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "AXDBaseTransitionAnimator.h"

@interface AXDCircleSpreadAnimator : AXDBaseTransitionAnimator

/**
 *  返回一个小圆点扩散转场效果器
 *
 *  @param point  扩散开始中心
 *  @param radius 扩散开始的半径
 *
 *  @return 小圆点扩散转场效果器
 */
+ (instancetype)animatorWithStartCenter:(CGPoint)point radius:(CGFloat)radius;

@end
