//
//  _interface_jsapi.m
//  模块化Demo
//
//  Created by JimmyOu on 17/3/15.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "_interface_jsapi.h"
#import "JS_Tools.h"
#import "JSPluginManager.h"

@implementation _interface_jsapi

- (void)install {
    [[JSPluginManager sharedInstance] registerPlugin:@"Tools" pluginClass:[JS_Tools class]];
}

@end
