//
//  JOShimmeringLayer.m
//  模块化Demo
//
//  Created by JimmyOu on 17/3/30.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "JOShimmeringLayer.h"
#import <UIKit/UIColor.h>
#import <UIKit/UIGeometry.h>

#if TARGET_IPHONE_SIMULATOR
UIKIT_EXTERN float UIAnimationDragCoefficient(void); // UIKit private drag coeffient, use judiciously
#endif

static CGFloat FBShimmeringLayerDragCoefficient(void)
{
#if TARGET_IPHONE_SIMULATOR
    return UIAnimationDragCoefficient();
#else
    return 1.0;
#endif
}

static void FBShimmeringLayerAnimationApplyDragCoefficient(CAAnimation *animation)
{
    CGFloat k = FBShimmeringLayerDragCoefficient();
    
    if (k != 0 && k != 1) {
        animation.speed = 1 / k;
    }
}

// animations keys
static NSString *const kJOShimmerSlideAnimationKey = @"slide";
static NSString *const kJOFadeAnimationKey = @"fade";
static NSString *const kJOEndFadeAnimationKey = @"fade-end";

static CABasicAnimation *fade_animation(CALayer *layer, CGFloat opacity, CFTimeInterval duration)
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = @([(layer.presentationLayer ?: layer) opacity]);
    animation.toValue = @(opacity);
    animation.fillMode = kCAFillModeBoth;
    animation.removedOnCompletion = NO;
    animation.duration = duration;
    FBShimmeringLayerAnimationApplyDragCoefficient(animation);
    return animation;
}
static CABasicAnimation *shimmer_slide_animation(CFTimeInterval duration, JOShimmerDirection direction)
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.toValue = [NSValue valueWithCGPoint:CGPointZero];
    animation.duration = duration;
    animation.repeatCount = HUGE_VALF;
    FBShimmeringLayerAnimationApplyDragCoefficient(animation);
    if (direction == JOShimmerDirectionLeft ||
        direction == JOShimmerDirectionUp) {
        animation.speed = -fabsf(animation.speed);
    }
    return animation;
}

// take a shimmer slide animation and turns into repeating
static CAAnimation *shimmer_slide_repeat(CAAnimation *a, CFTimeInterval duration, JOShimmerDirection direction)
{
    CAAnimation *anim = [a copy];
    anim.repeatCount = HUGE_VALF;
    anim.duration = duration;
    anim.speed = (direction == JOShimmerDirectionRight || direction == JOShimmerDirectionDown) ? fabsf(anim.speed) : -fabsf(anim.speed);
    return anim;
}

// take a shimmer slide animation and turns into finish
static CAAnimation *shimmer_slide_finish(CAAnimation *a)
{
    CAAnimation *anim = [a copy];
    anim.repeatCount = 0;
    return anim;
}

@interface JOShimmeringMaskLayer : CAGradientLayer
@property (nonatomic, readonly) CALayer *fadeLayer;
@end

@implementation JOShimmeringMaskLayer
- (instancetype)init
{
    self = [super init];
    if (self) {
        _fadeLayer = [[CALayer alloc] init];
        _fadeLayer.backgroundColor = [UIColor whiteColor].CGColor;
        [self addSublayer:_fadeLayer];
    }
    return self;
}
- (void)layoutSublayers {
    [super layoutSublayers];
    CGRect r = self.bounds;
    _fadeLayer.bounds = r;
    _fadeLayer.position = CGPointMake(CGRectGetMidX(r), CGRectGetMidY(r));
}
@end

@interface JOShimmeringLayer ()
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
<CALayerDelegate, CAAnimationDelegate>
#endif

@property (nonatomic, strong) JOShimmeringMaskLayer *maskLayer;
@end
@implementation JOShimmeringLayer
{
    CALayer *_contentLayer;
}

