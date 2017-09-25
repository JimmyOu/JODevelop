//
//  SlideTwoVC.m
//  JODevelop
//
//  Created by JimmyOu on 17/5/4.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "SlideTwoVC.h"

@interface SlideTwoVC ()

@end

@implementation SlideTwoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.button setTitle:@"点我或向下滑动" forState:UIControlStateNormal];
    __weak typeof(self)weakSelf = self;
    [self axd_registerBackInteractiveTransitionWithDirection:AXDInteractiveTransitionGestureDirectionDown transitonBlock:^(CGPoint startPoint){
        [weakSelf xw_transiton];
    } edgeSpacing:0];
    
}

- (void)click:(UIButton *)btn {
    self.view.frame = [UIScreen mainScreen].bounds;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
