//
//  RearVC.m
//  JODevelop
//
//  Created by JimmyOu on 2017/8/8.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "RearVC.h"
#import "SWRevealViewController.h"
#import "FrontVC.h"
#import "UIView+Extension.h"
#import "UIColor+Extension.h"


@interface RearVC () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation RearVC
{
    NSInteger _presentedRow;
    NSArray *_titles;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor greenColor];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,20, kScreenWidth, kScreenHeight) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];


    _titles = @[@"Front View Controller",@"Map View Controller",@"Enter Presentation Mode",@"Resign Presentation Mode"];
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

#pragma mark – delegate (eg:UITableViewDataSource)
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    NSInteger row = indexPath.row;
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = _titles[row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SWRevealViewController *revealController = self.revealViewController;
    
    // selecting row
    NSInteger row = indexPath.row;
    
    // if we are trying to push the same row or perform an operation that does not imply frontViewController replacement
    // we'll just set position and return
    
    if ( row == _presentedRow )
    {
        [revealController setFrontViewPosition:FrontViewPositionLeft animated:YES];
        return;
    }
   FrontVC *newFrontController =  [[FrontVC alloc ] init];
    newFrontController.view.backgroundColor = [UIColor randomColor];
    newFrontController.title = _titles[row];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newFrontController];
    
    [revealController pushFrontViewController:navigationController animated:YES];
    
    _presentedRow = row;  // <- store the presented row
}

- (void)dealloc {
    NSLog(@"%@ dealloc",[self class]);
}



@end
