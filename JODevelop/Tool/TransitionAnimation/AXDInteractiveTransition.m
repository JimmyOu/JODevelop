//
//  AXDInteractiveTransition.m
//  JODevelop
//
//  Created by JimmyOu on 17/4/27.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "AXDInteractiveTransition.h"
//#import <objc/runtime.h>

typedef struct {
    unsigned int willBegin :      1;
    unsigned int isUpdating :     1;
    unsigned int willBeginTimer : 1;
    unsigned int willEnd :        1;
} delegateFlag;

@interface AXDInteractiveTransition ()<UIGestureRecognizerDelegate>

@property (nonatomic, assign) AXDInteractiveTransitionGestureDirection direction;
@property (nonatomic, copy) void(^config)(CGPoint startPoint);
@property (nonatomic, strong) CADisplayLink *timer;
@property (nonatomic, assign) CGFloat percent;
@property (nonatomic, assign) CGFloat timeDis;
@property (nonatomic, assign) delegateFlag delegateFlag;
@property (nonatomic, assign) BOOL vertical;
@property (nonatomic, assign) CGFloat edgeSpacing;

@end

@implementation AXDInteractiveTransition

+ (instancetype)interactiveTransitionWithDirection:(AXDInteractiveTransitionGestureDirection)direction config:(void (^)(CGPoint))config edgeSpacing:(CGFloat)edgeSpacing {
    return [[self alloc] initWithDirection:direction config:config edgeSpacing:edgeSpacing];
}

- (instancetype)initWithDirection:(AXDInteractiveTransitionGestureDirection)direction config:(void (^)(CGPoint))config edgeSpacing:(CGFloat)edgeSpacing {
    if (self = [super init]) {
        self.config = config;
        self.direction = direction;
        self.edgeSpacing = edgeSpacing;
        self.vertical = (direction == AXDInteractiveTransitionGestureDirectionDown) || (direction == AXDInteractiveTransitionGestureDirectionUp);
        //self.panValue = kAXDTransitionPanValue;
        self.panValue = [UIScreen mainScreen].bounds.size.width;
    }
    return self;
}

- (void)setDelegate:(id<AXDInteractiveTransitionDelegate>)delegate{
    _delegate = delegate;
    _delegateFlag.willBegin = _delegate && [_delegate respondsToSelector:@selector(interactiveTransitionWillBegin:)];
    _delegateFlag.isUpdating = _delegate && [_delegate respondsToSelector:@selector(interactiveTransition:isUpdating:)];
    _delegateFlag.willBeginTimer = _delegate && [_delegate respondsToSelector:@selector(interactiveTransitionWillBeginTimerAnimation:)];
    _delegateFlag.willEnd = _delegate && [_delegate respondsToSelector:@selector(interactiveTransition:willEndWithSuccessFlag:percent:)];
}

- (void)addPanGestureForView:(UIView *)view {
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(p_handleGesture:)];
    //为drawerAnimator记录pan手势
    pan.delegate = self;
    [view addGestureRecognizer:pan];
    
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return [self isValidPanGesture:(UIPanGestureRecognizer *)gestureRecognizer];
    } else {
        return NO;
    }
    
}
- (void)p_handleGesture:(UIPanGestureRecognizer *)panGesture {
    
    CGPoint translation = [panGesture translationInView:panGesture.view.superview];
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            if (_delegateFlag.willBegin) {
                [_delegate interactiveTransitionWillBegin:self];
            }
            CGPoint startPoint = [panGesture locationInView:panGesture.view];
            _interation = YES;
            if (_config) {
                _config(startPoint);
            }
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            
            CGFloat fraction ;
            if (self.vertical) {
                fraction = fabs(translation.y / self.panValue);
            } else {
                fraction = fabs(translation.x / self.panValue);
            }
            fraction = fminf(fmaxf(fraction, 0.0), 1.0);
            if (fraction >= 1.0) fraction = 0.99;
            
            _percent = fraction;
            [self p_updatingWithPercent:fraction];
            
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            //判断是否需要timer
            if (!_timerEnable) {
                _percent >= 0.5 ? [self p_finish] : [self p_cancle];
                return;
            }
            //判断此时是否已经转场完成，大于1或者小于0
            BOOL canEnd = [self p_canEndInteractiveTransitionWithPercent:_percent];
            if (canEnd) return;
            //开启timer
            [self p_setEndAnimationTimerWithPercent:_percent];
            break;
        }
            
        default:
            break;
    }

}

