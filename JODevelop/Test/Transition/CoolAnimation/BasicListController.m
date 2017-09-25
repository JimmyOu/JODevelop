//
//  BasicListController.m
//  JODevelop
//
//  Created by JimmyOu on 17/4/24.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "BasicListController.h"

@interface BasicListController ()<UITableViewDelegate, UITableViewDataSource>


@end

@implementation BasicListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UITableView *mainView = [UITableView new];
    mainView.delegate = self;
    mainView.dataSource = self;
    mainView.frame = self.view.bounds;
    mainView.backgroundColor = [UIColor whiteColor];
    _mainView = mainView;
    [self.view addSubview:mainView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.titleData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"xwtransition"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"xwtransition"];
    }
    cell.textLabel.text = _titleData[indexPath.row];
    [self configCell:cell indexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self selectCellAtIndexPath:indexPath];
}

- (void)configCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    
}

- (void)selectCellAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
