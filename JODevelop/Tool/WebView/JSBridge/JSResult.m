//
//  JSResult.m
//  JOFoundation
//
//  Created by JimmyOu on 16/11/8.
//  Copyright © 2016年 JimmyOu. All rights reserved.
//

#import "JSResult.h"
const NSInteger ERR_CODE_CALL_ERROR          = -1000;
NSString * const ERR_INFO_CALL_ERROR         = @"调用格式错误";

const NSInteger ERR_CODE_MODULE_NOT_EXISTS   = -999;
NSString * const ERR_INFO_MODULE_NOT_EXISTS  = @"模块未找到";

const NSInteger ERR_CODE_METHOD_NOT_EXISTS   = -998;
NSString * const ERR_INFO_METHOD_NOT_EXISTS  = @"方法未找到";

const NSInteger ERR_CODE_PARAMS_NOT_VALID    = -997;
NSString * const ERR_INFO_PARAMS_NOT_VALID   = @"参数非法";

const NSInteger ERR_CODE_USER_NOT_LOGIN      = -996;
NSString * const ERR_INFO_USER_NOT_LOGIN     = @"用户未登录";

const NSInteger ERR_CODE_USER_CANCEL         = -995;
NSString * const ERR_INFO_USER_CANCEL        = @"用户取消";

const NSInteger ERR_CODE_USER_NO_PERMISSIONS = -994;
NSString * const ERR_INFO_USER_NO_PERMISSIONS = @"用户无权限";
@implementation JSResult

+ (instancetype)resultWithDictionary:(NSDictionary *)dictionary
{
    JSResult *result = [[JSResult alloc] init];
    result.code = 0;
    result.msg  = @"";
    result.data = [dictionary copy];
    return result;
}

+ (instancetype)resultWithError:(NSInteger)errCode errMessage:(NSString *)errMessage
{
    JSResult *result = [[JSResult alloc] init];
    result.code = errCode;
    result.msg  = errMessage;
    result.data = @{};
    return result;
}
- (NSDictionary *)toDict {
    return @{@"code":@(_code),@"msg":_msg,@"data":_data};
}

@end