@synthesize shimmering = _shimmering;
@synthesize shimmeringPauseDuration = _shimmeringPauseDuration;
@synthesize shimmeringAnimationOpacity = _shimmeringAnimationOpacity;
@synthesize shimmeringOpacity = _shimmeringOpacity;
@synthesize shimmeringSpeed = _shimmeringSpeed;
@synthesize shimmeringHighlightLength = _shimmeringHighlightLength;
@synthesize shimmeringDirection = _shimmeringDirection;
@synthesize shimmeringFadeTime = _shimmeringFadeTime;
@synthesize shimmeringBeginFadeDuration = _shimmeringBeginFadeDuration;
@synthesize shimmeringEndFadeDuration = _shimmeringEndFadeDuration;
@synthesize shimmeringBeginTime = _shimmeringBeginTime;

- (instancetype)init
{
    self = [super init];
    if (self) {
        // default configuration
        _shimmeringPauseDuration = 0.4;
        _shimmeringSpeed = 230.0;
        _shimmeringHighlightLength = 1.0;
        _shimmeringAnimationOpacity = 0.5;
        _shimmeringOpacity = 1.0;
        _shimmeringDirection = JOShimmerDirectionRight;
        _shimmeringBeginFadeDuration = 0.1;
        _shimmeringEndFadeDuration = 0.3;
        _shimmeringBeginTime = JOShimmerDefaultBeginTime;
    }
    return self;
}

#pragma mark - Properties

- (void)setContentLayer:(CALayer *)contentLayer {
    
    // reset mask
    self.maskLayer = nil;
    
    // note content layer and add for display
    _contentLayer = contentLayer;
    self.sublayers = contentLayer ? @[contentLayer] : nil;
    
    // update shimmering animation
    [self _updateShimmering];
}
- (void)setShimmering:(BOOL)shimmering {
    if (shimmering != _shimmering) {
        _shimmering = shimmering;
        [self _updateShimmering];
    }
}
- (void)setShimmeringSpeed:(CGFloat)shimmeringSpeed {
    if (_shimmeringSpeed != shimmeringSpeed) {
        _shimmeringSpeed = shimmeringSpeed;
        [self _updateShimmering];
    }
}
- (void)setShimmeringHighlightLength:(CGFloat)shimmeringHighlightLength {
    if (_shimmeringHighlightLength != shimmeringHighlightLength) {
        _shimmeringHighlightLength = shimmeringHighlightLength;
        [self _updateShimmering];
    }
}
- (void)setShimmeringDirection:(JOShimmerDirection)shimmeringDirection {
    if (_shimmeringDirection != shimmeringDirection) {
        _shimmeringDirection = shimmeringDirection;
        [self _updateShimmering];
    }
}
- (void)setShimmeringPauseDuration:(CFTimeInterval)duration
{
    if (duration != _shimmeringPauseDuration) {
        _shimmeringPauseDuration = duration;
        [self _updateShimmering];
    }
}

- (void)setShimmeringAnimationOpacity:(CGFloat)shimmeringAnimationOpacity
{
    if (shimmeringAnimationOpacity != _shimmeringAnimationOpacity) {
        _shimmeringAnimationOpacity = shimmeringAnimationOpacity;
        [self _updateMaskColors];
    }
}

- (void)setShimmeringOpacity:(CGFloat)shimmeringOpacity
{
    if (shimmeringOpacity != _shimmeringOpacity) {
        _shimmeringOpacity = shimmeringOpacity;
        [self _updateMaskColors];
    }
}

- (void)setShimmeringBeginTime:(CFTimeInterval)beginTime
{
    if (beginTime != _shimmeringBeginTime) {
        _shimmeringBeginTime = beginTime;
        [self _updateShimmering];
    }
}

- (void)layoutSublayers {
    [super layoutSublayers];
    CGRect r = self.bounds;
    _contentLayer.anchorPoint = CGPointMake(0.5, 0.5);
    _contentLayer.bounds = r;
    _contentLayer.position = CGPointMake(CGRectGetMidX(r), CGRectGetMidY(r));
    if (nil != _maskLayer) {
        [self _updateMaskLayout];
    }
}
- (void)setBounds:(CGRect)bounds {
    CGRect oldBounds = self.bounds;
    [super setBounds:bounds];
    if (!CGRectEqualToRect(oldBounds, bounds)) {
        [self _updateShimmering];
    }
}

