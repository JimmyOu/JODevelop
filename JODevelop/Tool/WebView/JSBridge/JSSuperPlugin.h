//
//  JSSuperPlugin.h
//  JOFoundation
//
//  Created by JimmyOu on 16/11/9.
//  Copyright © 2016年 JimmyOu. All rights reserved.
//  模块类的基类

#import <Foundation/Foundation.h>
@class JSPluginManager,JSResult;
@interface JSSuperPlugin : NSObject

@property (nonatomic, weak)  JSPluginManager *pluginManager;
/**
 * 执行JS调用,已用 Runtime 方法分发调用, 子类只需要实现各种 -(XPSuperJSResult *)method:(NSDictionary *)params 即可
 * @param method JS调用的原生方法名
 * @param params JS传递的参数
 * @param jsCallback JS接收返回数据的回调方法名
 * @param completion 完成事件
 */
- (void)executeJSCall:(NSString *)method
               params:(NSDictionary *)params
           jsCallback:(NSString *)jsCallback
           completion:(void (^)(NSString *jsMethod, JSResult *result))completion;
@end
