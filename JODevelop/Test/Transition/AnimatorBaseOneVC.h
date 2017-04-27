//
//  AnimatorBaseOneVC.h
//  JODevelop
//
//  Created by JimmyOu on 17/4/24.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "AXDTransition.h"

@interface AnimatorBaseOneVC : UIViewController

@property (nonatomic, weak,readonly) UISwitch *pushOrPresntSwitch;
@property (nonatomic, weak, readonly) UIButton *button;

- (void)xw_transition;

@end
