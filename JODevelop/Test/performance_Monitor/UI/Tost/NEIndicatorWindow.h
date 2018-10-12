//
//  NEIndicatorWindow.h
//  JODevelop
//
//  Created by JimmyOu on 2018/8/7.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NEIndicatorWindow;
@protocol NEIndicatorWindowDelegate<NSObject>
- (void)indicatorWindowTapTipsButton:(NEIndicatorWindow *)window;

@end
@interface NEIndicatorWindow : UIWindow

@property (nonatomic, strong) UIButton *fpsButton;
@property (strong, nonatomic) UIButton *cpuUsageButton;
@property (strong, nonatomic) UIButton *memoryUsageButton;

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, weak) id<NEIndicatorWindowDelegate> delegate;

@end
