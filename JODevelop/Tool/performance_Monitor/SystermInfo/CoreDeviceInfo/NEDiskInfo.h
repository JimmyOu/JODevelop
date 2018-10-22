//
//  NEDiskInfo.h
//  SnailReader
//
//  Created by JimmyOu on 2018/9/14.
//  Copyright © 2018年 com.netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NEDiskInfo : NSObject

// Disk Information

// Total Disk Space
+ (nullable NSString *)diskSpace;

// Total Free Disk Space
+ (nullable NSString *)freeDiskSpace:(BOOL)inPercent;

// Total Used Disk Space
+ (nullable NSString *)usedDiskSpace:(BOOL)inPercent;

// Get the total disk space in long format
+ (long long)longDiskSpace;

// Get the total free disk space in long format
+ (long long)longFreeDiskSpace;

@end
