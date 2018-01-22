//
//  JOPromise_impl_then.m
//  JODevelop
//
//  Created by JimmyOu on 2018/1/16.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "JOPromise_impl.h"

@implementation JOPromise (then)
- (JOPromise *(^)(handlerRun))then {
    __weak typeof(self) weakSelf = self;
    
    return ^JOPromise *(handlerRun thenBlock) {
        __weak JOPromise *newPromise = nil;
        newPromise = [JOPromise promise:^(handlerResolve resolve, handlerReject reject) {
           __strong typeof(self) strongSelf = weakSelf;
            resolve(strongSelf);
        }];
        newPromise.thenBlock = thenBlock;
        return newPromise;
    };
}


@end
