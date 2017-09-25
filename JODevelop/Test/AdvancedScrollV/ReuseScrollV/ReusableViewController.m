//
//  ReusableViewController.m
//  JODevelop
//
//  Created by JimmyOu on 2017/5/9.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "ReusableViewController.h"
#import "UIColor+Extension.h"
@interface ReusableViewController ()

@property (strong, nonatomic) UILabel *instanceNumberLabel;
@property (strong, nonatomic) UILabel *titleLabel;

@end

@implementation ReusableViewController


- (void)setPage:(NSNumber *)page
{
    if (_page != page) {
        _page = page;
        [self reloadData];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //NSLog(@"page = %@,%s",self.page,__func__);
    

    self.view.backgroundColor = [UIColor randomColor];
    [self.view addSubview:self.instanceNumberLabel];
    self.instanceNumberLabel.frame = CGRectMake(0, kScreenHeight - 30 - 60, kScreenWidth, 30);
    [self.view addSubview:self.titleLabel];
    self.titleLabel.bounds= CGRectMake(0, 0, kScreenWidth, 30);
    self.titleLabel.center = self.view.center;
    
    [self reloadData];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"page = %@,%s",self.page,__func__);
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //NSLog(@"page = %@,%s",self.page,__func__);
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //NSLog(@"page = %@,%s",self.page,__func__);
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    //NSLog(@"page = %@,%s",self.page,__func__);
}
- (void)reloadData
{
    self.titleLabel.text = [NSString stringWithFormat:@"Page #%@", self.page];
    self.instanceNumberLabel.text = [NSString stringWithFormat:@"Instance #%ld", self.numberOfInstance];
}

- (UILabel *)instanceNumberLabel {
    if (!_instanceNumberLabel) {
        UILabel *instanceNumberLabel = [UILabel new];
        _instanceNumberLabel.font = [UIFont systemFontOfSize:15];
        _instanceNumberLabel.textColor = [UIColor blackColor];
        _instanceNumberLabel.textAlignment = NSTextAlignmentLeft;
        _instanceNumberLabel = instanceNumberLabel;
    }
    return _instanceNumberLabel;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel  *titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont systemFontOfSize:15];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel = titleLabel;
    }
    return _titleLabel;
}

@end
