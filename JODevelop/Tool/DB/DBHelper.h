//
//  DBHelper.h
//  JODevelop
//
//  Created by JimmyOu on 2018/4/23.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

/**
 数据哭管理工具
 */
@interface DBHelper : NSObject

@property (readonly) FMDatabaseQueue *dbQueue;

/**
 数据库单例
 */
+ (instancetype)shareHelper;

/**
 数据库文件沙盒地址
 */
+ (NSString *)dbPath;

@end
