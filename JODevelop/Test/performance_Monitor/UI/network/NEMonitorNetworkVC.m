//
//  NEMonitorNetworkVC.m
//  SnailReader
//
//  Created by JimmyOu on 2018/8/23.
//  Copyright © 2018年 com.netease. All rights reserved.
//

#import "NEMonitorNetworkVC.h"
#import "NEMonitorNetworkCell.h"
#import "NEHTTPModelManager.h"
#import "NEHTTPModel.h"
#import "NEAppMonitor.h"
#import "NEMonitorNetworkDetailViewController.h"

@interface NEMonitorNetworkVC ()<UISearchDisplayDelegate>

@property (nonatomic, copy) NSArray *networkTransactions;
@property (nonatomic, copy) NSArray *filteredNetworkTransactions;
@property (nonatomic, assign) long long bytesReceived;
@property (nonatomic, assign) long long filteredBytesReceived;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@property (nonatomic, strong) UISearchDisplayController *searchController;
#pragma clang diagnostic pop

@end

@implementation NEMonitorNetworkVC

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"network";
    }
    return self;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(back)];
    // Do any additional setup after loading the view.
    [self.tableView registerClass:[NEMonitorNetworkCell class] forCellReuseIdentifier:kNEMonitorNetworkCellIndentifier];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = [self rowHight];
    
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    [searchBar sizeToFit];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
#pragma clang diagnostic pop
    self.searchController.delegate = self;
    self.searchController.searchResultsDataSource = self;
    self.searchController.searchResultsDelegate = self;
    [self.searchController.searchResultsTableView registerClass:[NEMonitorNetworkCell class] forCellReuseIdentifier:kNEMonitorNetworkCellIndentifier];
    self.searchController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.searchController.searchResultsTableView.rowHeight = [self rowHight];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    [self updateTransactions];
}
- (void)updateTransactions {
    self.networkTransactions = [[NEHTTPModelManager sharedInstance] netModels];
}
- (void)setNetworkTransactions:(NSArray *)networkTransactions {
    if (![_networkTransactions isEqual:networkTransactions]) {
        _networkTransactions = networkTransactions;
        [self updateBytesReceived];
        [self updateFilteredBytesReceived];
    }
}
- (void)updateBytesReceived
{
    long long bytesReceived = 0;
    for (NEHTTPModel *model in self.networkTransactions) {
        bytesReceived += model.responseFlow;
    }
    self.bytesReceived = bytesReceived;
    [self updateFirstSectionHeaderInTableView:self.tableView];
}

- (void)updateFilteredBytesReceived
{
    long long filteredBytesReceived = 0;
    for (NEHTTPModel *model in self.filteredNetworkTransactions) {
        filteredBytesReceived += model.responseFlow;
    }
    self.filteredBytesReceived = filteredBytesReceived;
    [self updateFirstSectionHeaderInTableView:self.searchController.searchResultsTableView];
}

- (void)updateFirstSectionHeaderInTableView:(UITableView *)tableView
{
    UIView *view = [tableView headerViewForSection:0];
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
        headerView.textLabel.text = [self headerTextForTableView:tableView];
        [headerView setNeedsLayout];
    }
}

- (NSString *)headerTextForTableView:(UITableView *)tableView
{
    NSString *headerText = nil;
    
    if ([NEAppMonitor sharedInstance].enableNetworkMonitor) {
        long long bytesReceived = 0;
        NSInteger totalRequests = 0;
        if (tableView == self.tableView) {
            bytesReceived = self.bytesReceived;
            totalRequests = [self.networkTransactions count];
        } else if (tableView == self.searchController.searchResultsTableView) {
            bytesReceived = self.filteredBytesReceived;
            totalRequests = [self.filteredNetworkTransactions count];
        }
        NSString *byteCountText = [NSByteCountFormatter stringFromByteCount:bytesReceived countStyle:NSByteCountFormatterCountStyleBinary];
        NSString *requestsText = totalRequests == 1 ? @"Request" : @"Requests";
        headerText = [NSString stringWithFormat:@"%ld %@ (%@ received)", (long)totalRequests, requestsText, byteCountText];
    } else {
        headerText = @"⚠️  Debugging Disabled (Enable in Settings)";
    }
    return headerText;
}

- (void)setFilteredNetworkTransactions:(NSArray *)filteredNetworkTransactions
{
    if (![_filteredNetworkTransactions isEqual:filteredNetworkTransactions]) {
        _filteredNetworkTransactions = filteredNetworkTransactions;
        [self updateFilteredBytesReceived];
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    if (tableView == self.tableView) {
        numberOfRows = [self.networkTransactions count];
    } else if (tableView == self.searchController.searchResultsTableView) {
        numberOfRows = [self.filteredNetworkTransactions count];
    }
    return numberOfRows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self headerTextForTableView:tableView];
}
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
        headerView.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14.0];
        headerView.textLabel.textColor = [UIColor whiteColor];
        headerView.contentView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NEMonitorNetworkCell *cell = [tableView dequeueReusableCellWithIdentifier:kNEMonitorNetworkCellIndentifier forIndexPath:indexPath];
    cell.model = [self transactionAtIndexPath:indexPath inTableView:tableView];
    
    // Since we insert from the top, assign background colors bottom up to keep them consistent for each transaction.
    NSInteger totalRows = [tableView numberOfRowsInSection:indexPath.section];
    if ((totalRows - indexPath.row) % 2 == 0) {
        cell.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NEMonitorNetworkDetailViewController *detailViewController = [[NEMonitorNetworkDetailViewController alloc] init];
    detailViewController.model = [self transactionAtIndexPath:indexPath inTableView:tableView];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (NEHTTPModel *)transactionAtIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView
{
    NEHTTPModel *model = nil;
    if (tableView == self.tableView) {
        model = [self.networkTransactions objectAtIndex:indexPath.row];
    } else if (tableView == self.searchController.searchResultsTableView) {
        model = [self.filteredNetworkTransactions objectAtIndex:indexPath.row];
    }
    return model;
}

#pragma mark - Search display delegate
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self updateSearchResultsWithSearchString:searchString];
    
    // Reload done after the data is filtered asynchronously
    return NO;
}

- (void)updateSearchResultsWithSearchString:(NSString *)searchString
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *filteredNetworkTransactions = [self.networkTransactions filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL( NEHTTPModel *model, NSDictionary *bindings) {
            return [[model.ne_request.URL absoluteString] rangeOfString:searchString options:NSCaseInsensitiveSearch].length > 0;
        }]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.searchController.searchBar.text isEqual:searchString]) {
                self.filteredNetworkTransactions = filteredNetworkTransactions;
                [self.searchController.searchResultsTableView reloadData];
            }
        });
    });
}

- (CGFloat)rowHight {
    return [NEMonitorNetworkCell preferredCellHeight];
}



@end
