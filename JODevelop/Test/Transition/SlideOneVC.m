//
//  SlideOneVC.m
//  JODevelop
//
//  Created by JimmyOu on 17/5/4.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "SlideOneVC.h"
#import "SlideTwoVC.h"

@interface SlideOneVC ()

@end

@implementation SlideOneVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.button setTitle:[NSString stringWithFormat:@"点我或向左滑动"] forState:UIControlStateNormal];
    __weak typeof(self)weakSelf = self;
    [self axd_registerToInteractiveTransitionWithDirection:AXDInteractiveTransitionGestureDirectionLeft transitonBlock:^(CGPoint startPoint) {
        [weakSelf xw_transition];
    } edgeSpacing:100];
    
}

- (void)xw_transition{
    AXDSlideAnimation *animator = [[AXDSlideAnimation alloc] init];
    
    SlideTwoVC *toVC = [SlideTwoVC new];
    
    if (self.pushOrPresntSwitch.on) {
        [self.navigationController axd_pushViewController:toVC withAnimator:animator];
    }else{
        [self axd_presentViewController:toVC withAnimator:animator];
    }
}

@end
