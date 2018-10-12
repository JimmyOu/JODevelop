//
//  UINavigationController+NEMemoryLeak.m
//  TestApp
//
//  Created by JimmyOu on 2018/10/9.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "UINavigationController+NEMemoryLeak.h"
#import <objc/runtime.h>
#import "NSObject+NEMemoryLeak.h"
#if _INTERNAL_MLF_ENABLED
static const void *const kPoppedDetailVCKey = &kPoppedDetailVCKey;
extern const void *const kHasBeenPoppedKey;
@implementation UINavigationController (NEMemoryLeak)


+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleSEL:@selector(pushViewController:animated:) withSEL:@selector(swizzled_pushViewController:animated:)];
        [self swizzleSEL:@selector(popViewControllerAnimated:) withSEL:@selector(swizzled_popViewControllerAnimated:)];
        [self swizzleSEL:@selector(popToViewController:animated:) withSEL:@selector(swizzled_popToViewController:animated:)];
        [self swizzleSEL:@selector(popToRootViewControllerAnimated:) withSEL:@selector(swizzled_popToRootViewControllerAnimated:)];
    });
}

- (void)swizzled_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.splitViewController) {
        id detailViewController = objc_getAssociatedObject(self, kPoppedDetailVCKey);
        if ([detailViewController isKindOfClass:[UIViewController class]]) {
            [detailViewController willDealloc];
            objc_setAssociatedObject(self, kPoppedDetailVCKey, nil, OBJC_ASSOCIATION_RETAIN);
        }
    }
    
    [self swizzled_pushViewController:viewController animated:animated];
}

- (UIViewController *)swizzled_popViewControllerAnimated:(BOOL)animated {
    UIViewController *poppedViewController = [self swizzled_popViewControllerAnimated:animated];
    
    if (!poppedViewController) {
        return nil;
    }
    
    // Detail VC in UISplitViewController is not dealloced until another detail VC is shown
    if (self.splitViewController &&
        self.splitViewController.viewControllers.firstObject == self &&
        self.splitViewController == poppedViewController.splitViewController) {
        objc_setAssociatedObject(self, kPoppedDetailVCKey, poppedViewController, OBJC_ASSOCIATION_RETAIN);
        return poppedViewController;
    }
    
    // VC is not dealloced until disappear when popped using a left-edge swipe gesture
    objc_setAssociatedObject(poppedViewController, kHasBeenPoppedKey, @(YES), OBJC_ASSOCIATION_RETAIN);
    
    return poppedViewController;
}

- (NSArray<UIViewController *> *)swizzled_popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSArray<UIViewController *> *poppedViewControllers = [self swizzled_popToViewController:viewController animated:animated];
    
    for (UIViewController *viewController in poppedViewControllers) {
        [viewController willDealloc];
    }
    
    return poppedViewControllers;
}

- (NSArray<UIViewController *> *)swizzled_popToRootViewControllerAnimated:(BOOL)animated {
    NSArray<UIViewController *> *poppedViewControllers = [self swizzled_popToRootViewControllerAnimated:animated];
    
    for (UIViewController *viewController in poppedViewControllers) {
        [viewController willDealloc];
    }
    
    return poppedViewControllers;
}

- (BOOL)willDealloc {
    if (![super willDealloc]) {
        return NO;
    }
    
    [self willReleaseChildren:self.viewControllers];
    
    return YES;
}


@end
#endif
