//
//  AXDCoolAnimator+MiddlePageFlip.m
//  JODevelop
//
//  Created by JimmyOu on 17/4/27.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "AXDCoolAnimator+MiddlePageFlip.h"
#import "UIView+Snapshot.h"

@implementation AXDCoolAnimator (MiddlePageFlip)

- (void)setMiddlePageFlipToAnimation:(id<UIViewControllerContextTransitioning>)transitionContext direction:(AXDMiddlePageFlipDirection)direction {
    [self p_animation:transitionContext direction:direction duration:self.toDuration];
    
}

- (void)setMiddlePageFlipBackAnimation:(id<UIViewControllerContextTransitioning>)transitionContext direction:(AXDMiddlePageFlipDirection)direction {
    [self p_animation:transitionContext direction:direction duration:self.backDuration];
    
}

- (void)p_animation:(id<UIViewControllerContextTransitioning>)transitionContext direction:(AXDMiddlePageFlipDirection)direction duration:(NSTimeInterval)duration{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *toView = toVC.view;
    UIView *fromView = fromVC.view;
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:toView];
    [containerView sendSubviewToBack:toView];
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -0.002;
    [containerView.layer setSublayerTransform:transform];
    BOOL animation = direction == AXDMiddlePageFlipDirectionLeft || direction == AXDMiddlePageFlipDirectionTop;
    NSArray* toViewSnapshots = [self p_animationSnapFlipView:toView withDirection:direction update:YES];
    UIView* animationToView = toViewSnapshots[animation ? 1 : 0];
    NSArray* fromViewSnapshots = [self p_animationSnapFlipView:fromView withDirection:direction update:NO];
    UIView* animationFromView = fromViewSnapshots[animation ? 0 : 1];
    [self p_addShadowWithDirection:direction fromView:animationFromView toView:animationToView];
    [self p_setAnchorPointWithDirection:direction fromView:animationFromView toView:animationToView];
    BOOL rationAngle = direction == AXDMiddlePageFlipDirectionLeft || direction == AXDMiddlePageFlipDirectionBottom;
    BOOL flipDirection = direction == AXDMiddlePageFlipDirectionLeft || direction == AXDMiddlePageFlipDirectionRight;
    animationToView.layer.transform = CATransform3DMakeRotation(rationAngle ? -M_PI_2 : M_PI_2, flipDirection ? 0.0 : 1.0, !flipDirection ? 0.0 : 1.0, 0.0);
    [UIView animateKeyframesWithDuration:duration
                                   delay:0.0
                                 options:0
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0.0
                                                          relativeDuration:0.5
                                                                animations:^{
                                                                    animationFromView.layer.transform = CATransform3DMakeRotation(rationAngle ? M_PI_2 : -M_PI_2, flipDirection ? 0.0 : 1.0, !flipDirection ? 0.0 : 1.0, 0.0);
                                                                    UIView *shadowView = animationFromView.subviews.lastObject;
                                                                    shadowView.alpha = 1.0f;
                                                                }];
                                  
                                  [UIView addKeyframeWithRelativeStartTime:0.5
                                                          relativeDuration:0.5
                                                                animations:^{
                                                                    animationToView.hidden = NO;
                                                                    animationToView.layer.transform = CATransform3DMakeRotation(rationAngle ? -0.001 : 0.001, flipDirection ? 0.0 : 1.0, !flipDirection ? 0.0 : 1.0, 0.0);
                                                                    UIView *shadowView = animationToView.subviews.lastObject;
                                                                    shadowView.alpha = 0.0f;
                                                                }];
                              } completion:^(BOOL finished) {
                                  [toViewSnapshots makeObjectsPerformSelector:@selector(removeFromSuperview)];
                                  [fromViewSnapshots makeObjectsPerformSelector:@selector(removeFromSuperview)];
                                  [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                              }];
}

- (NSArray<UIView *> *)p_animationSnapFlipView:(UIView *)view withDirection:(AXDMiddlePageFlipDirection)direction update:(BOOL)update{
    UIView *containerView = view.superview;
    CGSize size = view.bounds.size;
    CGRect rectOne = CGRectZero;
    CGRect rectTwo = CGRectZero;
    switch (direction) {
        case AXDMiddlePageFlipDirectionLeft:
        case AXDMiddlePageFlipDirectionRight:{
            rectOne = CGRectMake(0, 0, view.frame.size.width / 2.0f, view.frame.size.height);
            rectTwo = CGRectMake(view.frame.size.width / 2.0f, 0, view.frame.size.width / 2.0f, view.frame.size.height);
            break;
        }
        case AXDMiddlePageFlipDirectionTop:
        case AXDMiddlePageFlipDirectionBottom:{
            rectOne = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height / 2.0f);
            rectTwo = CGRectMake(0, view.frame.size.height / 2.0f, view.frame.size.width, view.frame.size.height / 2.0f);
            break;
        }
    }
    UIView *viewOne = [UIView new];
    viewOne.contentImage = view.snapshotImage;
    UIView *viewTwo = [UIView new];
    viewTwo.contentImage = viewOne.contentImage;
    viewOne.frame = rectOne;
    viewTwo.frame = rectTwo;
    viewOne.layer.contentsRect = CGRectMake(rectOne.origin.x / size.width, rectOne.origin.y / size.height, rectOne.size.width / size.width, rectOne.size.height / size.height);
    viewTwo.layer.contentsRect = CGRectMake(rectTwo.origin.x / size.width, rectTwo.origin.y / size.height, rectTwo.size.width / size.width, rectTwo.size.height / size.height);
    [containerView addSubview:viewOne];
    [containerView addSubview:viewTwo];
    return @[viewOne, viewTwo];
}

