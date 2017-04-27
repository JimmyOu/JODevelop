//
//  JSResult.h
//  JOFoundation
//
//  Created by JimmyOu on 16/11/8.
//  Copyright © 2016年 JimmyOu. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const NSInteger ERR_CODE_CALL_ERROR;
extern NSString * const ERR_INFO_CALL_ERROR;

extern const NSInteger ERR_CODE_MODULE_NOT_EXISTS;
extern NSString * const ERR_INFO_MODULE_NOT_EXISTS;

extern const NSInteger ERR_CODE_METHOD_NOT_EXISTS;
extern NSString * const ERR_INFO_METHOD_NOT_EXISTS;

extern const NSInteger ERR_CODE_PARAMS_NOT_VALID;
extern NSString * const ERR_INFO_PARAMS_NOT_VALID;

extern const NSInteger ERR_CODE_USER_NOT_LOGIN;
extern NSString * const ERR_INFO_USER_NOT_LOGIN;

extern const NSInteger ERR_CODE_USER_CANCEL;
extern NSString * const ERR_INFO_USER_CANCEL;

extern const NSInteger ERR_CODE_USER_NO_PERMISSIONS;
extern NSString * const ERR_INFO_USER_NO_PERMISSIONS;

@interface JSResult : NSObject

@property (nonatomic, assign) long code;
@property (nonatomic, copy) NSString *msg;
@property (nonatomic, strong) NSDictionary *data;

+ (instancetype)resultWithDictionary:(NSDictionary *)dictionary;
+ (instancetype)resultWithError:(NSInteger)errCode errMessage:(NSString *)errMessage;

- (NSDictionary *)toDict;

@end
