//
//  UIViewController+AXDTransition.m
//  JODevelop
//
//  Created by JimmyOu on 17/4/27.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "UIViewController+AXDTransition.h"
#import <objc/runtime.h>

@implementation UIViewController (AXDTransition)

- (void)axd_presentViewController:(UIViewController *)viewController withAnimator:(AXDBaseTransitionAnimator *)animator {
    if (!viewController) return;
    if (animator) {
        viewController.transitioningDelegate = animator;
    }
    AXDInteractiveTransition *toInteractive = objc_getAssociatedObject(self, &kAXDToInteractiveKey);
    if (toInteractive) {
        [animator setValue:toInteractive forKey:@"toInteractive"];
    }
    objc_setAssociatedObject(viewController, &kAXDAnimatorKey, animator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)axd_registerToInteractiveTransitionWithDirection:(AXDInteractiveTransitionGestureDirection)direction transitonBlock:(void (^)(CGPoint))tansitionConfig edgeSpacing:(CGFloat)edgeSpacing {
    
    if (!tansitionConfig) return;
    AXDInteractiveTransition *interactive = [AXDInteractiveTransition interactiveTransitionWithDirection:direction config:tansitionConfig edgeSpacing:edgeSpacing];
    [interactive addPanGestureForView:self.view];
    objc_setAssociatedObject(self, &kAXDToInteractiveKey, interactive, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

}

- (void)axd_registerBackInteractiveTransitionWithDirection:(AXDInteractiveTransitionGestureDirection)direction transitonBlock:(void (^)(CGPoint))tansitionConfig edgeSpacing:(CGFloat)edgeSpacing {
    if (!tansitionConfig) return;
    AXDInteractiveTransition *interactive = [AXDInteractiveTransition interactiveTransitionWithDirection:direction config:tansitionConfig edgeSpacing:edgeSpacing];
    [interactive addPanGestureForView:self.view];
    AXDBaseTransitionAnimator *animator = objc_getAssociatedObject(self, &kAXDAnimatorKey);
    if (animator) {
        [animator setValue:interactive forKey:@"backInteractive"];
    }
}

@end

NSString *const kAXDToInteractiveKey = @"kAXDToInteractiveKey";
NSString *const kAXDAnimatorKey = @"kAXDAnimatorKey";

