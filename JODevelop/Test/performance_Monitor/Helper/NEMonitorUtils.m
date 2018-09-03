//
//  JOMonitorUtils.m
//  JODevelop
//
//  Created by JimmyOu on 2018/8/7.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "NEMonitorUtils.h"
#import <objc/runtime.h>
#import <mach/mach.h>
#import "BSBacktraceLogger.h"

@implementation NEMonitorUtils
+ (void)ne_swizzleSEL:(SEL)originalSEL withSEL:(SEL)swizzledSEL forClass:(Class)clz {
    Method originalMethod = class_getInstanceMethod(clz, originalSEL);
    Method swizzledMethod = class_getInstanceMethod(clz, swizzledSEL);
    
    BOOL didAddMethod =
    class_addMethod(clz,
                    originalSEL,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(clz,
                            swizzledSEL,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

+ (NSString *)genCallStackReport {
    @try {
      return [BSBacktraceLogger bs_backtraceOfAllThread];
    }
    @catch (NSException * e){
        return @"";
    }
}
@end
