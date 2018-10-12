//
//  NEMonitorToast.m
//  JODevelop
//
//  Created by JimmyOu on 2018/8/9.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "NEMonitorToast.h"

@interface NEMonitorToast()
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) UIButton *btn;
@end
@implementation NEMonitorToast

+ (NEMonitorToast *)showToast:(NSString *)content {
    NEMonitorToast *tostView = [[NEMonitorToast alloc] init];
    [tostView showInView:[self topWindow] content:content];
    return tostView;
}
- (void)showInView:(UIView *)view content:(NSString *)content {
    self.btn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btn.layer.cornerRadius = 3;
    self.btn.clipsToBounds = YES;
    self.btn.titleLabel.font = [UIFont systemFontOfSize:13];
    self.btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.btn setTitle:content forState:UIControlStateNormal];
    self.btn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    
    [self addSubview:self.btn];
    
    [view addSubview:self];
    self.bounds = CGRectMake(0, 0, 100, 30);
    self.center = CGPointMake([UIScreen mainScreen].bounds.size.width * 0.5, [UIScreen mainScreen].bounds.size.height - 70);
    
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1.f;
    } completion:^(BOOL finished) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(hideAnimated) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }];
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.btn.frame = self.bounds;
}

- (void)hideAnimated {
    [_timer invalidate];
    _timer = nil;
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

+ (UIWindow *)topWindow
{
    UIWindow *window = nil;
    if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(window)]) {
        window = [[UIApplication sharedApplication].delegate performSelector:@selector(window)];
    }
    
    if (window != nil) {
        return window;
    }
    
    return [[[UIApplication sharedApplication].windows sortedArrayUsingComparator:^NSComparisonResult(UIWindow *win1, UIWindow *win2) {
        if (win1.frame.size.height != [[UIScreen mainScreen] bounds].size.height) {
            return NSOrderedAscending;
        }
        else if (win2.frame.size.height != [[UIScreen mainScreen] bounds].size.height) {
            return NSOrderedDescending;
        }
        
        if ([[win2.class description] isEqualToString:@"CustomStatusBar"] ||
            [[win2.class description] rangeOfString:@"TextEffects"].location != NSNotFound ||
            [[win2.class description] rangeOfString:@"Keyboard"].location != NSNotFound) {
            return NSOrderedDescending;
        }
        else if ([[win1.class description] isEqualToString:@"CustomStatusBar"] ||
                 [[win1.class description] rangeOfString:@"TextEffects"].location != NSNotFound ||
                 [[win1.class description] rangeOfString:@"Keyboard"].location != NSNotFound) {
            return NSOrderedAscending;
        }
        
        return win1.windowLevel - win2.windowLevel;
    }] lastObject];
}


@end
