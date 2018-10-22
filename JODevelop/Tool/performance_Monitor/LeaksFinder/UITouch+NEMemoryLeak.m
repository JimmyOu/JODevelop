//
//  UITouch+NEMemoryLeak.m
//  TestApp
//
//  Created by JimmyOu on 2018/10/9.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "UITouch+NEMemoryLeak.h"
#import <objc/runtime.h>
#import "NSObject+NEMemoryLeak.h"
#if _INTERNAL_MLF_ENABLED

extern const void *const kLatestSenderKey;

@implementation UITouch (NEMemoryLeak)


+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleSEL:@selector(setView:) withSEL:@selector(swizzled_setView:)];
    });
}

- (void)swizzled_setView:(UIView *)view {
    [self swizzled_setView:view];
    
    if (view) {
        objc_setAssociatedObject([UIApplication sharedApplication],
                                 kLatestSenderKey,
                                 @((uintptr_t)view),
                                 OBJC_ASSOCIATION_RETAIN);
    }
}

@end
#endif
