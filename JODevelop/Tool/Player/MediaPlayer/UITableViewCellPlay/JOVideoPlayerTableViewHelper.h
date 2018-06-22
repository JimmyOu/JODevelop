//
//  JOVideoPlayerTableViewHelper.h
//  JODevelop
//
//  Created by JimmyOu on 2018/6/21.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UITableView+JOVideoPlay.h"

@interface JOVideoPlayerTableViewHelper : NSObject

@property (weak, nonatomic) id<JOTableViewVideoPlayDelegate> jo_delegate;

@property (nonatomic, weak, nullable) UITableView *tableView;

/**
 当前正在播放视频的cell
 */
@property (nonatomic, weak) UITableViewCell *jo_playingVideoCell;
/**
 播放规则
 */
@property (assign, nonatomic) JOScrollPlayStrategyType playStrategy;

/**
 自定义寻找需要播放cell的规则， invoked by jo_playVideoInVisibleCellsIfNeed
 */
@property(nonatomic, copy) JOPlayVideoInVisibleCellsBlock jo_playVideoInVisibleCellsBlock;

/**
 初始化
 */
- (instancetype)initWithTableView:(UITableView *)tableView;
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

- (void)playVideoWithCell:(UITableViewCell *)cell;

@end
