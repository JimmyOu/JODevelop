//
//  AnimatorBaseOneVC.m
//  JODevelop
//
//  Created by JimmyOu on 17/4/24.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "AnimatorBaseOneVC.h"

@interface AnimatorBaseOneVC ()

@end

@implementation AnimatorBaseOneVC

- (void)dealloc {
    NSLog(@"%@ dealloc",[self class]);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.layer.contents = (__bridge id)[UIImage imageNamed:@"p1.JPG"].CGImage;
    UISwitch *pushOrPresntSwitch = [UISwitch new];
    _pushOrPresntSwitch = pushOrPresntSwitch;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:pushOrPresntSwitch];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button = button;
    button.titleLabel.font = [UIFont systemFontOfSize:13];
    button.titleLabel.textAlignment = 1;
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.center = CGPointMake(self.view.center.x, self.view.center.y + 30);
    button.bounds = CGRectMake(0, 0, 150, 30);
    [button addTarget:self action:@selector(xw_transition) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)xw_transition {
    
}
@end
