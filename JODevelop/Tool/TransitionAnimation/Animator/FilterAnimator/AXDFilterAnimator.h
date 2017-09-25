//
//  AXDFilterAnimator.h
//  JODevelop
//
//  Created by JimmyOu on 17/4/27.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//全都是基于不同的CIFilter产生的一些滤镜效果，在模拟器无法运行这些效果，请在真机上测试

#import "AXDBaseTransitionAnimator.h"
#import "AXDFilterTransitionView.h"

typedef NS_ENUM(NSUInteger, AXDFilterAnimatorType) {
    AXDFilterAnimatorTypeBoxBlur,//模糊转场,对应CIBoxBlur
    AXDFilterAnimatorTypeSwipe,//滑动过渡转场，对应CISwipeTranstion
    AXDFilterAnimatorTypeBarSwipe,//对应CIBarSwipeTranstion
    AXDFilterAnimatorTypeMask,//按指定遮罩图片转场，对应CIDisintegrateWithMaskTransition
    AXDFilterAnimatorTypeFlash,//闪烁转场，对应CIFlashTransition
    AXDFilterAnimatorTypeMod,//条纹转场 对应CIModTransition
    AXDFilterAnimatorTypePageCurl,//翻页转场 对应CIPageCurlWithShadowTransition
    AXDFilterAnimatorTypeRipple,//波纹转场，对应CIRippleTransition
    AXDFilterAnimatorTypeCopyMachine, //效果和AXDCoolAnimator中的Scanning效果类似，对应CICopyMachineTransition
};

@interface AXDFilterAnimator : AXDBaseTransitionAnimator

/**for AXDFilterAnimatorTypeMask，如果为空，则为默认的maskImg*/
@property (nonatomic, strong) UIImage *maskImg;
/**是否翻转，对于有转场有方向之分的此属性可用，如果为YES，如果to转场为左，那么back转场为右，默认为YES*/
@property (nonatomic, assign) BOOL revers;
/**开始角度，对于有转场方向的转场此属性可用，0为左，M_PI_2 为下 M_PI 为右 M_PI_2 * 3为上，也可指定任意开始角度*/
@property (nonatomic, assign) CGFloat startAngle;

/**
 *  初始化一个filter转场效果器
 *
 *  @param type 效果枚举值
 *
 *  @return 效果器
 */
+ (instancetype)animatorWithType:(AXDFilterAnimatorType)type;

@end
