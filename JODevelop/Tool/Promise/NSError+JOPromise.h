//
//  NSError+JOPromise.h
//  JODevelop
//
//  Created by JimmyOu on 2018/1/16.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (JOPromise)

+ (instancetype)errorWithException:(NSException *)exception;
+ (instancetype)errorWithReject:(NSError *)actualError;
+ (instancetype)errorWithValue:(id)value;
+ (instancetype)errorWithReason:(NSString *)reason;
+ (instancetype)errorWithUserInfo:(NSDictionary *)userInfo;

@end
