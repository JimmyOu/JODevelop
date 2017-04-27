//
//  CoolTypeListController.m
//  JODevelop
//
//  Created by JimmyOu on 17/4/24.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "CoolTypeListController.h"
#import "AXDCoolOneVC.h"
#import "AXDCoolAnimator.h"

@interface CoolTypeListController ()

@end

@implementation CoolTypeListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"CooltypeList";
    self.titleData = @[@"PageFlip",@"MiddleFlipFromLeft",@"MiddleFlipFromRight",@"MiddleFlipFromTop",@"MiddleFlipFromBottom",@"Portal",@"FoldFromLeft",@"FoldFromRight", @"Explode", @"HorizontalLines", @"VerticalLines",@"ScanningFromLeft",@"ScanningFromRight",@"ScanningFromTop",@"ScanningFromBottom"];
}

- (void)selectCellAtIndexPath:(NSIndexPath *)indexPath{
    AXDCoolOneVC *fVC = [AXDCoolOneVC new];
    fVC.type = indexPath.row;
    [self.navigationController pushViewController:fVC animated:YES];
}
@end
