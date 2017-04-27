//
//  JS_Tools.m
//  模块化Demo
//
//  Created by JimmyOu on 17/3/15.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "JS_Tools.h"
#import "JSResult.h"
#import "AXDRouterImport.h"
@implementation JS_Tools

- (void)login:(NSDictionary *)params
          jscallback:(NSString *)jsCallback
          completion:(void (^)(NSString *jsMethod, JSResult *result))completion{
    
    NSLog(@"%s, params = %@",__func__,params);
    NSString *params1 = params[@"params1"];
    [[AXDRouter sharedInstance] doSomething:params1];
    

}

@end
