//
//  NSAttributedString+NECrashVoid.m
//  SnailReader
//
//  Created by JimmyOu on 2018/8/31.
//  Copyright © 2018年 com.netease. All rights reserved.
//

#import "NSAttributedString+NECrashVoid.h"
#import "NEMonitorUtils.h"

@implementation NSAttributedString (NECrashVoid)

+ (void)swizzle {
    Class class = NSClassFromString(@"NSConcreteAttributedString");
    
    [NEMonitorUtils ne_swizzleSEL:@selector(initWithString:) withSEL:@selector(avoidCrashInitWithString:) forClass:class];
    [NEMonitorUtils ne_swizzleSEL:@selector(initWithAttributedString:) withSEL:@selector(avoidCrashInitWithAttributedString:) forClass:class];
    [NEMonitorUtils ne_swizzleSEL:@selector(initWithString:attributes:) withSEL:@selector(avoidCrashInitWithString:attributes:) forClass:class];
    
}

- (instancetype)avoidCrashInitWithString:(NSString *)str {
    id object = nil;
    
    @try {
        object = [self avoidCrashInitWithString:str];
    }
    @catch (NSException *exception) {
        [NEMonitorUtils notifyWithException:exception];
    }
    @finally {
        return object;
    }
}

- (instancetype)avoidCrashInitWithAttributedString:(NSAttributedString *)attrStr {
    id object = nil;
    
    @try {
        object = [self avoidCrashInitWithAttributedString:attrStr];
    }
    @catch (NSException *exception) {
        [NEMonitorUtils notifyWithException:exception];
    }
    @finally {
        return object;
    }
}


- (instancetype)avoidCrashInitWithString:(NSString *)str attributes:(NSDictionary<NSString *,id> *)attrs {
    id object = nil;
    
    @try {
        object = [self avoidCrashInitWithString:str attributes:attrs];
    }
    @catch (NSException *exception) {
        [NEMonitorUtils notifyWithException:exception];
    }
    @finally {
        return object;
    }
}

@end

@implementation NSMutableAttributedString (NECrashVoid)

+ (void)swizzle {
    Class class = NSClassFromString(@"NSConcreteMutableAttributedString");
    
    //initWithString:
    [NEMonitorUtils ne_swizzleSEL:@selector(initWithString:) withSEL:@selector(avoidCrashInitWithString:) forClass:class];
    
    //initWithString:attributes:
    [NEMonitorUtils ne_swizzleSEL:@selector(initWithString:attributes:) withSEL:@selector(avoidCrashInitWithString:attributes:) forClass:class];
    
}


- (instancetype)avoidCrashInitWithString:(NSString *)str {
    id object = nil;
    
    @try {
        object = [self avoidCrashInitWithString:str];
    }
    @catch (NSException *exception) {
        [NEMonitorUtils notifyWithException:exception];
    }
    @finally {
        return object;
    }
}


- (instancetype)avoidCrashInitWithString:(NSString *)str attributes:(NSDictionary<NSString *,id> *)attrs {
    id object = nil;
    
    @try {
        object = [self avoidCrashInitWithString:str attributes:attrs];
    }
    @catch (NSException *exception) {
        [NEMonitorUtils notifyWithException:exception];
    }
    @finally {
        return object;
    }
}



@end
