//
//  DBBaseModel.m
//  JODevelop
//
//  Created by JimmyOu on 2018/4/23.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "DBBaseModel.h"
#import "DBHelper.h"
#define dbTimeCount @"recent_time"
@implementation DBBaseModel

+ (void)initialize
{
    if (self != [DBBaseModel class]) { //表示子类
        [self createTable];
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSDictionary *dic = [self.class getAllProperties];
        _columnNames = [[NSMutableArray alloc] initWithArray:[dic objectForKey:@"name"]];
        _columnTypes = [[NSMutableArray alloc] initWithArray:[dic objectForKey:@"type"]];
    }
    return self;
}
#pragma base method
+ (NSDictionary *)getPropertys {
    NSMutableArray *proNames = [NSMutableArray array];
    NSMutableArray *proTypes = [NSMutableArray array];
    NSArray *theTransients = [[self class] transients];
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (int i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        //获取属性名
        NSString *properName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        if ([theTransients containsObject:properName]) {
            continue;
        }
        [proNames addObject:properName];
        //获取属性类型等参数
        NSString *propertyType = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
        /*
         c char         C unsigned char
         i int          I unsigned int
         l long         L unsigned long
         s short        S unsigned short
         d double       D unsigned double
         f float        F unsigned float
         q long long    Q unsigned long long
         B BOOL
         @ 对象类型 //指针 对象类型 如NSString 是@"NSString"
         
         
         64位下long 和long long 都是Tq
         SQLite 默认支持五种数据类型TEXT、INTEGER、REAL、BLOB、NULL
         */
        if ([propertyType hasPrefix:@"T@"]) {
            [proTypes addObject:SQLTEXT];
        } else if ([propertyType hasPrefix:@"Ti"]||[propertyType hasPrefix:@"TI"]||[propertyType hasPrefix:@"Ts"]||[propertyType hasPrefix:@"TS"]||[propertyType hasPrefix:@"TB"]) {
            [proTypes addObject:SQLINTEGER];
        } else {
            [proTypes addObject:SQLREAL];
        }
        
    }
    free(properties);
    return [NSDictionary dictionaryWithObjectsAndKeys:proNames,@"name",proTypes,@"type",nil];
}

/** 获取所有属性，包含主键pk */
+ (NSDictionary *)getAllProperties
{
    NSDictionary *dict = [self.class getPropertys];
    
    NSMutableArray *proNames = [NSMutableArray array];
    NSMutableArray *proTypes = [NSMutableArray array];
    [proNames addObject:primaryId];
    [proTypes addObject:[NSString stringWithFormat:@"%@ %@",SQLINTEGER,PrimaryKey]];
    [proNames addObjectsFromArray:[dict objectForKey:@"name"]];
    [proTypes addObjectsFromArray:[dict objectForKey:@"type"]];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:proNames,@"name",proTypes,@"type",nil];
}

/** 数据库中是否存在表 */
+ (BOOL)isExistInTable
{
    __block BOOL res = NO;
    DBHelper *dbHelper = [DBHelper shareHelper];
    [dbHelper.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *tableName = NSStringFromClass(self.class);
        res = [db tableExists:tableName];
    }];
    return res;
}
+ (NSArray *)getColumns {
    DBHelper *dbHelper = [DBHelper shareHelper];
    NSMutableArray *columes = [NSMutableArray array];
    [dbHelper.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *tableName = NSStringFromClass([self class]);
        FMResultSet *resultSet = [db getTableSchema:tableName];
        while ([resultSet next]) {
            NSString *column = [resultSet stringForColumn:@"name"];
            [columes addObject:column];
        }
    }];
    return [columes copy];
}

