//
//  NEMonitorDataCenter.m
//  JODevelop
//
//  Created by JimmyOu on 2018/8/7.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "NEMonitorDataCenter.h"

@implementation NEMonitorDataCenter

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static NEMonitorDataCenter *center;
    dispatch_once(&onceToken, ^{
        center = [[NEMonitorDataCenter alloc] init];
    });
    return center;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        _battery = [[NEAppGraphicModel alloc] init];
        _battery.title = @"battery";
        
        _cpu = [[NEAppGraphicModel alloc] init];
        _cpu.title = @"cpu";
        
        _memory = [[NEAppGraphicModel alloc] init];
        _memory.title = @"memory";
    }
    return self;
}

@end
