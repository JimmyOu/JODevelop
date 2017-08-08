//
//  FrontVC.m
//  JODevelop
//
//  Created by JimmyOu on 2017/8/8.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "FrontVC.h"
#import "SWRevealViewController.h"
@interface FrontVC ()

@end

@implementation FrontVC

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.title = @"Front View";
    SWRevealViewController *revealVC = [self revealViewController];
    [revealVC panGestureRecognizer];
    [revealVC tapGestureRecognizer];
    
    if (self.navigationController.viewControllers.count <= 1) {
        UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:revealVC action:@selector(revealToggle:)];
        
        self.navigationItem.leftBarButtonItem = revealButtonItem;
    } else {
    }
    

    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *push = [UIButton new];
    push.center = CGPointMake(0.5 * kScreenWidth, 0.5 * kScreenHeight);
    push.bounds = CGRectMake(0, 0, 100, 50);
    [push setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [push setTitle:@"push" forState:UIControlStateNormal];
    [push addTarget:self action:@selector(push) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:push];
}
- (void)push {
    FrontVC *new = [FrontVC new];
    [self.navigationController pushViewController:new animated:YES];
}
- (void)dealloc {
    NSLog(@"%@ dealloc",[self class]);
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
