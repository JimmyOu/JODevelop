//
//  AXDCoolAnimator.h
//  JODevelop
//
//  Created by JimmyOu on 17/4/27.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "AXDBaseTransitionAnimator.h"

typedef NS_ENUM(NSUInteger, AXDCoolTransitionAnimatorType){
    //全屏翻页
    AXDCoolTransitionAnimatorTypePageFlip,
    //中间翻页
    AXDCoolTransitionAnimatorTypePageMiddleFlipFromLeft,
    AXDCoolTransitionAnimatorTypePageMiddleFlipFromRight,
    AXDCoolTransitionAnimatorTypePageMiddleFlipFromTop,
    AXDCoolTransitionAnimatorTypePageMiddleFlipFromBottom,
    //开窗
    AXDCoolTransitionAnimatorTypePortal,
    //折叠
    AXDCoolTransitionAnimatorTypeFoldFromLeft,
    AXDCoolTransitionAnimatorTypeFoldFromRight,
    //爆炸
    AXDCoolTransitionAnimatorTypeExplode,
    //酷炫线条效果
    AXDCoolTransitionAnimatorTypeHorizontalLines,
    AXDCoolTransitionAnimatorTypeVerticalLines,
    //扫描效果
    AXDCoolTransitionAnimatorTypeScanningFromLeft,
    AXDCoolTransitionAnimatorTypeScanningFromRight,
    AXDCoolTransitionAnimatorTypeScanningFromTop,
    AXDCoolTransitionAnimatorTypeScanningFromBottom,
    
    
};

@interface AXDCoolAnimator : AXDBaseTransitionAnimator

//flod效果的折叠数量， for AXDCoolTransitionAnimatorTypeFoldFromLeft 和 AXDCoolTransitionAnimatorTypeFoldFromRight, 默认4
@property (nonatomic) NSUInteger foldCount;

+ (instancetype)animatorWithType:(AXDCoolTransitionAnimatorType)type;

@end
