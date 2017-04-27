//
//  AXDBaseTransitionAnimator.m
//  JODevelop
//
//  Created by JimmyOu on 17/4/27.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "AXDBaseTransitionAnimator.h"
#import <objc/runtime.h>
#import <objc/message.h>

#pragma mark - 私有转场动画管理者

typedef void(^AXDTransitionAnimationConfig)(id<UIViewControllerContextTransitioning> transitionContext);

@interface _AXDTransitionObject : NSObject<UIViewControllerAnimatedTransitioning>


- (instancetype)_initObjectWithDuration:(NSTimeInterval)duration animationBlock:(void(^)(id<UIViewControllerContextTransitioning> transitionContext)) config;

@end

@implementation _AXDTransitionObject{
    NSTimeInterval _duration;
    AXDTransitionAnimationConfig _config;
}

- (instancetype)_initObjectWithDuration:(NSTimeInterval)duration animationBlock:(AXDTransitionAnimationConfig)config{
    self = [super init];
    if (self) {
        _duration = duration;
        _config = config;
    }
    return self;
}

#pragma mark - <UIViewControllerAnimatedTransitioning>

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return _duration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    if (_config) {
        _config(transitionContext);
    }
    
}

@end

@interface AXDBaseTransitionAnimator()

@property (nonatomic, strong) _AXDTransitionObject *toTransition;
@property (nonatomic, strong) _AXDTransitionObject *backTranstion;
@property (nonatomic, strong) AXDInteractiveTransition *toInteractive;
@property (nonatomic, strong) AXDInteractiveTransition *backInteractive;
@property (nonatomic, assign) UINavigationControllerOperation operation;
@property (nonatomic, assign) BOOL toType;

@end

@implementation AXDBaseTransitionAnimator


- (instancetype)init
{
    self = [super init];
    if (self) {
        _toDuration = _backDuration = kAXDTransitionAnimationTimeDuration;
    }
    return self;
}

- (_AXDTransitionObject *)toTransition{
    if (!_toTransition) {
        __weak typeof(self)weakSelf = self;
        _toTransition = [[_AXDTransitionObject alloc] _initObjectWithDuration:_toDuration animationBlock:^(id<UIViewControllerContextTransitioning> transitionContext) {
            UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
            UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
            UIView *toView = toVC.view;
            UIView *fromView = fromVC.view;
            [weakSelf setToAnimation:transitionContext fromVC:fromVC toVC:toVC fromView:fromView toView:toView];
        }];
    }
    return _toTransition;
}

- (_AXDTransitionObject *)backTranstion{
    if (!_backTranstion) {
        __weak typeof(self)weakSelf = self;
        _backTranstion = [[_AXDTransitionObject alloc] _initObjectWithDuration:_backDuration animationBlock:^(id<UIViewControllerContextTransitioning> transitionContext) {
            UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
            UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
            UIView *toView = toVC.view;
            UIView *fromView = fromVC.view;
            [weakSelf setBackAnimation:transitionContext fromVC:fromVC toVC:toVC fromView:fromView toView:toView];
        }];
    }
    return _backTranstion;
}

- (void)setToInteractive:(AXDInteractiveTransition *)toInteractive{
    _toInteractive = toInteractive;
    toInteractive.delegate = self;
    toInteractive.timerEnable = _needInteractiveTimer;
    
}

- (void)setBackInteractive:(AXDInteractiveTransition *)backInteractive{
    _backInteractive = backInteractive;
    backInteractive.delegate = self;
    backInteractive.timerEnable = _needInteractiveTimer;
    
}


- (void)setToAnimation:(id<UIViewControllerContextTransitioning>)transitionContext fromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC fromView:(UIView *)fromView toView:(UIView *)toView {
    
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];

}

- (void)setBackAnimation:(id<UIViewControllerContextTransitioning>)transitionContext fromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC fromView:(UIView *)fromView toView:(UIView *)toView {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

#pragma mark - <UIViewControllerTransitioningDelegate>

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    return self.toTransition;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    return self.backTranstion;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator{
    return self.backInteractive.interation ? self.backInteractive : nil;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id<UIViewControllerAnimatedTransitioning>)animator{
    return self.toInteractive.interation ? self.toInteractive : nil;
}

#pragma mark - <UINavigationControllerDelegate>

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC{
    _operation = operation;
    return operation == UINavigationControllerOperationPush ? self.toTransition : self.backTranstion;
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController{
    AXDInteractiveTransition *inter = _operation == UINavigationControllerOperationPush ? self.toInteractive : self.backInteractive;
    return inter.interation ? inter : nil;
}



@end
