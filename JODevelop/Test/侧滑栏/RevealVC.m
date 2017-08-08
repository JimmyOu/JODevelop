//
//  RevealVC.m
//  JODevelop
//
//  Created by JimmyOu on 2017/8/8.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "RevealVC.h"


#import "FrontVC.h"
#import "RearVC.h"
#import "SWRevealViewController.h"

@interface RevealVC ()

@end

@implementation RevealVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIButton *btn = [UIButton new];
    [btn setTitle:@"present" forState:UIControlStateNormal];
    btn.center = CGPointMake(0.5 * kScreenWidth, 0.5 * kScreenHeight);
    btn.bounds = CGRectMake(0, 0, 100, 40);
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(didClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didClick {
    
    FrontVC *frontViewController = [[FrontVC alloc] init];
    RearVC *rearViewController = [[RearVC alloc] init];
    
    UINavigationController *frontNavigationController = [[UINavigationController alloc] initWithRootViewController:frontViewController];
    UINavigationController *rearNavigationController = [[UINavigationController alloc] initWithRootViewController:rearViewController];
    
    SWRevealViewController *revealController = [[SWRevealViewController alloc] initWithRearViewController:rearNavigationController frontViewController:frontNavigationController];
    
    [self presentViewController:revealController animated:YES completion:nil];
    
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