+ (BOOL)createTable {
    FMDatabase *db = [FMDatabase databaseWithPath:[DBHelper dbPath]];
    if (![db open]) {
        NSLog(@"数据库打开失败");
        return NO;
    }
    NSString *tableName = NSStringFromClass(self.class);
    NSString *columnAndType = [self.class getColumeAndTypeString];
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(%@);",tableName,columnAndType];
    if (![db executeUpdate:sql]) {
        return NO;
    }
    NSMutableArray *columns = [NSMutableArray array];
    FMResultSet *resultSet = [db getTableSchema:tableName];
    while ([resultSet next]) {
        NSString *column = [resultSet stringForColumn:@"name"];
        [columns addObject:column];
    }
    NSDictionary *dict = [self.class getAllProperties];
    NSArray *properties = [dict objectForKey:@"name"];
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)",columns];
    //过滤数组
    NSArray *resultArray = [properties filteredArrayUsingPredicate:filterPredicate];
    
    for (NSString *column in resultArray) {
        NSUInteger index = [properties indexOfObject:column];
         NSString *proType = [[dict objectForKey:@"type"] objectAtIndex:index];
        NSString *fieldSql = [NSString stringWithFormat:@"%@ %@",column,proType];
        NSString *sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ ",NSStringFromClass(self.class),fieldSql];
        if (![db executeUpdate:sql]) {
            return NO;
        }
    }
    [db close];
    return YES;
}

//数据是否存在
- (BOOL)isExisitObj {

    id otherPaimaryValue = [self valueForKey:_keyword];
    
    DBHelper *dbHelper = [DBHelper shareHelper];
    
    __block BOOL isExist = NO;
    
    __block DBBaseModel *WeakSelf = self;
    
    [dbHelper.dbQueue inDatabase:^(FMDatabase *db) {
        
        NSString *tableName = NSStringFromClass(self.class);
        
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@'",tableName,WeakSelf.keyword,otherPaimaryValue];
        
        FMResultSet *aResult = [db executeQuery:sql];
        
        if([aResult next]){
            
            isExist = YES;
            
        }else{
            
            isExist = NO;
        }
        [aResult close];
    }];
    
    return isExist;
}

- (BOOL)saveOrUpdate
{
    
    BOOL isExsist = [self isExisitObj];
    
    if (isExsist ) {
        
        return  [self update];
        
    }else{
        
        return [self save];
        
    }
}

