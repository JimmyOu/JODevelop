//
//  NEMonitorController.m
//  SnailReader
//
//  Created by JimmyOu on 2018/8/23.
//  Copyright © 2018年 com.netease. All rights reserved.
//

#import "NEMonitorController.h"
#import "NEMonitorNetworkVC.h"
#import "NEFilesViewController.h"
#import "NEMonitorFileManager.h"
#import "NEMonitorSettingVC.h"
#import "NEMonitorUtils.h"

typedef NS_ENUM(NSInteger, NEMonitorType) {
    NEMonitorType_network = 0,
    NEMonitorType_fluent,
    NEMonitorType_sql,
    NEMonitorType_Folder,
    NEMonitorType_all,
};
@interface NEMonitorController ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;


@end

@implementation NEMonitorController {
    NSArray *_names;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"NEMonitor";
    _names = @[@"Network history", @"Fluent", @"SQL",@"folder"];
    [self setupUI];
}

- (void)setupUI {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStyleDone target:self action:@selector(close)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"设置" style:UIBarButtonItemStyleDone target:self action:@selector(setting)];
    
    _tableView = [[UITableView alloc] init];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _tableView.frame = self.view.bounds;
}
- (void)close
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}
- (void)setting {
    NEMonitorSettingVC *settingVC = [[NEMonitorSettingVC alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:settingVC];
    UIViewController *hostVC = [NEMonitorUtils currentPresentVC];
    [hostVC presentViewController:nav animated:YES completion:NULL];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return NEMonitorType_all;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellID = @"FileCellId";
    
    NSString *name = _names[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellID];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case NEMonitorType_network:
        {
            NEMonitorNetworkVC *networkVC = [[NEMonitorNetworkVC alloc] init];
            [self.navigationController pushViewController:networkVC animated:YES];
            
        }
            break;
        case NEMonitorType_fluent:
        {
            NEFilesViewController *vc = [[NEFilesViewController alloc] initWithDir:[[NEMonitorFileManager shareInstance] monitorDir]];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case NEMonitorType_sql:
        {
            
        }
        
            break;
        case NEMonitorType_Folder:
        {
            NEFilesViewController *vc = [[NEFilesViewController alloc] initWithDir:NSHomeDirectory()];
            [self.navigationController pushViewController:vc animated:YES];
        }
            
            break;
            
        default:
            break;
    }
}

@end
