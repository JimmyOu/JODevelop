//
// Created by 徐鹏 on 16/3/25.
// Copyright (c) 2016 徐鹏. All rights reserved.
//

#import <Foundation/Foundation.h>

NSArray *xps_targetBoxingArgumentsWithVaList(va_list argList, Class cls, SEL selector, NSError *__autoreleasing *error);
NSArray *xps_targetBoxingArgumentsWithArray(NSArray *argList, Class cls, SEL selector, NSError *__autoreleasing *error);
id xps_targetCallSelectorWithArgumentError(id target, SEL selector, NSArray *argsArr, NSError *__autoreleasing *error);

@interface NSObject (XPSuperInvoker)

+ (id)invoke:(SEL)selector error:(NSError *__autoreleasing *)error, ...;

+ (id)invokeWithName:(NSString *)selName error:(NSError *__autoreleasing *)error, ...;

- (id)invoke:(SEL)selector error:(NSError *__autoreleasing *)error, ...;

- (id)invokeWithName:(NSString *)selName error:(NSError *__autoreleasing *)error, ...;

@end