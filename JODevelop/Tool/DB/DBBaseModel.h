//
//  DBBaseModel.h
//  JODevelop
//
//  Created by JimmyOu on 2018/4/23.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <objc/runtime.h> 

/** SQLite五种数据类型 */
#define SQLTEXT     @"TEXT"
#define SQLINTEGER  @"INTEGER"
#define SQLREAL     @"REAL"
#define SQLBLOB     @"BLOB"
#define SQLNULL     @"NULL"
#define PrimaryKey  @"primary key"

#define primaryId   @"pk"


/**
 数据库对象的父类
 */
@interface DBBaseModel : NSObject

/**
 primary key
 */
@property (assign, nonatomic) int pk;

/**
 查表的关键字段
 */
@property (nonatomic, copy) NSString *keyword;

/**
 列名
 */
@property (readonly) NSMutableArray *columnNames;

/**
 列类型
 */
@property (readonly) NSMutableArray *columnTypes;

#pragma -- mark fuctions

/**
 获取该类（模型）中所有属性 runtime
 */
+ (NSDictionary *)getPropertys;

/**
 获取所有的属性，包括主键
 */
+ (NSDictionary *)getAllProperties;

/**
 数据库中是否存在表
 */
+ (BOOL)isExistInTable;

/**
 表中的字段
 */
+ (NSArray *)getColumns;

/**
 保存或者更新
 如果不存在主键，保存
 如果有主键，更新
 */
- (BOOL)saveOrUpdate;

/**
 保存单个数据
 */
- (BOOL)save;

/**
 批量保存数据
 */
+ (BOOL)saveObjects:(NSArray *)array;

/**
 更新单个数据
 */
- (BOOL)update;

/**
 批量更新数据
 */
+ (BOOL)updateObjects:(NSArray *)array;

/**
 删除单个数据
 */
- (BOOL)deleteObject;

/**
 批量删除数据
 */
+ (BOOL)deleteObjects:(NSArray *)array;

/**
 清空表
 */
+ (BOOL)clearTable;

/**
 查询全部数据
 */
+ (NSArray *)findAll;

/*
 通过主键查询
 */
+ (instancetype)findByPK:(int)inPK;

/**
 查找某条数据
 */
+ (instancetype)findFirstByCriteria:(NSString *)criteria;

/**
  通过条件查找- 返回数据中的第一个
 */
+ (instancetype)findWhereColoum:(NSString *)coloum equleToValue:(NSString *)value;

/**
 通过条件查找数据
 这样可以进行分页查询 @"where pk > 5 limit 10"
 */
+ (NSArray *)findByCriteria:(NSString *)criteria;

/**
 创建表
 */
+ (BOOL)createTable;

/**
 数据是否存在
 */
- (BOOL)isExisitObj;

#pragma mark - must be override method
/**
 如果子类中有一些property不需要创建数据库字段，那么这个方法必须在字类中重写
 */
+ (NSArray *)transients;

@end


