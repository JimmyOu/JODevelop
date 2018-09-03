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

@end
