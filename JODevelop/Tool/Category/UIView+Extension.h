//
//  UIView+Extension.h
//  JODevelop
//
//  Created by JimmyOu on 17/4/19.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Extension)

@property (nonatomic) CGFloat left;
@property (nonatomic) CGFloat top;
@property (nonatomic) CGFloat right;
@property (nonatomic) CGFloat bottom;
@property (nonatomic) CGFloat x;
@property (nonatomic) CGFloat y;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@property (nonatomic) CGFloat centerX;
@property (nonatomic) CGFloat centerY;
@property (nonatomic) CGPoint origin;
@property (nonatomic) CGSize  size;

- (void)setAnchorPointTo:(CGPoint)point;

- (BOOL)isDisplayedInScreen;

#pragma mark - 点击及长按事件
- (void)clicked:(nonnull void(^)(void))clicked;
- (void)doubleClick:(nonnull void(^)(void))doubleClick;
- (void)longPressed:(nonnull void(^)(UITapGestureRecognizer *gesture))longPressed;

@end

NS_ASSUME_NONNULL_END
