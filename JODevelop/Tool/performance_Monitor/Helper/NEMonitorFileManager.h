//
//  NEMonitorFileManager.h
//  JODevelop
//
//  Created by JimmyOu on 2018/8/8.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NEMonitorFileManager : NSObject

+ (instancetype)shareInstance;
- (NSString *)monitorDir;
- (void)saveReportToLocal:(NSString *)report withFileName:(NSString *)fileName;
@end
