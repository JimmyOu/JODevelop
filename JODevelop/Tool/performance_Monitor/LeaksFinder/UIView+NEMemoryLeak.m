//
//  UIView+NEMemoryLeak.m
//  TestApp
//
//  Created by JimmyOu on 2018/10/9.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "UIView+NEMemoryLeak.h"
#import "NSObject+NEMemoryLeak.h"
#if _INTERNAL_MLF_ENABLED
@implementation UIView (NEMemoryLeak)

- (BOOL)willDealloc {
    if (![super willDealloc]) {
        return NO;
    }
    
    [self willReleaseChildren:self.subviews];
    
    return YES;
}

@end
#endif
