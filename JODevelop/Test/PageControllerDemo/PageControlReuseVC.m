//
//  PageControlReuseVC.m
//  JODevelop
//
//  Created by JimmyOu on 2017/5/11.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "PageControlReuseVC.h"

#import "UIColor+Extension.h"

@interface PageControlReuseVC ()

@property (nonatomic, assign) NSInteger currentIndexPage;

@property (strong, nonatomic) UILabel *titleLabel;

@end

@implementation PageControlReuseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //NSLog(@"page = %ld,%s",self.currentIndexPage,__func__);
    
    self.view.backgroundColor = [UIColor randomColor];
    [self.view addSubview:self.titleLabel];
    self.titleLabel.bounds= CGRectMake(0, 0, kScreenWidth, 30);
    self.titleLabel.center = self.view.center;
    
    [self reloadData];
}



- (void)reloadData
{
    self.titleLabel.text = [NSString stringWithFormat:@"Page #%@", @(self.currentIndexPage)];

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


- (UIViewController *)scrollViewController {
    return self.parentViewController;
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    _currentIndexPage = currentIndex;
    [self reloadData];
}

- (NSInteger)currentIndex {
    return _currentIndexPage;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"page = %ld,%s",self.currentIndexPage,__func__);
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"page = %ld,%s",self.currentIndexPage,__func__);
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"page = %ld,%s",self.currentIndexPage,__func__);
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    NSLog(@"page = %ld,%s",self.currentIndexPage,__func__);
}

@end