#pragma mark - private
- (void)_clearMask {
    if (nil == _maskLayer) {
        return;
    }
    //store old Transaction state
    BOOL disableAction = [CATransaction disableActions];
    //forbiden animation
    [CATransaction setDisableActions:YES];
    self.maskLayer = nil;
    _contentLayer.mask = nil;
    
    //reStore old Transaction state
    [CATransaction setDisableActions:disableAction];
}
- (void)_createMaskIfNeeded {
    if (_shimmering && !_maskLayer) {
        _maskLayer = [JOShimmeringMaskLayer layer];
        _maskLayer.delegate = self;
        _contentLayer.mask = _maskLayer;
        [self _updateMaskColors];
        [self _updateMaskLayout];
    }
}

- (void)_updateMaskColors {
    if (nil == _maskLayer) {
        return;
    }
    // We create a gradient to be used as a mask.
    // In a mask, the colors do not matter, it's the alpha that decides the degree of masking.
    UIColor *maskedColor = [UIColor colorWithWhite:1.0 alpha:_shimmeringOpacity];
    UIColor *unmaskedColor = [UIColor colorWithWhite:1.0 alpha:_shimmeringAnimationOpacity];
    
    // Create a gradient from masked to unmasked to masked.
    _maskLayer.colors = @[(__bridge id)maskedColor.CGColor, (__bridge id)unmaskedColor.CGColor,(__bridge id)maskedColor.CGColor];
    
}
- (void)_updateMaskLayout
{
    // Everything outside the mask layer is hidden, so we need to create a mask long enough for the shimmered layer to be always covered by the mask.
    CGFloat length = 0.0f;
    if (_shimmeringDirection == JOShimmerDirectionDown ||
        _shimmeringDirection == JOShimmerDirectionUp) {
        length = CGRectGetHeight(_contentLayer.bounds);
    } else {
        length = CGRectGetWidth(_contentLayer.bounds);
    }
    if (0 == length) {
        return;
    }
    
    // extra distance for the gradient to travel during the pause.
    CGFloat extraDistance = length + _shimmeringSpeed * _shimmeringPauseDuration;
    
    // compute how far the shimmering goes
    CGFloat fullShimmerLength = length * 3.0f + extraDistance;
    CGFloat travelDistance = length * 2.0f + extraDistance;
    
    // position the gradient for the desired width
    CGFloat highlightOutsideLength = (1.0 - _shimmeringHighlightLength) / 2.0;
    _maskLayer.locations = @[@(highlightOutsideLength),
                             @(0.5),
                             @(1.0 - highlightOutsideLength)];
    
    CGFloat startPoint = (length + extraDistance) / fullShimmerLength;
    CGFloat endPoint = travelDistance / fullShimmerLength;
    
    // position for the start of the animation
    _maskLayer.anchorPoint = CGPointZero;
    if (_shimmeringDirection == JOShimmerDirectionDown ||
        _shimmeringDirection == JOShimmerDirectionUp) {
        _maskLayer.startPoint = CGPointMake(0.0, startPoint);
        _maskLayer.endPoint = CGPointMake(0.0, endPoint);
        _maskLayer.position = CGPointMake(0.0, -travelDistance);
        _maskLayer.bounds = CGRectMake(0.0, 0.0, CGRectGetWidth(_contentLayer.bounds), fullShimmerLength);
    } else {
        _maskLayer.startPoint = CGPointMake(startPoint, 0.0);
        _maskLayer.endPoint = CGPointMake(endPoint, 0.0);
        _maskLayer.position = CGPointMake(-travelDistance, 0.0);
        _maskLayer.bounds = CGRectMake(0.0, 0.0, fullShimmerLength, CGRectGetHeight(_contentLayer.bounds));
    }
}


