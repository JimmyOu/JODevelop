//
//  NECallTraceViewController.m
//  SnailReader
//
//  Created by JimmyOu on 2018/12/19.
//  Copyright © 2018 com.netease. All rights reserved.
//

#import "NECallTraceViewController.h"
#import "NEMonitorFileManager.h"
#import "NEMonitorCallTraceCell.h"
#import "NECallTraceDetailVC.h"
@interface NECallTraceViewController ()

@property (strong, nonatomic) NSArray <SMCallTraceTimeCostModel *>*callModels;
@property (strong, nonatomic) NSArray *filteredCallModels;
@property (strong, nonatomic) UIBarButtonItem *orderbyFrequency;
@property (strong, nonatomic) UIBarButtonItem *orderbyCost;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@property (nonatomic, strong) UISearchDisplayController *searchController;
#pragma clang diagnostic pop

@end

@implementation NECallTraceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(back)];
    self.orderbyFrequency = [[UIBarButtonItem alloc] initWithTitle:@"按次数" style:UIBarButtonItemStylePlain target:self action:@selector(orderByFrequency:)];
    self.orderbyFrequency.tintColor = [UIColor lightGrayColor];
    self.orderbyCost = [[UIBarButtonItem alloc] initWithTitle:@"按时间" style:UIBarButtonItemStylePlain target:self action:@selector(orderByCost:)];
    
    
    self.navigationItem.rightBarButtonItems = @[self.orderbyFrequency, self.orderbyCost];
    
    // Do any additional setup after loading the view.
    [self.tableView registerClass:[NEMonitorCallTraceCell class] forCellReuseIdentifier:kNEMonitorCallTraceCellIndentifier];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 100;
    [self fetchData];
}


- (void)orderByFrequency:(id)sender {
    self.orderbyFrequency.tintColor = [UIColor lightGrayColor];
    self.orderbyCost.tintColor = nil;
   self.callModels = [self.callModels sortedArrayUsingComparator:^NSComparisonResult(SMCallTraceTimeCostModel *obj1,   SMCallTraceTimeCostModel *obj2) {
        if (obj1.frequency < obj2.frequency)
        {
            return NSOrderedDescending;
        }
        else
        {
            return NSOrderedAscending;
        }
    }];
    [self.tableView reloadData];
}
- (void)orderByCost:(id)sender {
    self.orderbyCost.tintColor = [UIColor lightGrayColor];
    self.orderbyFrequency.tintColor = nil;
   self.callModels =  [self.callModels sortedArrayUsingComparator:^NSComparisonResult(SMCallTraceTimeCostModel *obj1,   SMCallTraceTimeCostModel *obj2) {
        if (obj1.timeCost < obj2.timeCost)
        {
            return NSOrderedDescending;
        }
        else
        {
            return NSOrderedAscending;
        }
    }];
    [self.tableView reloadData];
}
- (void)fetchData {
    
    [[NEMonitorFileManager shareInstance] fetchCostModels:^(NSArray<SMCallTraceTimeCostModel *> *items) {
        self.callModels = items;
        [self.tableView reloadData];
    }];
    
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}
- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"callTrace";
    }
    return self;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SMCallTraceTimeCostModel *model = self.callModels[indexPath.row];
    NECallTraceDetailVC *detail = [[NECallTraceDetailVC alloc] init];
    detail.model = model;
    [self.navigationController pushViewController:detail animated:YES];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.callModels.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [NEMonitorCallTraceCell preferredCellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   SMCallTraceTimeCostModel *model = self.callModels[indexPath.row];
    NEMonitorCallTraceCell *cell = [tableView dequeueReusableCellWithIdentifier:kNEMonitorCallTraceCellIndentifier];
    cell.model = model;
    return cell;
}



@end
