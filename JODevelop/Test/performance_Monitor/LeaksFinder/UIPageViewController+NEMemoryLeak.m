//
//  UIPageViewController+NEMemoryLeak.m
//  TestApp
//
//  Created by JimmyOu on 2018/10/9.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "UIPageViewController+NEMemoryLeak.h"
#import "NSObject+NEMemoryLeak.h"
#if _INTERNAL_MLF_ENABLED
@implementation UIPageViewController (NEMemoryLeak)

- (BOOL)willDealloc {
    if (![super willDealloc]) {
        return NO;
    }
    
    [self willReleaseChildren:self.viewControllers];
    
    return YES;
}
@end
#endif
