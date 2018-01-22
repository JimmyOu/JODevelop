//
//  JOPromise_impl_map.m
//  JODevelop
//
//  Created by JimmyOu on 2018/1/18.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//


#import "JOPromise_impl.h"

@implementation JOPromise (map)

+ (instancetype)map:(NSArray *)array mapHandler:(handlerMap)handler
{
    NSMutableArray<JOPromise *> *promises = @[].mutableCopy;
    
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop) {
        [promises addObject:handler(obj)];
    }];
    
    return [JOPromise all:promises];
}

@end

