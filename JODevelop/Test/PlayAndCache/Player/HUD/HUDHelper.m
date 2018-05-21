//
//  HudHelper.m
//  边下边播Demo
//
//  Created by JimmyOu on 2018/5/8.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "HUDHelper.h"
#import "MBProgressHUD.h"

@interface HUDHelper()
@property (strong, nonatomic) MBProgressHUD *hud;
@end
@implementation HUDHelper

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static HUDHelper *instance ;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

+ (void)showMessage:(NSString *)message
{
    [self show:message icon:@"" view:nil];
}
+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view
{
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = text;
    // 设置图片
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@", icon]]];
    // 再设置模式
    hud.mode = MBProgressHUDModeCustomView;
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    // 1.0秒之后再消失
    [hud hideAnimated:YES afterDelay:1.0];
}

- (void)showHudOnView:(UIView *)view
              caption:(NSString *)caption
                image:(UIImage *)image
            acitivity:(BOOL)active
         autoHideTime:(NSTimeInterval)time {
    
    if (_hud) {
        [_hud hideAnimated:NO];
    }
    
    self.hud = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:self.hud];
    self.hud.label.text = caption;
    self.hud.customView = [[UIImageView alloc] initWithImage:image];
    self.hud.customView.bounds = CGRectMake(0, 0, 100, 100);
    self.hud.mode = image ? MBProgressHUDModeCustomView : MBProgressHUDModeIndeterminate;
    self.hud.animationType = MBProgressHUDAnimationFade;
    [self.hud showAnimated:YES];
    if (time > 0) {
        [self.hud hideAnimated:YES afterDelay:time];
    }
}

- (void)hideHud {
    if (_hud) {
        [_hud hideAnimated:YES];
    }
}

@end
