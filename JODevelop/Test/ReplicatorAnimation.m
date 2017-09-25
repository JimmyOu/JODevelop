//
//  ReplicatorAnimation.m
//  JODevelop
//
//  Created by JimmyOu on 17/4/13.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "ReplicatorAnimation.h"

@interface ReplicatorAnimation ()

@end

@implementation ReplicatorAnimation

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
     CAReplicatorLayer * circle = [ReplicatorAnimation replicatorLayer_Circle];
     circle.frame = CGRectMake(30, 70, circle.bounds.size.width, circle.bounds.size.height);
     [self.view.layer addSublayer:circle];
    
    CAReplicatorLayer * wave = [ReplicatorAnimation replicatorLayer_Wave];
    wave.frame = CGRectMake(130, 70, wave.bounds.size.width, wave.bounds.size.height);
    [self.view.layer addSublayer:wave];
    
    CAReplicatorLayer * tri = [ReplicatorAnimation replicatorLayer_Triangle];
    UIView *triView = [[UIView alloc] initWithFrame:CGRectMake(130, 170, tri.bounds.size.width, tri.bounds.size.height)];
    [triView.layer addSublayer:tri];
    [self.view addSubview:triView];
    
    
    CAReplicatorLayer *grid = [ReplicatorAnimation replicatorLayer_Grid];
    grid.frame = CGRectMake(130, 270, wave.bounds.size.width, wave.bounds.size.height);
    [self.view.layer addSublayer:grid];
    
}
+ (CAReplicatorLayer *)replicatorLayer_Circle {
    CAShapeLayer *shape = [CAShapeLayer layer];
    shape.frame = CGRectMake(0, 0, 80, 80);
    shape.path = [UIBezierPath bezierPathWithOvalInRect:shape.bounds].CGPath;
    shape.fillColor = [UIColor redColor].CGColor;
    shape.opacity = 0.0;
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = @[[self opacityAnimation],[self scaleAnimation]];
    animationGroup.duration = 4.0;
    animationGroup.autoreverses = NO;
    animationGroup.repeatCount = HUGE;
    [shape addAnimation:animationGroup forKey:@"animationGroup"];
    
    CAReplicatorLayer *replicatorLayer = [CAReplicatorLayer layer];
    replicatorLayer.frame = CGRectMake(0, 0, 80, 80);
    replicatorLayer.instanceDelay = 0.5;
    replicatorLayer.instanceCount = 8;
    [replicatorLayer addSublayer:shape];
    return replicatorLayer;
}

+ (CAReplicatorLayer *)replicatorLayer_Wave {
    CGFloat between = 5.0;
    CGFloat radius = (100 - 2*between)/3;
    CAShapeLayer *shape = [CAShapeLayer layer];
    shape.fillColor = [UIColor magentaColor].CGColor;
    shape.frame = CGRectMake(0, (100 - radius)/2, radius, radius);
    shape.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, radius, radius)].CGPath;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[[self scaleAnimation1],[self colorAnimation]];
    group.autoreverses = YES;
    group.repeatCount = CGFLOAT_MAX;
    group.duration = 0.6l;
    
    [shape addAnimation:group forKey:@"GroupAnimation"];
    
    CAReplicatorLayer *replicatorLayer = [CAReplicatorLayer layer];
    replicatorLayer.frame = CGRectMake(0, 0, 100, 100);
    replicatorLayer.instanceDelay = 0.2;
    replicatorLayer.instanceCount = 3;
    replicatorLayer.instanceTransform = CATransform3DMakeTranslation(between*2+radius,0,0);
    replicatorLayer.instanceBlueOffset = 0.1;
    replicatorLayer.instanceRedOffset = 0.1;
    replicatorLayer.instanceGreenOffset = 0.1;
    [replicatorLayer addSublayer:shape];
    
    return replicatorLayer;
    
}