- (BOOL)save
{
    //保存修改时间
    NSTimeInterval time = [[NSDate date]timeIntervalSince1970];
    NSString *str = [NSString stringWithFormat:@"%.0f",time];
    
    NSString *tableName = NSStringFromClass(self.class);
    NSMutableString *keyString = [NSMutableString string];
    NSMutableString *valueString = [NSMutableString string];
    NSMutableArray *insertValues = [NSMutableArray  array];
    for (int i = 0; i < self.columnNames.count; i++) {
        NSString *proname = [self.columnNames objectAtIndex:i];
        if ([proname isEqualToString:primaryId]) {
            continue;
        }
        
        [keyString appendFormat:@"%@,", proname];
        [valueString appendString:@"?,"];
        id value;
        if ([proname isEqualToString:dbTimeCount]) {
            value = str;
        }else{
            value = [self valueForKey:proname];
        }
        if (!value) {
            value = @"";
        }
        [insertValues addObject:value];
    }
    
    [keyString deleteCharactersInRange:NSMakeRange(keyString.length - 1, 1)];
    [valueString deleteCharactersInRange:NSMakeRange(valueString.length - 1, 1)];
    
    DBHelper *dbHelper = [DBHelper shareHelper];
    __block BOOL res = NO;
    [dbHelper.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@(%@) VALUES (%@);", tableName, keyString, valueString];
        res = [db executeUpdate:sql withArgumentsInArray:insertValues];
        self.pk = res?[NSNumber numberWithLongLong:db.lastInsertRowId].intValue:0;
        NSLog(res?@"插入成功":@"插入失败");
    }];
    return res;
}
/* 批量保存用户对象*/
+ (BOOL)saveObjects:(NSArray *)array
{
    //判断是否是JKBaseModel的子类
    for (DBBaseModel *model in array) {
        if (![model isKindOfClass:[DBBaseModel class]]) {
            return NO;
        }
    }
    
    __block BOOL res = YES;
    DBHelper *dbHelper = [DBHelper shareHelper];
    // 如果要支持事务
    [dbHelper.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (DBBaseModel *model in array) {
            //保存修改时间
            NSTimeInterval time = [[NSDate date]timeIntervalSince1970];
            NSString *str = [NSString stringWithFormat:@"%.0f",time];
            
            NSString *tableName = NSStringFromClass(model.class);
            NSMutableString *keyString = [NSMutableString string];
            NSMutableString *valueString = [NSMutableString string];
            NSMutableArray *insertValues = [NSMutableArray  array];
            for (int i = 0; i < model.columnNames.count; i++) {
                NSString *proname = [model.columnNames objectAtIndex:i];
                if ([proname isEqualToString:primaryId]) {
                    continue;
                }
                [keyString appendFormat:@"%@,", proname];
                [valueString appendString:@"?,"];
                id value;
                if ([proname isEqualToString:dbTimeCount]) {
                    value = str;
                }else{
                    value = [model valueForKey:proname];
                }
                if (!value) {
                    value = @"";
                }
                [insertValues addObject:value];
            }
            [keyString deleteCharactersInRange:NSMakeRange(keyString.length - 1, 1)];
            [valueString deleteCharactersInRange:NSMakeRange(valueString.length - 1, 1)];
            
            NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@(%@) VALUES (%@);", tableName, keyString, valueString];
            BOOL flag = [db executeUpdate:sql withArgumentsInArray:insertValues];
            model.pk = flag?[NSNumber numberWithLongLong:db.lastInsertRowId].intValue:0;
            NSLog(flag?@"插入成功":@"插入失败");
            if (!flag) {
                res = NO;
                *rollback = YES;
                return;
            }
        }
    }];
    return res;
}
/** 更新单个对象 */
- (BOOL)update
{
    //设置更新时间
    NSTimeInterval time = [[NSDate date]timeIntervalSince1970];
    NSString *str = [NSString stringWithFormat:@"%.0f",time];
    
    DBHelper *dbHelper = [DBHelper shareHelper];
    __block BOOL res = NO;
    
    [dbHelper.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *tableName = NSStringFromClass(self.class);
        id primaryValue = [self valueForKey:self.keyword];
        
        NSMutableString *keyString = [NSMutableString string];
        NSMutableArray *updateValues = [NSMutableArray  array];
        for (int i = 0; i < self.columnNames.count; i++) {
            NSString *proname = [self.columnNames objectAtIndex:i];
            if ([proname isEqualToString:self.keyword]) {
                continue;
            }
            if([proname isEqualToString:primaryId]){
                
                continue;
            }
            [keyString appendFormat:@" %@=?,", proname];
            id value;
            if ([proname isEqualToString:dbTimeCount]) {
                value = str;
            }else{
                value = [self valueForKey:proname];
            }
            if (!value) {
                value = @"";
            }
            [updateValues addObject:value];
        }
        
        //删除最后那个逗号
        [keyString deleteCharactersInRange:NSMakeRange(keyString.length - 1, 1)];
        NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@ = ?;", tableName, keyString, self.keyword];
        [updateValues addObject:primaryValue];
        res = [db executeUpdate:sql withArgumentsInArray:updateValues];
        NSLog(res?@"更新成功":@"更新失败");
    }];
    return res;
}
/** 批量更新用户对象*/
+ (BOOL)updateObjects:(NSArray *)array
{
    for (DBBaseModel *model in array) {
        if (![model isKindOfClass:[DBBaseModel class]]) {
            return NO;
        }
    }
    __block BOOL res = YES;
    DBHelper *dbHelper = [DBHelper shareHelper];
    // 如果要支持事务
    [dbHelper.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (DBBaseModel *model in array) {
            NSTimeInterval time = [[NSDate date]timeIntervalSince1970];
            NSString *str = [NSString stringWithFormat:@"%.0f",time];
            
            NSString *tableName = NSStringFromClass(model.class);
            id primaryValue = [model valueForKey:primaryId];
            if (!primaryValue || primaryValue <= 0) {
                res = NO;
                *rollback = YES;
                return;
            }
            
            NSMutableString *keyString = [NSMutableString string];
            NSMutableArray *updateValues = [NSMutableArray  array];
            for (int i = 0; i < model.columnNames.count; i++) {
                NSString *proname = [model.columnNames objectAtIndex:i];
                if ([proname isEqualToString:primaryId]) {
                    continue;
                }
                [keyString appendFormat:@" %@=?,", proname];
                id value;
                if ([proname isEqualToString:dbTimeCount]) {
                    value = str;
                }else{
                    value = [model valueForKey:proname];
                }
                if (!value) {
                    value = @"";
                }
                [updateValues addObject:value];
            }
            
            //删除最后那个逗号
            [keyString deleteCharactersInRange:NSMakeRange(keyString.length - 1, 1)];
            NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@=?;", tableName, keyString, primaryId];
            [updateValues addObject:primaryValue];
            BOOL flag = [db executeUpdate:sql withArgumentsInArray:updateValues];
            NSLog(flag?@"更新成功":@"更新失败");
            if (!flag) {
                res = NO;
                *rollback = YES;
                return;
            }
        }
    }];
    
    return res;
}
/** 删除单个对象 */
- (BOOL)deleteObject
{
    DBHelper *dbHelper = [DBHelper shareHelper];
    __block BOOL res = NO;
    [dbHelper.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *tableName = NSStringFromClass(self.class);
        id primaryValue = [self valueForKey:primaryId];
        if (!primaryValue || primaryValue <= 0) {
            return ;
        }
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = ?",tableName,primaryId];
        res = [db executeUpdate:sql withArgumentsInArray:@[primaryValue]];
        NSLog(res?@"删除成功":@"删除失败");
    }];
    return res;
}
/** 批量删除用户对象 */
+ (BOOL)deleteObjects:(NSArray *)array
{
    for (DBBaseModel *model in array) {
        if (![model isKindOfClass:[DBBaseModel class]]) {
            return NO;
        }
    }
    
    __block BOOL res = YES;
    DBHelper *dbHelper = [DBHelper shareHelper];
    // 如果要支持事务
    [dbHelper.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (DBBaseModel *model in array) {
            NSString *tableName = NSStringFromClass(model.class);
            id primaryValue = [model valueForKey:primaryId];
            if (!primaryValue || primaryValue <= 0) {
                return ;
            }
            
            NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = ?",tableName,primaryId];
            BOOL flag = [db executeUpdate:sql withArgumentsInArray:@[primaryValue]];
            NSLog(flag?@"删除成功":@"删除失败");
            if (!flag) {
                res = NO;
                *rollback = YES;
                return;
            }
        }
    }];
    return res;
}
/** 通过条件删除数据 */
+ (BOOL)deleteObjectsByCriteria:(NSString *)criteria
{
    DBHelper *dbHelper = [DBHelper shareHelper];
    __block BOOL res = NO;
    [dbHelper.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *tableName = NSStringFromClass(self.class);
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ %@ ",tableName,criteria];
        res = [db executeUpdate:sql];
        NSLog(res?@"删除成功":@"删除失败");
    }];
    return res;
}

