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
    
    
    [NEMonitorUtils ne_swizzleSEL:@selector(forwardInvocation:) withSEL:@selector(avoidCrashForwardInvocation:) forClass:[NSObject class]];
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

- (void)avoidCrashForwardInvocation:(NSInvocation *)anInvocation {

    @try {
        [self avoidCrashForwardInvocation:anInvocation];
    } @catch (NSException *exception) {
        [NEMonitorUtils notifyWithException:exception];
    } @finally {
    }
}



@end
