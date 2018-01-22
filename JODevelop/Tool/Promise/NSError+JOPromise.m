//
//  NSError+JOPromise.m
//  JODevelop
//
//  Created by JimmyOu on 2018/1/16.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "NSError+JOPromise.h"
static NSString *const kErrorDomain = @"err.jokit.promise";
static const NSInteger kPromiseRuntimeError = -999;
static const NSInteger kPromiseRejectError = -998;

@implementation NSError (JOPromise)

+ (instancetype)errorWithException:(NSException *)exception {
    return [NSError errorWithDomain:kErrorDomain code:kPromiseRuntimeError userInfo:@{@"exception":exception}];
}
+ (instancetype)errorWithReject:(NSError *)actualError {
    return [NSError errorWithDomain:kErrorDomain code:kPromiseRejectError userInfo:@{@"error":actualError}];
}
+ (instancetype)errorWithValue:(id)value {
    return [NSError errorWithDomain:kErrorDomain code:kPromiseRejectError userInfo:@{@"value":value}];
}
+ (instancetype)errorWithReason:(NSString *)reason {
    return [NSError errorWithDomain:kErrorDomain code:kPromiseRejectError userInfo:@{@"reason":reason}];
}
+ (instancetype)errorWithUserInfo:(NSDictionary *)userInfo {
    return [NSError errorWithDomain:kErrorDomain code:kPromiseRejectError userInfo:userInfo];
}

@end
