//
//  NEMonitorFileManager.h
//  JODevelop
//
//  Created by JimmyOu on 2018/8/8.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMCallTraceTimeCostModel.h"
typedef NS_ENUM(NSUInteger, NEMonitorFileManagerType) {
    NEMonitorFileFluentType, //卡顿
    NEMonitorFileCrashType, //本应该crash的地方
    NEMonitorFileHighCPUType, //高CPU的地方
};


@interface NEMonitorFileManager : NSObject

+ (instancetype)shareInstance;

/**
 卡顿，crash等保存文件的父目录
 */
- (NSString *)monitorDir;

/**
 保存text到指定路径

 @param report text
 @param fileName 后缀名称
 @param type 类型
 */
- (void)saveReportToLocal:(NSString *)report withFileName:(NSString *)fileName type:(NEMonitorFileManagerType)type;
/*添加一条新的retainCycle*/
- (void)addNewRetainCycle:(NSString *)retainStr;
/*添加调用记录*/
- (void)addWithClsCallModel:(SMCallTraceTimeCostModel *)model;

/**
 添加剩下的models
 */
- (void)saveLastClsCallModels;
/*数据库读取*/
- (void)fetchCostModels:(void(^)(NSArray <SMCallTraceTimeCostModel *> *))block;

/**
 清空数据库
 */
+ (void)clearTraceDB:(void(^)(BOOL))block;
@end
