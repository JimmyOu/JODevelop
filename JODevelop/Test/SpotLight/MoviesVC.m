//
//  MoviesVC.m
//  JODevelop
//
//  Created by JimmyOu on 2017/8/8.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "MoviesVC.h"
#import "MovieCell.h"
#import "MoviesService.h"
#import "MoviesDetailVC.h"
@interface MoviesVC ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *moviesInfo;

@end

@implementation MoviesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUpUI];
    [self loadData];
    self.title = @"Movies";
    
}
- (void)loadData {
    self.moviesInfo = [MoviesService loadMoviesInfo];
    [self.tableView reloadData];
}
- (void)setUpUI {
    self.automaticallyAdjustsScrollViewInsets = NO;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,60, kScreenWidth, kScreenHeight) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.rowHeight = 100;
    
    NSString *identifier = NSStringFromClass([MovieCell class]);
    UINib *cellNib = [UINib nibWithNibName:identifier bundle:nil];
    [_tableView registerNib:cellNib forCellReuseIdentifier:identifier];
    [self.view addSubview:_tableView];

}

#pragma mark – delegate (eg:UITableViewDataSource)
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.moviesInfo.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([MovieCell class])];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *currentMovieInfo = self.moviesInfo[indexPath.row];
    
     
    cell.lblTitle.text = currentMovieInfo[@"Title"];
    cell.lblDescription.text = currentMovieInfo[@"Description"];
    cell.lblRating.text = currentMovieInfo[@"Rating"];
    cell.imgMovieImage.image = [UIImage imageNamed:currentMovieInfo[@"Image"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    MoviesDetailVC *detail = [MoviesDetailVC new];
    detail.movieInfo = self.moviesInfo[indexPath.row];
    [self.navigationController pushViewController:detail animated:YES];
}


@end
