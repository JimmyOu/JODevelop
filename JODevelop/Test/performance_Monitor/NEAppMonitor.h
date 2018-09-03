//
//  JOAppMonitor.h
//  JODevelop
//
//  Created by JimmyOu on 2018/8/6.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NEMonitorViewManager.h"

@interface NEAppMonitor : NSObject
@property (readonly, nullable) NEMonitorViewManager *viewManager;
@property (assign, nonatomic) BOOL enableMonitor;
@property (assign, nonatomic) BOOL enableFulencyMonitor;
@property (assign, nonatomic) BOOL showDebugView;

+ (NEAppMonitor *)sharedInstance;

- (void)startMonitor;
- (void)pause;
- (void)resnume;
- (void)endMonitor;

@end
