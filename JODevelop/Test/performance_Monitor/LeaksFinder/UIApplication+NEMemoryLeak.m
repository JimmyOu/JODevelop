//
//  UIApplication+NEMemoryLeak.m
//  TestApp
//
//  Created by JimmyOu on 2018/10/9.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "UIApplication+NEMemoryLeak.h"
#import "NSObject+NEMemoryLeak.h"
#import <objc/runtime.h>

#if _INTERNAL_MLF_ENABLED
extern const void *const kLatestSenderKey;
@implementation UIApplication (NEMemoryLeak)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleSEL:@selector(sendAction:to:from:forEvent:) withSEL:@selector(swizzled_sendAction:to:from:forEvent:)];
    });
}

- (BOOL)swizzled_sendAction:(SEL)action to:(id)target from:(id)sender forEvent:(UIEvent *)event {
    objc_setAssociatedObject(self, kLatestSenderKey, @((uintptr_t)sender), OBJC_ASSOCIATION_RETAIN);
    
    return [self swizzled_sendAction:action to:target from:sender forEvent:event];
}


@end
#endif
