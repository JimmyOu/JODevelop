//
//  JOPromise_impl_filter.m
//  JODevelop
//
//  Created by JimmyOu on 2018/1/18.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "JOPromise_impl.h"

@implementation JOPromise (filter)

+ (instancetype)filter:(NSArray *)array filterHandler:(handlerFilter)handler
{
    NSMutableArray<JOPromise *> *promises = @[].mutableCopy;
    
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop) {
        if (handler(obj)) {
            [promises addObject:[JOPromise resolve:obj]];
        }
    }];
    
    return [JOPromise all:promises];
}


@end
