//
//  NEHardware.h
//  SnailReader
//
//  Created by JimmyOu on 2018/9/11.
//  Copyright © 2018年 com.netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NEHardware : NSObject

/**
 系统上一次开机的累计时间
 */
+ (nullable NSString *)systemUptime;

/**
 设备名称
 */
+ (nullable NSString *)deviceName;

/**
 系统名称
 */
+ (nullable NSString *)systemName;

/**
 系统版本号
 */
+ (nullable NSString *)systemVersion;
/*
 设备类型
 */
+ (nullable NSString *)systemDeviceType;

/*
 屏幕宽度
 */
+ (NSInteger)screenWidth;

/*
 屏幕高度
 */
+ (NSInteger)screenHeight;

/**
 屏幕亮度
 */
+ (float)screenBrightness;

/**
 是否在debug 状态
 */
+ (BOOL)debugger;




@end