- (void)p_setAnchorPointWithDirection:(AXDMiddlePageFlipDirection)direction fromView:(UIView *)fromView toView:(UIView *)toView{
    switch (direction) {
        case AXDMiddlePageFlipDirectionLeft: {
            [self p_setAnchorPointTo:CGPointMake(1, 0.5) forView:fromView];
            [self p_setAnchorPointTo:CGPointMake(0, 0.5) forView:toView];
            break;
        }
        case AXDMiddlePageFlipDirectionRight: {
            [self p_setAnchorPointTo:CGPointMake(0, 0.5) forView:fromView];
            [self p_setAnchorPointTo:CGPointMake(1, 0.5) forView:toView];
            break;
        }
        case AXDMiddlePageFlipDirectionTop: {
            [self p_setAnchorPointTo:CGPointMake(0.5, 1) forView:fromView];
            [self p_setAnchorPointTo:CGPointMake(0.5, 0) forView:toView];
            break;
        }
        case AXDMiddlePageFlipDirectionBottom: {
            [self p_setAnchorPointTo:CGPointMake(0.5, 0) forView:fromView];
            [self p_setAnchorPointTo:CGPointMake(0.5, 1) forView:toView];
            break;
        }
    }
}

- (void)p_setAnchorPointTo:(CGPoint)point forView:(UIView *)view{
    view.frame = CGRectOffset(view.frame, (point.x - view.layer.anchorPoint.x) * view.frame.size.width, (point.y - view.layer.anchorPoint.y) * view.frame.size.height);
    view.layer.anchorPoint = point;
}

- (void)p_addShadowWithDirection:(AXDMiddlePageFlipDirection)direction fromView:(UIView *)fromView toView:(UIView *)toView{
    CGPoint fstartP = CGPointZero;
    CGPoint fendP = CGPointZero;
    CGPoint tstartP = CGPointZero;
    CGPoint tendP = CGPointZero;
    switch (direction) {
        case AXDMiddlePageFlipDirectionLeft: {
            fstartP = CGPointMake(0.0, 0.0);
            fendP = CGPointMake(1.0, 0.0);
            tstartP = CGPointMake(1.0, 0.0);
            tendP = CGPointMake(0.0, 0.0);
            break;
        }
        case AXDMiddlePageFlipDirectionRight: {
            fstartP = CGPointMake(1.0, 0.0);
            fendP = CGPointMake(0.0, 0.0);
            tstartP = CGPointMake(0.0, 0.0);
            tendP = CGPointMake(1.0, 0.0);
            break;
        }
        case AXDMiddlePageFlipDirectionTop: {
            fstartP = CGPointMake(0.0, 0.0);
            fendP = CGPointMake(0.0, 1.0);
            tstartP = CGPointMake(0.0, 1.0);
            tendP = CGPointMake(0.0, 0.0);
            break;
        }
        case AXDMiddlePageFlipDirectionBottom: {
            fstartP = CGPointMake(0.0, 1.0);
            fendP = CGPointMake(0.0, 0.0);
            tstartP = CGPointMake(0.0, 0.0);
            tendP = CGPointMake(0.0, 1.0);
            break;
        }
    }
    [self p_addGrandientLayerWithStartPoint:fstartP endPoint:fendP forView:fromView].alpha = 0.0f;
    [self p_addGrandientLayerWithStartPoint:tstartP endPoint:tendP forView:toView].alpha = 1.0f;
}

- (UIView *)p_addGrandientLayerWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint forView:(UIView *)view{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = view.bounds;
    gradient.colors = @[(id)[UIColor colorWithWhite:0.0 alpha:0.0].CGColor,
                        (id)[UIColor colorWithWhite:0.0 alpha:0.5].CGColor];
    gradient.startPoint = startPoint;
    gradient.endPoint = endPoint;
    UIView* shadowView = [[UIView alloc] initWithFrame:view.bounds];
    [shadowView.layer insertSublayer:gradient atIndex:0];
    [view addSubview:shadowView];
    return shadowView;
}

#pragma mark - <InteractiveTransitionDelegate>

- (void)interactiveTransition:(AXDInteractiveTransition *)interactiveTransition willEndWithSuccessFlag:(BOOL)flag percent:(CGFloat)percent{
    //防止闪烁
    if (!flag && percent < 0) {
        [interactiveTransition updateInteractiveTransition:0.001];
    }
}

@end
