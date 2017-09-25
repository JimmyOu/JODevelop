//
//  BasicListController.h
//  JODevelop
//
//  Created by JimmyOu on 17/4/24.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BasicListController : UIViewController

@property (nonatomic, copy) NSArray *titleData;
@property (nonatomic, weak,readonly) UITableView *mainView;

- (void)configCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath;

- (void)selectCellAtIndexPath:(NSIndexPath *)indexPath;

@end
