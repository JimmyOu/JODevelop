//
//  JOPromise_impl_reduce.m
//  JODevelop
//
//  Created by JimmyOu on 2018/1/18.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "JOPromise_impl.h"

@implementation JOPromise (reduce)

+ (instancetype)reduce:(NSArray *)array reduceHandler:(handlerReduce)handler initialValue:(id)initialValue
{
    if (array.count == 0) {
        return nil;
    }
    
    __block JOPromise *p = handler(array[0],initialValue);
    
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx > 0) {
            p = p.then(^id(id value){
                return handler(obj, value);
            });
        }
    }];
    
    return p.then(^id(id res) {
        return res;
    });
}

@end

