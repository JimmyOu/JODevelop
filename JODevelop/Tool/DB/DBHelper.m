//
//  DBHelper.m
//  JODevelop
//
//  Created by JimmyOu on 2018/4/23.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "DBHelper.h"

@interface DBHelper()
@property (strong, nonatomic) FMDatabaseQueue *dbQueue;
@end
@implementation DBHelper

+(instancetype)shareHelper{
    static DBHelper *instance = nil;
    static dispatch_once_t onceToken;
    if (!instance) {
        dispatch_once(&onceToken, ^{
            instance = [[super allocWithZone:nil] init];
        });
    }
    return instance;
}

- (FMDatabaseQueue *)dbQueue {
    if (!_dbQueue) {
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:[[self class] dbPath]];
    }
    return _dbQueue;
}
+ (NSString *)dbPath {
    NSString *docsdir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    docsdir = [docsdir stringByAppendingPathComponent:@"AppDataBase"];
    BOOL isDir;
    BOOL exit = [fileManager fileExistsAtPath:docsdir isDirectory:&isDir];
    if (!exit || !isDir) {
        [fileManager createDirectoryAtPath:docsdir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *dbPath = [docsdir stringByAppendingPathComponent:@"TierTime.sqlite"];
    return dbPath;
}

#pragma --mark 保证单例不会被创建成新对象
+(instancetype)alloc{
    NSAssert(0, @"这是一个单例对象，请使用+(DBHelper *)sharedHelper方法");
    return nil;
}
+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [DBHelper shareHelper];
}

- (id)copyWithZone:(struct _NSZone *)zone
{
    return [DBHelper shareHelper];
}

@end