+ (CAReplicatorLayer *)replicatorLayer_Triangle {
    
    CGFloat radius = 100/4;
    CGFloat transX = 100 - radius;
    CAShapeLayer *shape = [CAShapeLayer layer];
    shape.frame = CGRectMake(0, 0, radius, radius);
    shape.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, radius, radius)].CGPath;
    shape.strokeColor = [UIColor redColor].CGColor;
    shape.fillColor = [UIColor redColor].CGColor;
    shape.lineWidth = 1;
    [shape addAnimation:[self rotationAnimation:transX] forKey:@"rotateAnimation"];
    
    
    CAReplicatorLayer *replicatorLayer = [CAReplicatorLayer layer];
    replicatorLayer.frame = CGRectMake(0, 0, radius, radius);
    replicatorLayer.instanceDelay = 0.0;
    replicatorLayer.instanceCount = 3;
    CATransform3D trans3D = CATransform3DIdentity;
    
    trans3D = CATransform3DTranslate(trans3D, transX, 0, 0);
    trans3D = CATransform3DRotate(trans3D,120.0*M_PI/180.0 , 0.0, 0.0, 1.0);
    replicatorLayer.instanceTransform = trans3D;
    [replicatorLayer addSublayer:shape];
    
    
    return replicatorLayer;

}

+ (CAReplicatorLayer *)replicatorLayer_Grid{
    NSInteger column = 3;
    CGFloat between = 5.0;
    CGFloat radius = (100 - between * (column - 1))/column;
    CAShapeLayer *shape = [CAShapeLayer layer];
    shape.frame = CGRectMake(0, 0, radius, radius);
    shape.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, radius, radius)].CGPath;
    shape.fillColor = [UIColor redColor].CGColor;
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = @[[self scaleAnimation1], [self opacityAnimation]];
    animationGroup.duration = 1.0;
    animationGroup.autoreverses = YES;
    animationGroup.repeatCount = HUGE;
    [shape addAnimation:animationGroup forKey:@"groupAnimation"];
    
    CAReplicatorLayer *replicatorLayerX = [CAReplicatorLayer layer];
    replicatorLayerX.backgroundColor = [UIColor lightGrayColor].CGColor;
    replicatorLayerX.frame = CGRectMake(0, 0, 100, 100);
    replicatorLayerX.instanceDelay = 0.3;
    replicatorLayerX.instanceCount = column;
    replicatorLayerX.instanceTransform = CATransform3DTranslate(CATransform3DIdentity, radius+between, 0, 0);
    [replicatorLayerX addSublayer:shape];
    
    CAReplicatorLayer *replicatorLayerY = [CAReplicatorLayer layer];
    replicatorLayerY.backgroundColor = [UIColor blueColor].CGColor;
    replicatorLayerY.frame = CGRectMake(0, 0, 100, 100);
    replicatorLayerY.instanceDelay = 0.3;
    replicatorLayerY.instanceCount = column;
    replicatorLayerY.instanceTransform = CATransform3DTranslate(CATransform3DIdentity, 0, radius+between, 0);
    [replicatorLayerY addSublayer:replicatorLayerX];
    
    return replicatorLayerY;
}



#pragma mark -animtion

+ (CABasicAnimation *)opacityAnimation {
    
    CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacity.fromValue = @(1.0);
    opacity.toValue = @(0.0);
    return opacity;
}

+ (CABasicAnimation *)scaleAnimation {
    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform"];
    scale.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0, 0, 0)];
    scale.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    return scale;
}

+ (CABasicAnimation *)scaleAnimation1 {
    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform"];
    scale.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 0.0)];
    scale.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.2, 0.2, 0)];

    return scale;
}
+ (CABasicAnimation *)colorAnimation {
    CABasicAnimation *tint = [CABasicAnimation animationWithKeyPath:@"fillColor"];
    tint.fromValue = (__bridge id _Nullable)([UIColor magentaColor].CGColor);
    tint.toValue = (__bridge id _Nullable)([UIColor cyanColor].CGColor);
    return tint;
}

+ (CABasicAnimation *)rotationAnimation:(CGFloat)transX {
    CABasicAnimation *transform = [CABasicAnimation animationWithKeyPath:@"transform"];
    CATransform3D fromValue = CATransform3DRotate(CATransform3DIdentity, 0.0, 0.0, 0.0, 0.0);
    transform.fromValue = [NSValue valueWithCATransform3D:fromValue];
    
    CATransform3D toValue = CATransform3DTranslate(CATransform3DIdentity, transX, 0.0, 0.0);
    toValue = CATransform3DRotate(toValue,120.0*M_PI/180.0, 0.0, 0.0, 1.0);
    
    transform.toValue = [NSValue valueWithCATransform3D:toValue];
    transform.autoreverses = NO;
    transform.repeatCount = HUGE;
    transform.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transform.duration = 0.8;
    return transform;
}
@end
