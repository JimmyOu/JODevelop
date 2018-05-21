//
//  HudHelper.h
//  边下边播Demo
//
//  Created by JimmyOu on 2018/5/8.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HUDHelper : NSObject

+ (instancetype)sharedInstance;

- (void)showHudOnView:(UIView *)view
              caption:(NSString *)caption
                image:(UIImage *)image
            acitivity:(BOOL)active
         autoHideTime:(NSTimeInterval)time;

- (void)hideHud;
+ (void)showMessage:(NSString *)message;

@end
