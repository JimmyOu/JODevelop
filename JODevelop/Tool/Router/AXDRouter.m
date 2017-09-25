//
//  AXDRouter.m
//  JOFoundation
//
//  Created by JimmyOu on 17/2/23.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "AXDRouter.h"
#import "XPSuperInvoker.h"
#import "NSObject+XPSuperInvoker.h"
#import "NSString+Extention.h"

//你的App的Scheme
static NSString * const AXDAppScheme  = @"axd";

@implementation AXDRouter


- (BOOL)handel_application_openurl:(UIApplication *)application
                           openurl:(NSURL *)url
                 sourceapplication:(NSString *)sourceapplication
                        annotation:(id)annotation
{
    if ([url.scheme isEqualToString:AXDAppScheme]) {
        [AXDRouter dispatchInvokesWithUrl:url.absoluteString];
    }
    
    return YES;
}

- (BOOL)handel_application_openurl:(UIApplication *)application
                           openurl:(NSURL *)url
                           options:(NSDictionary<NSString *,id> *)options
{
    if ([url.scheme isEqualToString:AXDAppScheme]) {
        [AXDRouter dispatchInvokesWithUrl:url.absoluteString];
    }
    
    return YES;
}

+ (nonnull instancetype)sharedInstance
{
    static AXDRouter *router;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        router = [[AXDRouter alloc] init];
    });
    return router;
}

+ (id)dispatchInvokes:(NSString *)target action:(NSString *)action error:(NSError *__autoreleasing  _Nullable *)error, ...
{
    NSString *targetClassString = [NSString stringWithFormat:@"_interface_%@", target.lowercaseString];
    NSString *actionSelString   = action.lowercaseString;
    
    Class targetClass  = NSClassFromString(targetClassString);
    id targetInstance  = [[targetClass alloc] init];
    SEL actionSelector = NSSelectorFromString(actionSelString);
    
    if (targetInstance == nil) {
        NSLog(@"找不到对象"); //自己做错误处理，我这里直接Log。
        return nil;
    }
    
    if (![targetInstance respondsToSelector:actionSelector]) {
        NSLog(@"找不到方法"); //自己做错误处理，我这里直接Log。
        return nil;
    }
    
    va_list argList;
    va_start(argList, error);
    NSArray* boxingArguments = xps_targetBoxingArgumentsWithVaList(argList, targetClass, actionSelector, error);
    va_end(argList);
    
    if (!boxingArguments) {
        return nil;
    }
    
    return xps_targetCallSelectorWithArgumentError(targetInstance, actionSelector, boxingArguments, error);
}

+ (id)dispatchInvokesWithUrl:(NSString *)url {

    NSURL *invokeUrl = [NSURL URLWithString:url];
    if (![invokeUrl.scheme isEqualToString:AXDAppScheme]) {
        //ToDo: 调用出错的错误页面
        return nil;
    }
    
    if ([NSString isEmpty:invokeUrl.host]) {
        //ToDo: 调用出错的错误页面
        return nil;
    }
    NSString *targetClassString = [NSString stringWithFormat:@"_interface_%@", [invokeUrl.host lowercaseString]];
    Class targetClass  = NSClassFromString(targetClassString);
    id targetInstance  = [[targetClass alloc] init];
    
    if (targetInstance == nil) {
        //ToDo: 调用出错的错误页面
        return nil;
    }
    
    NSString *actionSelString = [[invokeUrl.path substringFromIndex:1] lowercaseString];
    if ([NSString isEmpty:invokeUrl.host]) {
        //ToDo: 调用出错的错误页面
        return nil;
    }
    
    NSString *params = invokeUrl.query;
    
    if (!params) { //如果有的方法不需要参数，直接拼接后直接调用
        actionSelString = [NSString stringWithFormat:@"_remote_%@", actionSelString];
        SEL actionSelector = NSSelectorFromString(actionSelString);
        if (![targetInstance respondsToSelector:actionSelector]) {
            //ToDo: 调用出错的错误页面
            return nil;
        }
        
        NSError *err;
        id result = [targetInstance invoke:actionSelector error:&err];
        if (err) {
            //ToDo: 调用出错的错误页面
        }
        return err ? nil : result;

    } else { //如果有的方法需要参数
        //解析参数
        NSArray *paramsArray = [params componentsSeparatedByString:@"&"];
        NSMutableArray *argArray = [NSMutableArray array];
        NSMutableArray *selArray = [NSMutableArray array];
        
        [paramsArray enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSRange range = [obj rangeOfString:@"="];
            NSString *arg = [obj substringFromIndex:(range.location + range.length)];
            NSString *sel = [obj substringToIndex:(range.location)];
            [argArray addObject:arg];
            [selArray addObject:sel];
        }];
        
        //拼接SEL
        actionSelString = [NSString stringWithFormat:@"_remote_%@:", actionSelString];
        if (selArray.count > 1) {
            for (NSUInteger j = 1; j < selArray.count; ++j) {
                actionSelString = [actionSelString stringByAppendingString:[NSString stringWithFormat:@"%@:",selArray[j]]];
            }
        }
        
        SEL actionSelector = NSSelectorFromString(actionSelString);
        if (![targetInstance respondsToSelector:actionSelector]) {
            //ToDo: 调用出错的错误页面
            return nil;
        }
        NSArray* boxingArguments = xps_targetBoxingArgumentsWithArray(argArray, targetClass, actionSelector, nil);
        if (!boxingArguments) {
            return nil;
        }
        NSError *err;
        id result = xps_targetCallSelectorWithArgumentError(targetInstance, actionSelector, boxingArguments, &err);
        if (err) {
            //ToDo: 调用出错的错误页面
        }
        return err ? nil : result;
    }
}

@end
