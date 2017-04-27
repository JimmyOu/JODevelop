//
//  _interface_login.m
//  JOFoundation
//
//  Created by JimmyOu on 17/2/23.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "_interface_login.h"

@implementation _interface_login

- (void)dologin:(void (^)(NSInteger))callBack {
    NSLog(@"%s",__func__);
    if (callBack) {
        callBack(1);
    }
}

- (id)dobussiness:(void (^)(NSInteger))callBack {
    NSLog(@"%s",__func__);
    if (callBack) {
        callBack(1);
    }
    return self;
}

- (void)dobussiness {
    NSLog(@"%s",__func__);
}


- (void)_remote_dologin {
    NSLog(@"%s",__func__);
}

- (void)_remote_dologin:(NSString *)str {
    NSLog(@"%s   paramsIn :%@",__func__,str);
}
- (id)_remote_dologin_protocol:(NSString *)str {
    NSLog(@"%s   paramsIn :%@",__func__,str);
    return self;
}

- (void)dosomething:(NSString *)other {
    NSLog(@"%s %@",__func__,other);
}
@end
