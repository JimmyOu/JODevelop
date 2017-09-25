//
//  AXDRouter+LoginService.m
//  JOFoundation
//
//  Created by JimmyOu on 17/2/23.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "AXDRouter+LoginService.h"

@implementation AXDRouter (LoginService)

- (void)doLogin:(void (^)(NSInteger))callback {
    [AXDRouter dispatchInvokes:@"login" action:@"dologin:" error:nil,callback];
}

- (id)doBussiness:(void (^)(NSInteger))callBack {
    return  [AXDRouter dispatchInvokes:@"login" action:@"dobussiness:" error:nil,callBack];
}

- (void)doBussiness {
    [AXDRouter dispatchInvokes:@"login" action:@"dobussiness" error:nil];
}

- (void)doSomething:(NSString *)other {
     [AXDRouter dispatchInvokes:@"login" action:@"dosomething:" error:nil,other];
}


@end
