//
//  NESystemInfoVC.m
//  SnailReader
//
//  Created by JimmyOu on 2018/9/17.
//  Copyright © 2018年 com.netease. All rights reserved.
//

#import "NESystemInfoVC.h"
#import "NESystemInfo.h"
#import "NESystemInfoChartViewVC.h"
#import "NEMonitorDataCenter.h"
@interface NESystemInfoVC ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray<NESystemInfoModel *> *systemInfos;
@property (strong, nonatomic) UIActivityIndicatorView *loadingView;

@end

@implementation NESystemInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"SystemInfo";
    [self setupUI];
    [self refresh];
}

- (void)setupUI {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(back)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
    
    _tableView = [[UITableView alloc] init];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _loadingView.hidden = YES;
    [self.view addSubview:_loadingView];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _tableView.frame = self.view.bounds;
    _loadingView.center = self.view.center;
}
- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)refresh {
    _loadingView.hidden = NO;
    [_loadingView startAnimating];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        self.systemInfos = [[NESystemInfo sharedSystemInfo] getAllSystemInformation];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.loadingView.hidden = YES;
            [self.loadingView stopAnimating];
            [self.tableView reloadData];
        });
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NESystemInfoModel *info = self.systemInfos[section];
    return info.items.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.systemInfos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NESystemInfoModel *info = self.systemInfos[indexPath.section];
    NESystemInfoItem *item = info.items[indexPath.row];
    
    static NSString *CellID = @"FileCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellID];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
        cell.detailTextLabel.numberOfLines = 0;

    }
    if (indexPath.section == 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.textLabel.text = item.title;
    cell.detailTextLabel.text = item.value;
    return cell;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NESystemInfoModel *info = self.systemInfos[section];
    return info.groupName;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (action == @selector(copy:)) {
        NESystemInfoModel *info = self.systemInfos[indexPath.section];
        NESystemInfoItem *item = info.items[indexPath.row];
        [UIPasteboard generalPasteboard].string = item.value;
    }
}
- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    return action == @selector(copy:);
}
- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NEMonitorDataCenter *dataCenter = [NEMonitorDataCenter sharedInstance];
        if (indexPath.row == 1) {
            NESystemInfoChartViewVC *vc = [[NESystemInfoChartViewVC alloc] initWithData:dataCenter.cpu.values time:dataCenter.cpu.times];
            vc.type = NESystemInfoChartTypeCPU;
            vc.startDate = dataCenter.startGraphicMonitorTime;
            vc.titleText = dataCenter.cpu.title;
            [self.navigationController pushViewController:vc animated:YES];
        } else if (indexPath.row == 2) {
            NESystemInfoChartViewVC *vc = [[NESystemInfoChartViewVC alloc] initWithData:dataCenter.memory.values time:dataCenter.memory.times];
            vc.startDate = dataCenter.startGraphicMonitorTime;
            vc.type = NESystemInfoChartTypeMemory;
            vc.titleText = dataCenter.memory.title;
            [self.navigationController pushViewController:vc animated:YES];
        } else if (indexPath.row == 3) {
            NESystemInfoChartViewVC *vc = [[NESystemInfoChartViewVC alloc] initWithData:dataCenter.battery.values time:dataCenter.battery.times];
            vc.startDate = dataCenter.startGraphicMonitorTime;
            vc.type = NESystemInfoChartTypeBattery;
            vc.titleText = dataCenter.battery.title;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}



@end
