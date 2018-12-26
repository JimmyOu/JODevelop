//
//  TableViewHeaderAnimation.m
//  JODevelop
//
//  Created by JimmyOu on 17/4/14.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "TableViewHeaderAnimation.h"
#import "Masonry.h"

#define expandedFont 30
#define collapsedFont 20

@interface TableViewHeaderAnimation ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UIView *headV;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, assign) CGFloat maxHeaderHeight;
@property (nonatomic, assign) CGFloat minHeaderHeight;
@property (nonatomic, assign) CGFloat currentHeaderHeight;

@property (nonatomic, assign) CGFloat previousScrollOffsetY;


@property (nonatomic, strong) UILabel *expandedLabel;
@property (nonatomic, strong) UILabel *collapsedLabel;

@end

@implementation TableViewHeaderAnimation

- (instancetype)init
{
    self = [super init];
    if (self) {
        _maxHeaderHeight = 88;
        _minHeaderHeight = 44;
        _currentHeaderHeight = _maxHeaderHeight;
    }
    return self;
}


#pragma mark – VC life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _headV = [[UIView alloc] init];
    _headV.backgroundColor = [UIColor blueColor];
    [self.view addSubview:_headV];
    [_headV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).offset(0);
        make.left.mas_equalTo(self.view);
        make.right.mas_equalTo(self.view);
        make.height.mas_equalTo(_currentHeaderHeight);
    }];
    
    [_headV addSubview:self.expandedLabel];
    [self.expandedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(self.expandedLabel.text.length * expandedFont, expandedFont * 2));
        make.centerX.mas_equalTo(_headV);
        make.bottom.mas_equalTo(_headV);
    }];
    
    [_headV addSubview:self.collapsedLabel];
    [self.collapsedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(self.collapsedLabel.text.length * collapsedFont, collapsedFont * 2));
        make.centerX.mas_equalTo(_headV);
        make.top.mas_equalTo(_headV);
    }];
    
    
    _tableView = [[UITableView alloc] init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view);
        make.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.headV.mas_bottom);
        make.bottom.mas_equalTo(self.view);
    }];
    
}
- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
}
- (BOOL)prefersStatusBarHidden {
    return YES;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [_headV mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.maxHeaderHeight);
    }];
    
    [self updateHeader];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark – delegate (eg:UITableViewDelegate)
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat scrollDiff = scrollView.contentOffset.y - self.previousScrollOffsetY;
    CGFloat range = self.maxHeaderHeight - self.minHeaderHeight;
    
    CGFloat previousH = _currentHeaderHeight;
    CGFloat newHeight = _currentHeaderHeight;
    
    CGFloat absoluteTop = 0;
    CGFloat absoluteBottom = scrollView.contentSize.height - scrollView.frame.size.height;
    
    BOOL isScrollingDown = (scrollDiff > 0) && (scrollView.contentOffset.y > absoluteTop&&scrollView.contentOffset.y < range);
    BOOL isScrollingUp = (scrollDiff < 0) && (scrollView.contentOffset.y < absoluteBottom &&scrollView.contentOffset.y < range);
    
    if (isScrollingDown) {  //scroll down
        newHeight -= fabs(scrollDiff);
    } else if(isScrollingUp){ //scroll up
        newHeight += fabs(scrollDiff);
    }
    newHeight = MIN(_maxHeaderHeight, MAX(newHeight, _minHeaderHeight));
    if (previousH != newHeight) {
        _currentHeaderHeight = newHeight;
        [self.headV mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(_currentHeaderHeight);
        }];
        
        //when animating stop scrolling
        [self setScrollPosition:self.previousScrollOffsetY];

    }
    
    [self updateHeader];

    self.previousScrollOffsetY = scrollView.contentOffset.y;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    //the scrollV stop
    if(!decelerate) {
        [self scrollViewDidStopScrolling];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //the scrollV stop
    [self scrollViewDidStopScrolling];
}

#pragma mark – delegate (eg:UITableViewDataSource)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 40;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"textLabel%ld",indexPath.row];
    return cell;
}


#pragma mark - helper 
- (void)setScrollPosition:(CGFloat)contentOffSetY {
    self.tableView.contentOffset = CGPointMake(self.tableView.contentOffset.x, contentOffSetY);

}

- (void)scrollViewDidStopScrolling {
    CGFloat range = self.maxHeaderHeight - self.minHeaderHeight;
    CGFloat midPoint = self.minHeaderHeight + (range / 2);
    if (_currentHeaderHeight > midPoint) {
        //expend header
        [self.view layoutIfNeeded];
        _currentHeaderHeight = self.maxHeaderHeight;
        [self updateHeader];
        [self.headV mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(_currentHeaderHeight);
        }];
        [UIView animateWithDuration:0.2 animations:^{
            [self.view layoutIfNeeded];
        }];
        

    } else {
        //condense header
        [self.view layoutIfNeeded];
        _currentHeaderHeight = self.minHeaderHeight;
        [self updateHeader];
        [self.headV mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(_currentHeaderHeight);
        }];
        [UIView animateWithDuration:0.2 animations:^{
            [self.view layoutIfNeeded];
        }];
    }
    
    
}

- (void)updateHeader {
    CGFloat range = self.maxHeaderHeight - self.minHeaderHeight;
    CGFloat openAmount = self.currentHeaderHeight - self.minHeaderHeight;
    CGFloat percentage = openAmount / range;
    
    
    [self.collapsedLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_headV).offset(-openAmount + 10);
    }];
    self.expandedLabel.alpha = percentage;
}

#pragma mark - setter & getter
- (UILabel *)expandedLabel {
    if (!_expandedLabel) {
        _expandedLabel = [[UILabel alloc] init];
        _expandedLabel.text = @"ShimmerLab";
        _expandedLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:expandedFont];
        _expandedLabel.textColor = [UIColor whiteColor];
        _expandedLabel.textAlignment = NSTextAlignmentCenter;
        _expandedLabel.backgroundColor = [UIColor clearColor];
    }
    return _expandedLabel;
}

- (UILabel *)collapsedLabel {
    if (!_collapsedLabel) {
        _collapsedLabel = [[UILabel alloc] init];
        _collapsedLabel.text = @"Shimmer";
        _collapsedLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:collapsedFont];
        _collapsedLabel.textColor = [UIColor whiteColor];
        _collapsedLabel.textAlignment = NSTextAlignmentCenter;
        _collapsedLabel.backgroundColor = [UIColor clearColor];
    }
    return _collapsedLabel;
}



@end
