//
//  JOPromise_impl_finally.m
//  JODevelop
//
//  Created by JimmyOu on 2018/1/18.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "JOPromise_impl.h"

@implementation JOPromise (finally)

- (void (^)(dispatch_block_t))finally
{
    __weak __typeof(self)weakSelf = self;
    
    return ^(dispatch_block_t runBlock) {
        __weak JOPromise *newPromise = nil;
        
        newPromise = [JOPromise promise:^(handlerResolve resolve, handlerReject reject) {
            resolve(weakSelf);
        }];
        
        newPromise.thenBlock = ^id(id value){
            runBlock();
            return nil;
        };
        
        newPromise.catchBlock = ^(NSError * error){
            runBlock();
        };
    };
}

@end
