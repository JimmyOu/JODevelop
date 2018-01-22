//
//  JOPromise_impl_catch.m
//  JODevelop
//
//  Created by JimmyOu on 2018/1/18.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "JOPromise_impl.h"

@implementation JOPromise (catch)

- (JOPromise *(^)(handlerError))catch
{
    __weak __typeof(self)weakSelf = self;
    
    return ^JOPromise *(handlerError catchBlock) {
        __weak JOPromise *newPromise = nil;
        newPromise = [JOPromise promise:^(handlerResolve resolve, handlerReject reject) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            resolve(strongSelf);
        }];
        
        newPromise.catchBlock = catchBlock;
        return newPromise;
    };
}

@end
