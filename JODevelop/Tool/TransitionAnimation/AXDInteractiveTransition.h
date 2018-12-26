//
//  AXDInteractiveTransition.h
//  JODevelop
//
//  Created by JimmyOu on 17/4/27.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//  手势转场管理者

#import <Foundation/Foundation.h>
#import "AXDTransitionConst.h"
#import <UIKit/UIKit.h>
@protocol AXDInteractiveTransitionDelegate;

@interface AXDInteractiveTransition : UIPercentDrivenInteractiveTransition

@property (nonatomic, assign, readonly) BOOL interation;
@property (nonatomic, assign) BOOL timerEnable; //手势取消是否开启动画回到初始状态，default :yes
@property (nonatomic, weak) id<AXDInteractiveTransitionDelegate> delegate;
@property (nonatomic, assign) CGFloat panValue; //手势的位移区域,default:200

+ (instancetype)interactiveTransitionWithDirection:(AXDInteractiveTransitionGestureDirection)direction config:(void(^)(CGPoint startPoint))config edgeSpacing:(CGFloat)edgeSpacing;

- (void)addPanGestureForView:(UIView *)view;

@end

/**手势转场时的代理事件，animator默认为为其手势的代理，复写对应的代理事件可处理一些手势失败闪烁的情况*/
@protocol AXDInteractiveTransitionDelegate <NSObject>

@optional
/**手势转场即将开始时调用*/
- (void)interactiveTransitionWillBegin:(AXDInteractiveTransition *)interactiveTransition;
/**手势转场中调用*/
- (void)interactiveTransition:(AXDInteractiveTransition *)interactiveTransition isUpdating:(CGFloat)percent;
/**如果开始了转场手势timer，会在松开手指，timer开始的时候调用*/
- (void)interactiveTransitionWillBeginTimerAnimation:(AXDInteractiveTransition *)interactiveTransition;
/**手势转场结束的时候调用*/
- (void)interactiveTransition:(AXDInteractiveTransition *)interactiveTransition willEndWithSuccessFlag:(BOOL)flag percent:(CGFloat)percent;

@end
