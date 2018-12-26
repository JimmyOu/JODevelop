//
//  JOAppMonitor.h
//  JODevelop
//
//  Created by JimmyOu on 2018/8/6.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NEMonitorViewManager.h"
//#if defined(DEBUG)||defined(_DEBUG)
@interface NEAppMonitor : NSObject
@property (readonly, nullable) NEMonitorViewManager *viewManager;

/**
 开启普通检测
 */
@property (assign, nonatomic) BOOL enablePerformanceMonitor;

/**
 开启流畅检测
 */
@property (assign, nonatomic) BOOL enableFulencyMonitor;

/**
 网络检测
 */
@property (assign, nonatomic) BOOL enableNetworkMonitor;
/**
 开启崩溃
 */
@property (assign, nonatomic) BOOL enableVoidCrashOnLine;

/**
 开启方法追踪的时候，配置选项
 */
@property (assign, nonatomic) int depth; //深度 default = 1

+ (NEAppMonitor *_Nonnull)sharedInstance;

- (void)startMonitor;
- (void)endMonitor;

@end
//#endif