/** 清空表 */
+ (BOOL)clearTable
{
    DBHelper *dbHelper = [DBHelper shareHelper];
    __block BOOL res = NO;
    [dbHelper.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *tableName = NSStringFromClass(self.class);
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@",tableName];
        res = [db executeUpdate:sql];
        NSLog(res?@"清空成功":@"清空失败");
    }];
    return res;
}

#pragma mark - util method
+ (NSString *)getColumeAndTypeString {
    NSMutableString* pars = [NSMutableString string];
    NSDictionary *dict = [self.class getAllProperties];
    
    NSMutableArray *proNames = [dict objectForKey:@"name"];
    NSMutableArray *proTypes = [dict objectForKey:@"type"];
    
    for (int i=0; i< proNames.count; i++) {
        [pars appendFormat:@"%@ %@",[proNames objectAtIndex:i],[proTypes objectAtIndex:i]];
        if(i+1 != proNames.count)
        {
            [pars appendString:@","];
        }
    }
    return pars;
}
- (NSString *)description
{
    NSString *result = @"";
    NSDictionary *dict = [self.class getAllProperties];
    NSMutableArray *proNames = [dict objectForKey:@"name"];
    for (int i = 0; i < proNames.count; i++) {
        NSString *proName = [proNames objectAtIndex:i];
        id  proValue = [self valueForKey:proName];
        result = [result stringByAppendingFormat:@"%@:%@\n",proName,proValue];
    }
    return result;
}
/** 查询全部数据 */
+ (NSArray *)findAll
{
    NSLog(@"db---%s",__func__);
    DBHelper *dbHelper = [DBHelper shareHelper];
    NSMutableArray *users = [NSMutableArray array];
    [dbHelper.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *tableName = NSStringFromClass(self.class);
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@",tableName];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next]) {
            DBBaseModel *model = [[self.class alloc] init];
            for (int i=0; i< model.columnNames.count; i++) {
                NSString *columeName = [model.columnNames objectAtIndex:i];
                NSString *columeType = [model.columnNames objectAtIndex:i];
                if ([columeType isEqualToString:SQLTEXT]) {
                    [model setValue:[resultSet stringForColumn:columeName] forKey:columeName];
                } else {
                    [model setValue:[NSNumber numberWithLongLong:[resultSet longLongIntForColumn:columeName]] forKey:columeName];
                }
            }
            [users addObject:model];
            FMDBRelease(model);
        }
    }];
    
    return users;
}
/** 查找某条数据 */
+ (instancetype)findFirstByCriteria:(NSString *)criteria
{
    NSArray *results = [self.class findByCriteria:criteria];
    if (results.count < 1) {
        return nil;
    }
    
    return [results firstObject];
}

