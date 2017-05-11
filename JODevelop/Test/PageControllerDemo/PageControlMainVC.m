//
//  PageControlMainVC.m
//  JODevelop
//
//  Created by JimmyOu on 2017/5/11.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "PageControlMainVC.h"
#import "AXDScrollPageView.h"
#import "PageControlReuseVC.h"

@interface PageControlMainVC ()<AXDScrollPageViewDelegate>

@property(strong, nonatomic)NSArray<NSString *> *titles;
@property(strong, nonatomic)NSArray<UIViewController *> *childVcs;
@property (nonatomic, strong) AXDScrollPageView *scrollPageView;

@end

@implementation PageControlMainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"效果示例";
    
    //必要的设置, 如果没有设置可能导致内容显示不正常
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.titles = @[@"新闻头条",
                    @"国际要闻",
                    @"体育",
                    @"中国足球",
                    @"汽车",
                    @"囧途旅游",
                    @"幽默搞笑",
                    @"视频",
                    @"无厘头",
                    @"美女图片",
                    @"今日房价",
                    @"头像",
                    ];
    // 初始化
    _scrollPageView = [[AXDScrollPageView alloc] initWithFrame:CGRectMake(0, 64.0, self.view.bounds.size.width, self.view.bounds.size.height - 64.0) titles:self.titles parentViewController:self delegate:self];
    
    [self.view addSubview:_scrollPageView];

    
}

- (NSInteger)numberOfChildViewControllers {
    return self.titles.count;
}

- (UIViewController<AXDScrollPageViewChildVcDelegate> *)childViewController:(UIViewController<AXDScrollPageViewChildVcDelegate> *)reuseViewController forIndex:(NSInteger)index {
    UIViewController<AXDScrollPageViewChildVcDelegate> *childVc = reuseViewController;
    
    if (!childVc) {
        childVc = [[PageControlReuseVC alloc] init];
    }
    
    //    NSLog(@"%ld-----%@",(long)index, childVc);
    
    return childVc;
}


- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
    return NO;
}

@end
