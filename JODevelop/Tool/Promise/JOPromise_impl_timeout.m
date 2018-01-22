//
//  JOPromise_impl_timeout.m
//  JODevelop
//
//  Created by JimmyOu on 2018/1/16.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "JOPromise_impl.h"

@implementation JOPromise (timeout)

- (JOPromise *(^)(NSTimeInterval))timeout
{
    return ^JOPromise *(NSTimeInterval seconds) {
        __weak JOPromise *newPromise = [JOPromise race:@[self, [JOPromise timer:seconds]]];
        
        return newPromise;
    };
}

@end
