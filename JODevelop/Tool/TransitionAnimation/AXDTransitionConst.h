//
//  AXDTransitionConst.h
//  JODevelop
//
//  Created by JimmyOu on 17/4/27.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**手势转场方向*/
typedef NS_ENUM(NSUInteger, AXDInteractiveTransitionGestureDirection) {
    AXDInteractiveTransitionGestureDirectionLeft = 0,
    AXDInteractiveTransitionGestureDirectionRight,
    AXDInteractiveTransitionGestureDirectionUp,
    AXDInteractiveTransitionGestureDirectionDown
};

// 常量
UIKIT_EXTERN const CGFloat kAXDTransitionAnimationTimeDuration;
UIKIT_EXTERN const CGFloat kAXDTransitionPanValue;