- (void)_updateShimmering
{
    // create mask if needed
    [self _createMaskIfNeeded];
    
    // if not shimmering and no mask, noop
    if (!_shimmering && !_maskLayer) {
        return;
    }
    
    // ensure layout
    [self layoutIfNeeded];
    
    BOOL disableActions = [CATransaction disableActions];
    if (!_shimmering) {
        if (disableActions) {
            // simply remove mask
            [self _clearMask];
        } else {
            // end slide
            CFTimeInterval slideEndTime = 0;
            
            CAAnimation *slideAnimation = [_maskLayer animationForKey:kJOShimmerSlideAnimationKey];
            if (slideAnimation != nil) {
                
                // determine total time sliding
                CFTimeInterval now = CACurrentMediaTime();
                CFTimeInterval slideTotalDuration = now - slideAnimation.beginTime;
                
                // determine time offset into current slide
                CFTimeInterval slideTimeOffset = fmod(slideTotalDuration, slideAnimation.duration);
                
                // transition to non-repeating slide
                CAAnimation *finishAnimation = shimmer_slide_finish(slideAnimation);
                
                // adjust begin time to now - offset
                finishAnimation.beginTime = now - slideTimeOffset;
                
                // note slide end time and begin
                slideEndTime = finishAnimation.beginTime + slideAnimation.duration;
                [_maskLayer addAnimation:finishAnimation forKey:kJOShimmerSlideAnimationKey];
            }
            
            // fade in text at slideEndTime
            CABasicAnimation *fadeInAnimation = fade_animation(_maskLayer.fadeLayer, 1.0, _shimmeringEndFadeDuration);
            fadeInAnimation.delegate = self;
            [fadeInAnimation setValue:@YES forKey:kJOEndFadeAnimationKey];
            fadeInAnimation.beginTime = slideEndTime;
            [_maskLayer.fadeLayer addAnimation:fadeInAnimation forKey:kJOFadeAnimationKey];
            
            // expose end time for synchronization
            _shimmeringFadeTime = slideEndTime;
        }
    } else {
        // fade out text, optionally animated
        CABasicAnimation *fadeOutAnimation = nil;
        if (_shimmeringBeginFadeDuration > 0.0 && !disableActions) {
            fadeOutAnimation = fade_animation(_maskLayer.fadeLayer, 0.0, _shimmeringBeginFadeDuration);
            [_maskLayer.fadeLayer addAnimation:fadeOutAnimation forKey:kJOFadeAnimationKey];
        } else {
            BOOL innerDisableActions = [CATransaction disableActions];
            [CATransaction setDisableActions:YES];
            
            _maskLayer.fadeLayer.opacity = 0.0;
            [_maskLayer.fadeLayer removeAllAnimations];
            
            [CATransaction setDisableActions:innerDisableActions];
        }
        
        // begin slide animation
        CAAnimation *slideAnimation = [_maskLayer animationForKey:kJOShimmerSlideAnimationKey];
        
        // compute shimmer duration
        CGFloat length = 0.0f;
        if (_shimmeringDirection == JOShimmerDirectionDown ||
            _shimmeringDirection == JOShimmerDirectionUp) {
            length = CGRectGetHeight(_contentLayer.bounds);
        } else {
            length = CGRectGetWidth(_contentLayer.bounds);
        }
        CFTimeInterval animationDuration = (length / _shimmeringSpeed) + _shimmeringPauseDuration;
        
        if (slideAnimation != nil) {
            // ensure existing slide animation repeats
            [_maskLayer addAnimation:shimmer_slide_repeat(slideAnimation, animationDuration, _shimmeringDirection) forKey:kJOShimmerSlideAnimationKey];
        } else {
            // add slide animation
            slideAnimation = shimmer_slide_animation(animationDuration, _shimmeringDirection);
            slideAnimation.fillMode = kCAFillModeForwards;
            slideAnimation.removedOnCompletion = NO;
            if (_shimmeringBeginTime == JOShimmerDefaultBeginTime) {
                _shimmeringBeginTime = CACurrentMediaTime() + fadeOutAnimation.duration;
            }
            slideAnimation.beginTime = _shimmeringBeginTime;
            
            [_maskLayer addAnimation:slideAnimation forKey:kJOShimmerSlideAnimationKey];
        }
    }
}

#pragma mark - CALayerDelegate

- (id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event
{
    // no associated actions
    return (id)kCFNull;
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag && [[anim valueForKey:kJOEndFadeAnimationKey] boolValue]) {
        [_maskLayer.fadeLayer removeAnimationForKey:kJOFadeAnimationKey];
        
        [self _clearMask];
    }
}
@end
