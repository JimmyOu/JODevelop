//
//  UITableView+JOVideoPlay.h
//  JODevelop
//
//  Created by JimmyOu on 2018/6/21.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableViewCell+JOVideoPlay.h"

typedef NS_OPTIONS(NSUInteger , JOScrollPlayStrategyType) {
    /*cell的中心到tableview的中心越近越容易播放*/
    JOScrollPlayStrategyTypeBestCell = 0,
    /*cell 中videoView的中心到tableview的中心越近越容易播放*/
    JOScrollPlayStrategyTypeBestVideoView,
};

typedef UITableViewCell *_Nullable (^JOPlayVideoInVisibleCellsBlock)(NSArray<UITableViewCell *> *_Nullable visibleCells);
@protocol JOTableViewVideoPlayDelegate<NSObject>

/**
 当调用jo_playVideoInVisibleCellsIfNeed时候，会找到需要播放的cell交给业务方，业务方可以调用cell.jo_videoPlayView jo_playVideoWithURL: 等一系列方法播放视频。
 @param tableView 当前的tableView
 @param cell 需要播放视频的cell
 */

- (void)tableView:(UITableView *)tableView willPlayVideoOnCell:(UITableViewCell *)cell;
@end
@interface UITableView (JOVideoPlay)

@property (weak, nonatomic) id<JOTableViewVideoPlayDelegate> jo_delegate;

/**
    当前正在播放视频的cell
 */
@property (readonly, nonatomic) UITableViewCell *jo_playingVideoCell;
/**
 播放规则
 */
@property (assign, nonatomic) JOScrollPlayStrategyType jo_playStrategy;

/**
 自定义寻找需要播放cell的规则， invoked by jo_playVideoInVisibleCellsIfNeed
 */
@property(nonatomic) JOPlayVideoInVisibleCellsBlock jo_playVideoInVisibleCellsBlock;


/**
 寻找到需要播放的cell。must be called after reloadData && didAppear
 */
- (void)jo_playVideoInVisibleCellsIfNeed;

/**
 stop playing ifNeeded
 */
- (void)jo_stopPlayIfNeed;

/**
 must called in 'scrollViewDidScroll:'
 */
- (void)jo_scrollViewDidScroll;
/**
 must called in 'scrollViewDidEndDecelerating:'
 */
- (void)jo_scrollViewDidEndDecelerating;

/**
 must called in `scrollViewDidEndDragging:willDecelerate:`
 */
- (void)jo_scrollViewDidEndDraggingWillDecelerate:(BOOL)decelerate;

/**
 播放指定cell上的视频
 */
- (void)jo_playCellAtIndexPath:(NSIndexPath *)indexPath;


@end
