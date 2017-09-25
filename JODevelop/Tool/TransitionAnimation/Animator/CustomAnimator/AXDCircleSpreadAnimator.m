//
//  AXDCircleSpreadAnimator.m
//  JODevelop
//
//  Created by JimmyOu on 17/4/27.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "AXDCircleSpreadAnimator.h"

@interface AXDCircleSpreadAnimator ()<CAAnimationDelegate>

@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGFloat startRadius;
@property (nonatomic, strong) UIBezierPath *startPath;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) CAShapeLayer *maskLayer;
@property (nonatomic, strong) id<UIViewControllerContextTransitioning> transitionContext;


@end
@implementation AXDCircleSpreadAnimator

+ (instancetype)animatorWithStartCenter:(CGPoint)point radius:(CGFloat)radius {
    return [[self alloc] _initWithStartCenter:point radius:radius];
}

- (instancetype)_initWithStartCenter:(CGPoint)point radius:(CGFloat)radius
{
    self = [super init];
    if (self) {
        _startPoint = point;
        _startRadius = radius == 0 ? 0.01 : radius;
        self.needInteractiveTimer = YES;
    }
    return self;
}
- (void)setToAnimation:(id<UIViewControllerContextTransitioning>)transitionContext fromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC fromView:(UIView *)fromView toView:(UIView *)toView {
    
    self.transitionContext = transitionContext;
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:toVC.view];
    UIBezierPath *startCycle =  [UIBezierPath bezierPathWithArcCenter:self.startPoint radius:self.startRadius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    CGFloat x = self.startPoint.x;
    CGFloat y = self.startPoint.y;
    CGFloat endX = MAX(x, containerView.frame.size.width - x);
    CGFloat endY = MAX(y, containerView.frame.size.height - y);
    CGFloat radius = sqrtf(pow(endX, 2) + pow(endY, 2));
    UIBezierPath *endCycle = [UIBezierPath bezierPathWithArcCenter:self.startPoint radius:radius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = endCycle.CGPath;
    toVC.view.layer.mask = maskLayer;
    self.startPath = startCycle;
    self.maskLayer = maskLayer;
    self.containerView = containerView;
    CABasicAnimation *maskLayerAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    maskLayerAnimation.fromValue = (__bridge id)(startCycle.CGPath);
    maskLayerAnimation.toValue = (__bridge id)((endCycle.CGPath));
    maskLayerAnimation.duration = self.toDuration;
    maskLayerAnimation.delegate = self;
    [maskLayer addAnimation:maskLayerAnimation forKey:@"maskLayerAnimation"];

}

- (void)setBackAnimation:(id<UIViewControllerContextTransitioning>)transitionContext fromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC fromView:(UIView *)fromView toView:(UIView *)toView {
    
    self.transitionContext = transitionContext;
    UIView *containerView = [transitionContext containerView];
    [containerView insertSubview:toVC.view atIndex:0];
    UIBezierPath *endCycle = [UIBezierPath bezierPathWithArcCenter:self.startPoint radius:self.startRadius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    CAShapeLayer *maskLayer = (CAShapeLayer *)fromVC.view.layer.mask;
    CGPathRef startPath = maskLayer.path;
    maskLayer.path = endCycle.CGPath;
    self.maskLayer = maskLayer;
    self.startPath = [UIBezierPath bezierPathWithCGPath:startPath];
    self.containerView = containerView;
    CABasicAnimation *maskLayerAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    maskLayerAnimation.fromValue = (__bridge id)(startPath);
    maskLayerAnimation.toValue = (__bridge id)(endCycle.CGPath);
    maskLayerAnimation.duration = self.backDuration;
    maskLayerAnimation.delegate = self;
    [maskLayer addAnimation:maskLayerAnimation forKey:@"maskLayerAnimation"];
}


- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{

    [self.transitionContext completeTransition:![self.transitionContext transitionWasCancelled]];
    self.transitionContext = nil;
}

- (void)interactiveTransitionWillBeginTimerAnimation:(AXDInteractiveTransition *)interactiveTransition {
    _containerView.userInteractionEnabled = NO;
}

- (void)interactiveTransition:(AXDInteractiveTransition *)interactiveTransition willEndWithSuccessFlag:(BOOL)flag percent:(CGFloat)percent{
    if (!flag) {
        //防止失败后的闪烁
        _maskLayer.path = _startPath.CGPath;
    }
    _containerView.userInteractionEnabled = YES;
}

@end
