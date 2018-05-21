//
//  JOConst.h
//  边下边播Demo
//
//  Created by JimmyOu on 2018/5/8.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import <Foundation/Foundation.h>


FOUNDATION_EXPORT NSString *const kJOPlayerFullScreenNotification;
FOUNDATION_EXPORT NSString *const kJOPlayerHalfScreenNotification;

#define kScreenHeight ([UIScreen mainScreen].bounds.size.height)
#define kScreenWidth ([UIScreen mainScreen].bounds.size.width)
#import "UIColor+Extension.h"

//播放器的几种状态
typedef NS_ENUM(NSInteger, JOPlayerState) {
    JOPlayerStateBuffering = 1,
    JOPlayerStatePlaying   = 2,
    JOPlayerStateStopped   = 3,
    JOPlayerStatePause     = 4
};
