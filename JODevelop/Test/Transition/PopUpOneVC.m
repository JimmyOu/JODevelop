//
//  PopUpOneVC.m
//  JODevelop
//
//  Created by JimmyOu on 17/4/27.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "PopUpOneVC.h"
#import "PopUpTwoVC.h"


@interface PopUpOneVC ()

@end

@implementation PopUpOneVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.button.backgroundColor = [UIColor lightGrayColor];
    self.button.titleLabel.numberOfLines = 0;
    self.button.titleLabel.font = [UIFont systemFontOfSize:12];
    self.button.bounds = CGRectMake(0, 0, 40, 40);
    self.button.center = CGPointMake(self.view.center.x, self.view.center.y - 100);
}

- (void)xw_transition{
    AXDPopUpAnimation *animator = [[AXDPopUpAnimation alloc] init];
    
    PopUpTwoVC *toVC = [PopUpTwoVC new];
    toVC.title = @"popUpNavi";
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:toVC];
    
    
    if (self.pushOrPresntSwitch.on) {
        
    }else{
        navi.modalPresentationStyle = UIModalPresentationCustom;
        [self axd_presentViewController:navi withAnimator:animator];
    }
}

@end
