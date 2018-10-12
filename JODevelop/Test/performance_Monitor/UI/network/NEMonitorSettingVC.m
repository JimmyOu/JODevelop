//
//  NEMonitorSettingVC.m
//  SnailReader
//
//  Created by JimmyOu on 2018/8/23.
//  Copyright © 2018年 com.netease. All rights reserved.
//

#import "NEMonitorSettingVC.h"
#import "NEAppMonitor.h"
#import "NEMonitorDataCenter.h"
#import "NEMonitorToast.h"
#import "NEConstConstraints.h"
#import "NELeaksFinder.h"

@interface NEMonitorSettingVC ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (nonatomic, copy) NSArray *cells;

@end

@implementation NEMonitorSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    

    [self setupUI];
   
}
- (void)setupUI {
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStyleDone target:self action:@selector(close)];
    
    
    NSMutableArray *mutableCells = [NSMutableArray array];
    UITableViewCell *networkDebuggingCell = [self switchCellWithTitle:@"Network Debugging" toggleAction:@selector(networkDebuggingToggled:) isOn:[NEAppMonitor sharedInstance].enableNetworkMonitor];
    [mutableCells addObject:networkDebuggingCell];
    
    UITableViewCell *fluentDebuggingCell = [self switchCellWithTitle:@"Fluent Monitor" toggleAction:@selector(fluentDebuggingToggled:) isOn:[NEAppMonitor sharedInstance].enableFulencyMonitor];
    [mutableCells addObject:fluentDebuggingCell];
    
    UITableViewCell *performanceDebuggingCell = [self switchCellWithTitle:@"Performance" toggleAction:@selector(performanceDebuggingToggled:) isOn:[NEAppMonitor sharedInstance].enablePerformanceMonitor];
    
    [mutableCells addObject:performanceDebuggingCell];
    
//    UITableViewCell *alertWhenFindingRetainCycle = [self switchCellWithTitle:@"alertWhenFindingRetainCycle" toggleAction:@selector(alertWhenFindingRetainCycle:) isOn:_INTERNAL_MLF_Alert];
//
//    [mutableCells addObject:alertWhenFindingRetainCycle];
    
    UITableViewCell *clearGraphicDataCell = [self buttonCellWithTitle:@"清理绘图缓存" toggleAction:@selector(clearGraphicData)];
    [mutableCells addObject:clearGraphicDataCell];
    
    self.cells = mutableCells;
    [self.tableView reloadData];
}
- (void)close
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.tableView.frame = self.view.bounds;
}
#pragma mark - Settings Actions
//- (void)alertWhenFindingRetainCycle:(UISwitch *)sender {
//    _INTERNAL_MLF_Alert = sender.isOn;
//}
- (void)clearGraphicData {
    [[NEMonitorDataCenter sharedInstance].battery clearAllData];
    [[NEMonitorDataCenter sharedInstance].cpu clearAllData];
    [[NEMonitorDataCenter sharedInstance].memory clearAllData];
    [NEMonitorToast showToast:@"清理完毕"];
}
- (void)networkDebuggingToggled:(UISwitch *)sender
{
    [NEAppMonitor sharedInstance].enableNetworkMonitor = sender.isOn;
}
- (void)fluentDebuggingToggled:(UISwitch *)sender
{
    [NEAppMonitor sharedInstance].enableFulencyMonitor = sender.isOn;
}
- (void)performanceDebuggingToggled:(UISwitch *)sender
{
    [NEAppMonitor sharedInstance].enablePerformanceMonitor = sender.isOn;
}
#pragma mark - Helpers

- (UITableViewCell *)switchCellWithTitle:(NSString *)title toggleAction:(SEL)toggleAction isOn:(BOOL)isOn
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = title;
    cell.textLabel.font = [[self class] defaultFontOfSize:14];
    
    UISwitch *theSwitch = [[UISwitch alloc] init];
    theSwitch.on = isOn;
    [theSwitch addTarget:self action:toggleAction forControlEvents:UIControlEventValueChanged];
    
    CGFloat switchOriginY = round((cell.contentView.frame.size.height - theSwitch.frame.size.height) / 2.0);
    CGFloat switchOriginX = CGRectGetMaxX(cell.contentView.frame) - theSwitch.frame.size.width - self.tableView.separatorInset.left;
    theSwitch.frame = CGRectMake(switchOriginX, switchOriginY, theSwitch.frame.size.width, theSwitch.frame.size.height);
    theSwitch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [cell.contentView addSubview:theSwitch];
    
    return cell;
}

- (UITableViewCell *)buttonCellWithTitle:(NSString *)title toggleAction:(SEL)toggleAction
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = title;
    cell.textLabel.font = [[self class] defaultFontOfSize:14];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 31)];
    btn.layer.cornerRadius = 15;
    btn.clipsToBounds = YES;
    btn.backgroundColor = kJBColorLineChartControllerBackground;
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [btn addTarget:self action:toggleAction forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat switchOriginY = round((cell.contentView.frame.size.height - btn.frame.size.height) / 2.0);
    CGFloat switchOriginX = CGRectGetMaxX(cell.contentView.frame) - btn.frame.size.width - self.tableView.separatorInset.left;
    btn.frame = CGRectMake(switchOriginX, switchOriginY, btn.frame.size.width, btn.frame.size.height);
    btn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [cell.contentView addSubview:btn];
    
    return cell;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.cells count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.cells objectAtIndex:indexPath.row];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

+ (UIFont *)defaultFontOfSize:(CGFloat)size
{
    return [UIFont fontWithName:@"HelveticaNeue" size:size];
}

@end
