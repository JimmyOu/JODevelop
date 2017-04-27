//
//  AXDFilterTransitionView.m
//  JODevelop
//
//  Created by JimmyOu on 17/4/27.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "AXDFilterTransitionView.h"

@interface _AXDDisplayRatioLayer : CALayer

@property (nonatomic, assign) CGFloat ratio;
@property (nonatomic, copy) void(^ratioUpdating)(CGFloat ratio);

@end

@implementation _AXDDisplayRatioLayer

@dynamic ratio;

+ (BOOL)needsDisplayForKey:(NSString *)key{
    if ([key isEqualToString:@"ratio"]) {
        return YES;
    }
    return [super needsDisplayForKey:key];
}

- (void)display{
    if (_ratioUpdating) {
        _ratioUpdating([[self presentationLayer] ratio]);
    }
}

@end

@interface AXDFilterTransitionView()<GLKViewDelegate, CAAnimationDelegate>

@property (nonatomic, weak) _AXDDisplayRatioLayer *ratioLayer;
@property (nonatomic, assign) CGFloat ratio;
@property (nonatomic, copy) CIImage *(^animationConfig)(CGFloat ratio, CIImage *fromImg, CIImage * toImg, CIFilter * filter);
@property (nonatomic, copy) void(^completion)(BOOL finish);
@property (nonatomic, assign) CGFloat lastRatio;


@end

@implementation AXDFilterTransitionView{
    CIImage *_fromImg;
    CIImage *_toImg;
    CIContext *_saveContext;
    CGRect _imgRect;
    CIVector *_vector;
}


- (instancetype)initWithFrame:(CGRect)frame
                    fromImage:(UIImage *)fromImage
                      toImage:(UIImage *)toImage{
    self = [super initWithFrame:frame];
    if (!self) return nil;
    _fromImg = [CIImage imageWithCGImage:fromImage.CGImage];
    _toImg = [CIImage imageWithCGImage:toImage.CGImage];
    _vector = [CIVector vectorWithX:0 Y:0 Z:fromImage.size.width * fromImage.scale W:fromImage.size.height * fromImage.scale];
    CGFloat width = fromImage.size.width * fromImage.scale;
    CGFloat height = fromImage.size.height * fromImage.scale;
    _imgRect = CGRectMake(0, 0, width, height);
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    _saveContext = [CIContext contextWithEAGLContext:self.context];
    _AXDDisplayRatioLayer *layer = [_AXDDisplayRatioLayer new];
    _ratioLayer = layer;
    _ratioLayer.frame = CGRectMake(0, 0, 100, 100);
    __weak typeof(self)weakSelf = self;
    _ratioLayer.ratioUpdating = ^(CGFloat ratio){
        weakSelf.ratio = ratio;
        [weakSelf setNeedsDisplay];
    };
    [self.layer insertSublayer:_ratioLayer atIndex:0];
    self.delegate = self;
    return self;
}

- (CAAnimation *)p_filterBasicAnimation{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"ratio"];
    animation.fromValue = @0;
    animation.toValue = @1;
    return animation;
}

- (CIImage *)p_filterBasicImageForTransition
{
    [_filter setValue:_fromImg forKey:kCIInputImageKey];
    [_filter setValue:_toImg forKey:kCIInputTargetImageKey];
    [_filter setValue:@(_ratio) forKey:kCIInputTimeKey];
    CIImage *transitionImage = [_filter valueForKey:kCIOutputImageKey];
    return transitionImage;
}

- (CIImage *)p_filterBlurImageForTransition{
    CGFloat radius = 0;
    if (_ratio < 0.5) {
        [_filter setValue:_fromImg forKey:kCIInputImageKey];
        radius = _ratio * 0.5 * 200;
    }
    else {
        [_filter setValue:_toImg forKey:kCIInputImageKey];
        radius = (1.0 - _ratio) * 200;
    }
    [_filter setValue:@(radius) forKey:kCIInputRadiusKey];
    CIImage *transitionImage = [_filter valueForKey:kCIOutputImageKey];
    return transitionImage;
}
- (void)p_filterViewDoAnimation:(NSTimeInterval)duration completion:(void (^ __nullable)(BOOL finished))completion{
    _completion = completion;
    CAAnimation *animation = [self p_filterBasicAnimation];
    animation.duration = duration;
    animation.delegate = self;
    [_ratioLayer addAnimation:animation forKey:@"xw_filterAnimation"];
}

#pragma mark - <GLKViewDelegate>

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    if (_ratio >= 1 || _ratio <= 0) {
        _ratio = _lastRatio > 0.5 ? 1 : 0;
    }
    if (!_filter) return;
    CIImage *image = _blurType ? [self p_filterBlurImageForTransition] : [self p_filterBasicImageForTransition];
    if (!image) return;
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGRect nativeBounds = [[UIScreen mainScreen] nativeBounds];
    CGRect destRect = CGRectMake(0, self.bounds.size.height * scale - _imgRect.size.height,
                                 nativeBounds.size.width,
                                 nativeBounds.size.height);
    [_saveContext drawImage:image
                     inRect:destRect
                   fromRect:_imgRect];
    _lastRatio = _ratio;
}


#pragma mark - <CAAnimationDelegate>

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (_completion) {
        _completion(flag);
    }
    _completion = nil;
}

+ (void)animationWith:(AXDFilterTransitionView *)filterView duration:(NSTimeInterval)duration completion:(void (^ __nullable)(BOOL finished))completion {
    [filterView p_filterViewDoAnimation:duration completion:completion];
}

- (CAAnimation *)xw_getInnerAnimation {
    return [self p_filterBasicAnimation];
}

- (CIVector *)xw_getInnerVector {
    return _vector;
}


@end
