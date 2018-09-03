//
//  NSObject+NECrashVoid.m
//  SnailReader
//
//  Created by JimmyOu on 2018/8/31.
//  Copyright © 2018年 com.netease. All rights reserved.
//

#import "NSObject+NECrashVoid.h"
#import "NEMonitorUtils.h"
#import "NECrashProxy.h"
#import <objc/runtime.h>
#import "NEAppMonitor.h"

@implementation NSObject (NECrashVoid)

+ (void)swizzle {
    // setValue:forKey:
    [NEMonitorUtils ne_swizzleSEL:@selector(setValue:forKey:) withSEL:@selector(ne_avoidCrashSetValue:forKey:) forClass:[NSObject class]];
    // setValue:forKeyPath:
    [NEMonitorUtils ne_swizzleSEL:@selector(setValue:forKeyPath:) withSEL:@selector(ne_avoidCrashSetValue:forKeyPath:) forClass:[NSObject class]];
    //setValue:forUndefinedKey:
    [NEMonitorUtils ne_swizzleSEL:@selector(setValue:forUndefinedKey:) withSEL:@selector(ne_avoidCrashSetValue:forUndefinedKey:) forClass:[NSObject class]];
    //setValuesForKeysWithDictionary:
    [NEMonitorUtils ne_swizzleSEL:@selector(setValuesForKeysWithDictionary:) withSEL:@selector(ne_avoidCrashsetValuesForKeysWithDictionary:) forClass:[NSObject class]];
    
    //unrecognized selector sent to instance
    [NEMonitorUtils ne_swizzleSEL:@selector(forwardingTargetForSelector:) withSEL:@selector(ne_avoidCrashforwardingTargetForSelector:) forClass:[NSObject class]];
}


/**********   setValue:forKey:  *********/
- (void)ne_avoidCrashSetValue:(id)value forKey:(NSString *)key {
    @try {
        [self ne_avoidCrashSetValue:value forKey:key];
    }
    @catch (NSException * e){
        [NEMonitorUtils notifyWithException:e];
    }
    
}

/**********   setValue:forKeyPath:  *********/
- (void)ne_avoidCrashSetValue:(id)value forKeyPath:(NSString *)keyPath {
    @try {
        [self ne_avoidCrashSetValue:value forKeyPath:keyPath];
    }
    @catch (NSException * e){
        [NEMonitorUtils notifyWithException:e];
    }
    
}

/**********   setValue:forUndefinedKey:  *********/
- (void)ne_avoidCrashSetValue:(id)value forUndefinedKey:(NSString *)key {
    @try {
        [self ne_avoidCrashSetValue:value forKey:key];
    }
    @catch (NSException * e){
        [NEMonitorUtils notifyWithException:e];
    }
}

/**********   setValuesForKeysWithDictionary:  *********/
- (void)ne_avoidCrashsetValuesForKeysWithDictionary:(NSDictionary<NSString *,id> *)keyedValues {
    @try {
        [self ne_avoidCrashsetValuesForKeysWithDictionary:keyedValues];
    }
    @catch (NSException * e){
        [NEMonitorUtils notifyWithException:e];
    }
}

/**********   unknown selector  *********/
- (id)ne_avoidCrashforwardingTargetForSelector:(SEL)aSelector {
    NSString *className = NSStringFromClass([self class]);
    NSString *methodName = NSStringFromSelector(aSelector);
    
    //是否在白名单里
    NSArray *whiteList = [NEAppMonitor sharedInstance].noSELWhiteClassNameList;
    BOOL inWhiteList = NO;
    for (NSString *class_name in whiteList) {
        if ([class_name isEqualToString:className]) {
            inWhiteList = YES;
            break;
        }
    }
    if ([self respondsToSelector:@selector(forwardInvocation:)] || inWhiteList) { // 表示自己该类就是要应用转发来做一些事儿的，就不重写
        return [self ne_avoidCrashforwardingTargetForSelector:aSelector];
    } else { //确实进入了错误,如果是系统的错误或者NECrashProxy，我不去记录信息
        if ([NSStringFromClass([self class]) hasPrefix:@"_"] || [self isKindOfClass:NSClassFromString(@"UITextInputController")] || [NSStringFromClass([self class]) hasPrefix:@"UIKeyboard"] || [methodName isEqualToString:@"dealloc"] || [className isEqualToString:@"NECrashProxy"]) {
            return nil;
        }
        
        //记录信息，添加信息，并把IMP指向selecotor;
        NECrashProxy * crashProxy = [NECrashProxy new];
        crashProxy.crashMsg =[NSString stringWithFormat:@"CrashProtector: [%@ %p %@]: unrecognized selector sent to instance",NSStringFromClass([self class]),self,NSStringFromSelector(aSelector)];
        class_addMethod([NECrashProxy class], aSelector, [crashProxy methodForSelector:@selector(getCrashMsg)], "v@:");
        return crashProxy;
    }
}


@end
