//
// Created by 徐鹏 on 16/3/25.
// Copyright (c) 2016 徐鹏. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XPSuperInvoker <NSObject>

+ (id)invoke:(SEL)selector error:(NSError *__autoreleasing *)error, ...;

+ (id)invokeWithName:(NSString *)selName error:(NSError *__autoreleasing *)error, ...;

- (id)invoke:(SEL)selector error:(NSError *__autoreleasing *)error, ...;

- (id)invokeWithName:(NSString *)selName error:(NSError *__autoreleasing *)error, ...;

@end