+ (instancetype)findByPK:(int)inPk
{
    NSString *condition = [NSString stringWithFormat:@"WHERE %@=%d",primaryId,inPk];
    return [self findFirstByCriteria:condition];
}



/** 通过条件查找数据 */
+ (NSArray *)findByCriteria:(NSString *)criteria
{
    DBHelper *dbHelper = [DBHelper shareHelper];
    NSMutableArray *users = [NSMutableArray array];
    [dbHelper.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *tableName = NSStringFromClass(self.class);
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@  %@",tableName,criteria];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next]) {
            DBBaseModel *model = [[self.class alloc] init];
            for (int i=0; i< model.columnNames.count; i++) {
                NSString *columeName = [model.columnNames objectAtIndex:i];
                NSString *columeType = [model.columnNames objectAtIndex:i];
                if ([columeType isEqualToString:SQLTEXT]) {
                    [model setValue:[resultSet stringForColumn:columeName] forKey:columeName];
                } else {
                    [model setValue:[NSNumber numberWithLongLong:[resultSet longLongIntForColumn:columeName]] forKey:columeName];
                }
            }
            [users addObject:model];
            FMDBRelease(model);
        }
    }];
    return users;
}
// 值 为 通过 条件查找  － 返回数组中的第一个
+ (instancetype)findWhereColoum:(NSString *)coloum equleToValue:(NSString *)value{
    
    return [[self class] findFirstByCriteria:[NSString stringWithFormat:@"WHERE %@='%@'",coloum,value]];
}
#pragma mark - must be override method
/** 如果子类中有一些property不需要创建数据库字段，那么这个方法必须在子类中重写
 */
+ (NSArray *)transients
{
    return @[];
}

@end
