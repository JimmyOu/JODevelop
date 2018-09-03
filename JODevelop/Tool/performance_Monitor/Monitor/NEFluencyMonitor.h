//
//  NEFluencyMonitor.h
//  JODevelop
//
//  Created by JimmyOu on 2018/8/8.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NEFluencyMonitor : NSObject

+ (instancetype)sharedInstance;

/**
 *  开启监听
 */
- (void)startMonitoring;

/**
 *  关闭监听
 */
- (void)stopMonitoring;

@end
