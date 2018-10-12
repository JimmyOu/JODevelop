//
//  NEMonitorViewManager.m
//  JODevelop
//
//  Created by JimmyOu on 2018/8/7.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "NEMonitorViewManager.h"
#import "NEIndicatorWindow.h"
//#import "NEFilesViewController.h"
#import "NEMonitorFileManager.h"
#import "NEAppMonitor.h"
#import "NEMonitorController.h"
#import "NEMonitorUtils.h"
@interface NEMonitorViewManager()<NEIndicatorWindowDelegate>
@property (strong, nonatomic) NEIndicatorWindow *window;
@property (strong, nonatomic) UIColor *goodColor;
@property (strong, nonatomic) UIColor *badColor;


@end

@implementation NEMonitorViewManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self prepare];
    }
    return self;
}
- (void)prepare {
    self.window = [[NEIndicatorWindow alloc] init];
    self.window.delegate = self;
    self.window.hidden = YES;
    
    self.goodColor = [UIColor greenColor];
    self.badColor = [UIColor redColor];
    
}

- (void)indicatorWindowTapTipsButton:(NEIndicatorWindow *)window {
//    [[NEAppMonitor sharedInstance] pause];
    NEMonitorController *vc = [[NEMonitorController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.interactivePopGestureRecognizer.enabled = NO;
    UIViewController *hostVC = [NEMonitorUtils currentPresentVC];
    [hostVC presentViewController:nav animated:YES completion:NULL];
}

- (void)setFPS:(float)fps {
    if (fps > 30) {
        self.window.fpsButton.backgroundColor = self.goodColor;
    } else {
        self.window.fpsButton.backgroundColor = self.badColor;
    }
    [self.window.fpsButton setTitle:[NSString stringWithFormat:@"fps:%.f",fps] forState:UIControlStateNormal];
}
- (void)setCPU:(float)cpu {
    [self.window.cpuUsageButton setTitle:[NSString stringWithFormat:@"cpu:%.f%%",cpu] forState:UIControlStateNormal];
}
- (void)setMemory:(float)memory {
    [self.window.memoryUsageButton setTitle:[NSString stringWithFormat:@"%.fM",memory] forState:UIControlStateNormal];
}
- (void)show {
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_window.hidden = NO;
    });
}
- (void)hide {
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_window.hidden = YES;
    });
}
- (BOOL)isShowing {
    return _window.hidden;
}
@end
