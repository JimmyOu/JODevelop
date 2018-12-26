//
//  NEHTTPMonitor.h
//  SnailReader
//
//  Created by JimmyOu on 2018/8/17.
//  Copyright © 2018年 com.netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NEHTTPMonitor : NSObject
+ (instancetype)sharedInstance;
- (void)networkMonitor:(BOOL)enable;
//+ (BOOL)networkMonitorEnable;

@end
