//
//  RootVC.m
//  JODevelop
//
//  Created by JimmyOu on 17/4/13.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "RootVC.h"
#import "RootItemModel.h"
#import "NSString+Extention.h"
#import <FLEX/FLEXManager.h>


@interface RootVC ()

@property (nonatomic, strong) NSMutableArray <RootItemModel *>*names;
@property (strong, nonatomic) UIButton *flexButton;

@end

@implementation RootVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addFlexButton];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.names.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReuseID" forIndexPath:indexPath];
    
    RootItemModel *item = self.names[indexPath.row];
    
    cell.textLabel.text = item.name;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        RootItemModel *item = self.names[indexPath.row];
        UIViewController *toVC = [[NSClassFromString(item.vc) alloc] init] ;
        toVC.title = item.name;
        toVC.view.backgroundColor = [UIColor whiteColor];
        [self.navigationController pushViewController:toVC animated:YES];
    });
    
}

- (NSMutableArray<RootItemModel *> *)names {
    if (!_names) {
        _names = [NSMutableArray array];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"ItemList.plist" ofType:nil];
        NSArray *array = [NSArray arrayWithContentsOfFile:path];
        
        for (NSDictionary *dic in array) {
            RootItemModel *item = [RootItemModel itemWithDict:dic];
            [_names addObject:item];
        }
    }
    return _names;
}

- (void)addFlexButton
{
    UIWindow *keywindow = [UIApplication sharedApplication].keyWindow;
#ifdef DEBUG
    if (self.flexButton != nil) {
        [keywindow bringSubviewToFront:self.flexButton];
        return;
    }
    self.flexButton = [[UIButton alloc] init];
    CGFloat buttonW = 20;
    CGFloat buttonH = 20;
    self.flexButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - buttonW, [UIScreen mainScreen].bounds.size.height - buttonH, buttonW, buttonH);
    self.flexButton.titleLabel.font = [UIFont systemFontOfSize:7];
    self.flexButton.backgroundColor = [UIColor darkGrayColor];
    [self.flexButton setTitle:@"FLEX" forState:UIControlStateNormal];
    [self.flexButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.flexButton addTarget:self action:@selector(showFlexExplorer:) forControlEvents:UIControlEventTouchUpInside];
    [keywindow addSubview:self.flexButton];
#endif
}

- (void)showFlexExplorer:(UIButton *)sender
{
#ifdef DEBUG
    [[FLEXManager sharedManager] showExplorer];
#endif
}

@end
