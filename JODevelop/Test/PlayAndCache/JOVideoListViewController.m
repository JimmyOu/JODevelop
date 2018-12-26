//
//  JOVideoListViewController.m
//  JODevelop
//
//  Created by JimmyOu on 2018/6/21.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "JOVideoListViewController.h"
#import "JOVideoCell.h"
#import "JOWebVideoPlayer.h"
#import "UIColor+Extension.h"
@interface JOVideoListViewController ()<JOTableViewVideoPlayDelegate, UITableViewDelegate, UITableViewDataSource>

/**
 * Arrary of video paths.
 * 播放路径数组集合.
 */
@property(nonatomic, strong, nonnull)NSArray *pathStrings;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation JOVideoListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setup];
}

- (void)setup {
    self.title = @"微博";
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([JOVideoCell class]) bundle:nil]
         forCellReuseIdentifier:NSStringFromClass([JOVideoCell class])];
    self.tableView.jo_delegate = self;
    self.tableView.jo_playStrategy = JOScrollPlayStrategyTypeBestCell;
    
    // location file in disk.
    // 本地视频播放.
    NSString *locVideoPath = [[NSBundle mainBundle]pathForResource:@"designedByAppleInCalifornia" ofType:@"mp4"];
    NSURL *url = [NSURL fileURLWithPath:locVideoPath];
    self.pathStrings = @[
                         url.absoluteString,
                         @"https://www.apple.com/105/media/cn/iphone-x/2017/01df5b43-28e4-4848-bf20-490c34a926a7/films/feature/iphone-x-feature-cn-20170912_1280x720h.mp4",
                         @"https://static.smartisanos.cn/common/video/smartisan-tnt.mp4",
                         @"https://static.smartisanos.cn/common/video/video-jgpro.mp4",
                         @"https://static.smartisanos.cn/common/video/m1-coffee.mp4",
                         @"https://static.smartisanos.cn/common/video/m1-white.mp4",
                         @"https://static.smartisanos.cn/common/video/smartisanT2.mp4",
                         @"https://static.smartisanos.cn/common/video/smartisant1.mp4",

                         ];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView jo_playVideoInVisibleCellsIfNeed];
}


#pragma mark - Data Srouce

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    return self.pathStrings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    JOVideoCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([JOVideoCell class]) forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.jo_videoURL = [NSURL URLWithString:self.pathStrings[indexPath.row]];
    cell.jo_videoPlayView = cell.videoView;
    cell.contentView.backgroundColor = [UIColor randomColor];
    return cell;
}


#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    //把之前的停掉
    [tableView jo_stopPlayIfNeed];
    [tableView jo_playCellAtIndexPath:indexPath];
    NSLog(@"detailVC");
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 150;
}

/**
 * Called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
 * 松手时已经静止, 只会调用scrollViewDidEndDragging
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.tableView jo_scrollViewDidEndDraggingWillDecelerate:decelerate];
}

/**
 * Called on tableView is static after finger up if the user dragged and tableView is scrolling.
 * 松手时还在运动, 先调用scrollViewDidEndDragging, 再调用scrollViewDidEndDecelerating
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self.tableView jo_scrollViewDidEndDecelerating];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.tableView jo_scrollViewDidScroll];
}


#pragma mark - JOTableViewPlayVideoDelegate

- (void)tableView:(UITableView *)tableView willPlayVideoOnCell:(UITableViewCell *)cell {
    [cell.jo_videoPlayView jo_playVideoWithURL:cell.jo_videoURL];
}

@end
