//
//  JSPluginManager.h
//  JOFoundation
//
//  Created by JimmyOu on 16/11/8.
//  Copyright © 2016年 JimmyOu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSResult.h"
@interface JSPluginManager : NSObject

+ (instancetype)sharedInstance;

/**
注册H5和原生交互的类
 @param namespace 模块名key
 @param pluginClass H5和原生交互的类
 */
- (void)registerPlugin:(NSString *)namespace pluginClass:(Class)pluginClass;

/**
 调用解析JS的jsCall，解析成

 @param jsCall     H5通过jsbrige传递来的字典
 @param completion 解析结果
 */
- (void)dispatchJSCall:(NSDictionary *)jsCall completion:(void(^)(NSString *jsMethod, JSResult *result))completion;

@end