//设置开启timer
- (void)p_setEndAnimationTimerWithPercent:(CGFloat)percent{
    _percent = percent;
    //根据失败还是成功设置刷新间隔
    if (percent > 0.5) {
        _timeDis = (1 - percent) / ((1 - percent) * 60);
    }else{
        _timeDis = percent / (percent * 60);
    }
    if (_delegateFlag.willBeginTimer) {
        [_delegate interactiveTransitionWillBeginTimerAnimation:self];
    }
    //开启timer
    [self p_startTimer];
}

- (void)p_startTimer{
    if (_timer) {
        return;
    }
    _timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(p_timerEvent)];
    [_timer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

//timer 事件
- (void)p_timerEvent{
    if (_percent > 0.5) {
        _percent += _timeDis;
    }else{
        _percent -= _timeDis;
    }
    //通过timer不断刷新转场进度
    [self p_updatingWithPercent:_percent];
    BOOL canEnd = [self p_canEndInteractiveTransitionWithPercent:_percent];
    if (canEnd) {
        [self p_stopTimer];
    }
}

- (void)p_stopTimer{
    if (!_timer) {
        return;
    }
    [_timer invalidate];
    _timer = nil;
    
}

- (void)p_updatingWithPercent:(CGFloat)percent{
    [self updateInteractiveTransition:percent];
    if (_delegateFlag.isUpdating) {
        [_delegate interactiveTransition:self isUpdating:_percent];
    }
}


- (BOOL)p_canEndInteractiveTransitionWithPercent:(CGFloat)percent{
    BOOL can = NO;
    if (percent >= 0.99) {
        [self p_finish];
        can = YES;
    }
    if (percent <= 0) {
        [self p_cancle];
        can = YES;
    }
    return can;
}


- (void)p_finish{
    if (_delegateFlag.willEnd) {
        [_delegate interactiveTransition:self willEndWithSuccessFlag:YES percent:_percent];
    }
    [self finishInteractiveTransition];
    _percent = 0.0f;
    _interation = NO;
}

- (void)p_cancle{
    if (_delegateFlag.willEnd) {
        [_delegate interactiveTransition:self willEndWithSuccessFlag:NO percent:_percent];
    }
    [self cancelInteractiveTransition];
    _percent = 0.0f;
    _interation = NO;
}



- (BOOL)isValidPanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
    
    BOOL valid = NO;
    CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
    CGPoint vel = [gestureRecognizer velocityInView:gestureRecognizer.view];
    if (_edgeSpacing <= 0) {
        switch (self.direction) {
            case AXDInteractiveTransitionGestureDirectionLeft:
                valid = (vel.x < 0);
                break;
            case AXDInteractiveTransitionGestureDirectionRight:
                valid = (vel.x > 0);
                break;
            case AXDInteractiveTransitionGestureDirectionUp:
                valid = (vel.y < 0);
                break;
            case AXDInteractiveTransitionGestureDirectionDown:
                valid = (vel.y > 0);
                break;

        }
    }else {
        switch (self.direction) {
            case AXDInteractiveTransitionGestureDirectionLeft:
                valid = (vel.x < 0) && (point.x >= gestureRecognizer.view.frame.size.width - _edgeSpacing);
                break;
            case AXDInteractiveTransitionGestureDirectionRight:
                valid = (vel.x > 0) && (point.x <= _edgeSpacing);
                break;
            case AXDInteractiveTransitionGestureDirectionUp:
                valid = (vel.y < 0) && (point.y >= gestureRecognizer.view.frame.size.height - _edgeSpacing);
                break;
            case AXDInteractiveTransitionGestureDirectionDown:
                valid = (vel.y > 0) && (point.y <= _edgeSpacing);
                break;
                
        }
    }
    return valid;
}

@end
