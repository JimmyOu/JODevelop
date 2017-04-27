//
//  UINavigationController+AXDTransition.m
//  JODevelop
//
//  Created by JimmyOu on 17/4/27.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "UINavigationController+AXDTransition.h"
#import "UIViewController+AXDTransition.h"
#import "AXDBaseTransitionAnimator.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation UINavigationController (AXDTransition)

- (void)axd_pushViewController:(UIViewController *)viewController withAnimator:(AXDBaseTransitionAnimator *)animator {
    if (!viewController) return;
    AXDInteractiveTransition *toInteractive = objc_getAssociatedObject(self.topViewController, &kAXDToInteractiveKey);
    if (toInteractive) {
        [animator setValue:toInteractive forKey:@"toInteractive"];
    }
    if (animator) {
        self.delegate = animator;
        objc_setAssociatedObject(viewController, &kAXDAnimatorKey, animator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [self pushViewController:viewController animated:YES];
}

@end
