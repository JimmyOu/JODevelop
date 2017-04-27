//
//  CircleSpreadTwoVC.m
//  JODevelop
//
//  Created by JimmyOu on 17/4/19.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "CircleSpreadTwoVC.h"

@interface CircleSpreadTwoVC ()<UIViewControllerTransitioningDelegate>


@end

@implementation CircleSpreadTwoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.button setTitle:@"点我或向下滑动" forState:UIControlStateNormal];
    __weak typeof(self)weakSelf = self;
    [self axd_registerBackInteractiveTransitionWithDirection:AXDInteractiveTransitionGestureDirectionDown transitonBlock:^(CGPoint startPoint){
        [weakSelf xw_transiton];
    } edgeSpacing:0];
}

@end
