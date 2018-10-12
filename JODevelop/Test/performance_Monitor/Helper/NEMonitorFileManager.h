//
//  NEMonitorFileManager.h
//  JODevelop
//
//  Created by JimmyOu on 2018/8/8.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSUInteger, NEMonitorFileManagerType) {
    NEMonitorFileFluentType, //卡顿
    NEMonitorFileCrashType, //本应该crash的地方
};


@interface NEMonitorFileManager : NSObject

+ (instancetype)shareInstance;
- (NSString *)monitorDir;
- (void)saveReportToLocal:(NSString *)report withFileName:(NSString *)fileName type:(NEMonitorFileManagerType)type;
- (void)addNewRetainCycle:(NSString *)retainStr;
@end
