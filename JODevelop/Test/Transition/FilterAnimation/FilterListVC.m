
//
//  FilterListVC.m
//  JODevelop
//
//  Created by JimmyOu on 17/4/24.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "FilterListVC.h"
#import "FilterOneVC.h"
@interface FilterListVC ()

@end

@implementation FilterListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"FilterTransition";
    self.titleData = @[@"BoxBlur", @"Swipe", @"BarsSwipe", @"Mask", @"Flash", @"Mod", @"PageCurl", @"Ripple", @"CopyMachine"];
}

- (void)selectCellAtIndexPath:(NSIndexPath *)indexPath{
    FilterOneVC *fVC = [FilterOneVC new];
    fVC.type = indexPath.row;
    [self.navigationController pushViewController:fVC animated:YES];
}
@end
