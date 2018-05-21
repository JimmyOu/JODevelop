//
//  UIView+Extension.m
//  JODevelop
//
//  Created by JimmyOu on 17/4/19.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "UIView+Extension.h"

#import <objc/runtime.h>

static char kDTActionHandlerTapBlockKey;
static char kDTActionHandlerTapGestureKey;
static char kDTActionHandlerDoubleTapBlockKey;
static char kDTActionHandlerDoubleTapGestureKey;
static char kDTActionHandlerLongPressBlockKey;
static char kDTActionHandlerLongPressGestureKey;
static const char * kLastClickedEventTime = "LastClickedEventTime"; //这个为了限制多次点击
static const NSTimeInterval kAcceptClickEventInterval        = 1;//两次点击的间隔

@implementation UIView (Extension)

- (void)setAnchorPointTo:(CGPoint)point{
    self.frame = CGRectOffset(self.frame, (point.x - self.layer.anchorPoint.x) * self.frame.size.width, (point.y - self.layer.anchorPoint.y) * self.frame.size.height);
    self.layer.anchorPoint = point;
}

- (CGFloat)left {
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)top {
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)x
{
    return self.frame.origin.x;
}

- (void)setX:(CGFloat)newX
{
    CGRect newFrame = self.frame;
    newFrame.origin.x = newX;
    self.frame = newFrame;
}

- (CGFloat)y
{
    return self.frame.origin.y;
}

- (void)setY:(CGFloat)newY
{
    CGRect newFrame = self.frame;
    newFrame.origin.y = newY;
    self.frame = newFrame;
}

- (CGFloat)centerX {
    return self.center.x;
}

- (void)setCenterX:(CGFloat)centerX {
    self.center = CGPointMake(centerX, self.center.y);
}



- (CGFloat)centerY {
    return self.center.y;
}

- (void)setCenterY:(CGFloat)centerY {
    self.center = CGPointMake(self.center.x, centerY);
}



- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}



- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}


- (CGPoint)origin {
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}


- (CGSize)size {
    return self.frame.size;
}

- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}


// 判断View是否显示在屏幕上
- (BOOL)isDisplayedInScreen
{
    if (self == nil) {
        return FALSE;
    }
    
    CGRect screenRect = [UIScreen mainScreen].bounds;
    
    // 转换view对应window的Rect
    CGRect rect = [self convertRect:self.frame fromView:nil];
    if (CGRectIsEmpty(rect) || CGRectIsNull(rect)) {
        return FALSE;
    }
    
    // 若view 隐藏
    if (self.hidden) {
        return FALSE;
    }
    
    // 若没有superview
    if (self.superview == nil) {
        return FALSE;
    }
    
    // 若size为CGrectZero
    if (CGSizeEqualToSize(rect.size, CGSizeZero)) {
        return  FALSE;
    }
    
    // 获取 该view与window 交叉的 Rect
    CGRect intersectionRect = CGRectIntersection(rect, screenRect);
    if (CGRectIsEmpty(intersectionRect) || CGRectIsNull(intersectionRect)) {
        return FALSE;
    }
    
    return TRUE;
}


#pragma mark - 点击事件
- (void)clicked:(nonnull void(^)(void))clicked
{
    UITapGestureRecognizer *gesture = objc_getAssociatedObject(self, &kDTActionHandlerTapGestureKey);
    
    if (!gesture)
    {
        gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(__handleActionForTapGesture:)];
        if ([self isKindOfClass:[UILabel class]] || [self isKindOfClass:[UIImageView class]]) {
            self.userInteractionEnabled = YES;
        }
        [self addGestureRecognizer:gesture];
        objc_setAssociatedObject(self, &kDTActionHandlerTapGestureKey, gesture, OBJC_ASSOCIATION_RETAIN);
    }
    
    objc_setAssociatedObject(self, &kDTActionHandlerTapBlockKey, clicked, OBJC_ASSOCIATION_COPY);
}

- (void)doubleClick:(nonnull void(^)(void))doubleClick
{
    UITapGestureRecognizer *gesture = objc_getAssociatedObject(self, &kDTActionHandlerDoubleTapGestureKey);
    
    if (!gesture)
    {
        gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(__handleActionForDoubleTapGesture:)];
        gesture.numberOfTapsRequired = 2;
        if ([self isKindOfClass:[UILabel class]] || [self isKindOfClass:[UIImageView class]]) {
            self.userInteractionEnabled = YES;
        }
        [self addGestureRecognizer:gesture];
        objc_setAssociatedObject(self, &kDTActionHandlerDoubleTapGestureKey, gesture, OBJC_ASSOCIATION_RETAIN);
    }
    
    objc_setAssociatedObject(self, &kDTActionHandlerDoubleTapBlockKey, doubleClick, OBJC_ASSOCIATION_COPY);
}

- (void)__handleActionForTapGesture:(UITapGestureRecognizer *)gesture
{
    if ([NSDate date].timeIntervalSince1970 - self.lastClickedEventTime < kAcceptClickEventInterval) {
        return;
    }
    
    self.lastClickedEventTime = [NSDate date].timeIntervalSince1970;
    
    if (gesture.state == UIGestureRecognizerStateRecognized)
    {
        void(^action)(void) = objc_getAssociatedObject(self, &kDTActionHandlerTapBlockKey);
        
        if (action)
        {
            action();
        }
    }
}


- (void)__handleActionForDoubleTapGesture:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateRecognized)
    {
        void(^action)() = objc_getAssociatedObject(self, &kDTActionHandlerDoubleTapBlockKey);
        
        if (action)
        {
            action();
        }
    }
}

- (void)longPressed:(nonnull void(^)(UITapGestureRecognizer *gesture))longPressed
{
    UILongPressGestureRecognizer *gesture = objc_getAssociatedObject(self, &kDTActionHandlerLongPressGestureKey);
    
    if (!gesture)
    {
        gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(__handleActionForLongPressGesture:)];
        if ([self isKindOfClass:[UILabel class]] || [self isKindOfClass:[UIImageView class]]) {
            self.userInteractionEnabled = YES;
        }
        [self addGestureRecognizer:gesture];
        objc_setAssociatedObject(self, &kDTActionHandlerLongPressGestureKey, gesture, OBJC_ASSOCIATION_RETAIN);
    }
    
    objc_setAssociatedObject(self, &kDTActionHandlerLongPressBlockKey, longPressed, OBJC_ASSOCIATION_COPY);
}

- (void)__handleActionForLongPressGesture:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        void(^action)(UITapGestureRecognizer *tapGesture) = objc_getAssociatedObject(self, &kDTActionHandlerLongPressBlockKey);
        
        if (action)
        {
            action(gesture);
        }
    }
}

- (NSTimeInterval)lastClickedEventTime
{
    return [objc_getAssociatedObject(self, kLastClickedEventTime) doubleValue];
}

- (void)setLastClickedEventTime:(NSTimeInterval)lastClickedEventTime
{
    objc_setAssociatedObject(self, kLastClickedEventTime, @(lastClickedEventTime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
