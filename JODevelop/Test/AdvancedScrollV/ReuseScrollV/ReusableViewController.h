//
//  ReusableViewController.h
//  JODevelop
//
//  Created by JimmyOu on 2017/5/9.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReusableViewController : UIViewController

@property (assign, nonatomic) NSInteger numberOfInstance;
@property (assign, nonatomic) NSNumber *page;

- (void)reloadData;

@end
