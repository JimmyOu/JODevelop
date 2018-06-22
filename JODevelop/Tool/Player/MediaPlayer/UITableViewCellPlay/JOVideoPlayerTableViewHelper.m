//
//  JOVideoPlayerTableViewHelper.m
//  JODevelop
//
//  Created by JimmyOu on 2018/6/21.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "JOVideoPlayerTableViewHelper.h"
#import "UIView+JOWebVideoPlayer.h"

@implementation JOVideoPlayerTableViewHelper
/**
 初始化
 */
- (instancetype)initWithTableView:(UITableView *)tableView {
    if (self = [super init]) {
        self.tableView = tableView;
    }
    return self;
}
/**
 寻找到需要播放的cell。must be called after reloadData && didAppear
 */
- (void)jo_playVideoInVisibleCellsIfNeed {
    if (self.jo_playingVideoCell) {
        [self playVideoWithCell:self.jo_playingVideoCell];
        return;
    }
    NSArray *visibleCells = [self.tableView visibleCells];
    UITableViewCell *targetCell = nil;
    if (self.jo_playVideoInVisibleCellsBlock) {
       targetCell = self.jo_playVideoInVisibleCellsBlock(visibleCells);
    } else {
        targetCell = [self findBestPlayVideoCell];
    }
    if (targetCell) {
        [self playVideoWithCell:targetCell];
    }
}

/**
 stop playing ifNeeded
 */
- (void)jo_stopPlayIfNeed {
    [self.jo_playingVideoCell.jo_videoPlayView jo_stopPlay];
    self.jo_playingVideoCell = nil;
}

/**
 must called in 'scrollViewDidScroll:'
 */
- (void)jo_scrollViewDidScroll {
    [self handleQuickScrollIfNeed];
}
/**
 must called in 'scrollViewDidEndDecelerating:'
 */
- (void)jo_scrollViewDidEndDecelerating {
    [self handleScrollStopIfNeed];
}

/**
 must called in `scrollViewDidEndDragging:willDecelerate:`
 */
- (void)jo_scrollViewDidEndDraggingWillDecelerate:(BOOL)decelerate {
    if (decelerate == NO) { //表示松手scorll就直接停止了
        [self handleScrollStopIfNeed];
    }
}
#pragma mark - private
- (void)handleScrollStopIfNeed {
    UITableViewCell *bestCell = [self findBestPlayVideoCell];
    if (!bestCell) {
        return;
    }
    if (bestCell == self.jo_playingVideoCell) {
        return;
    }
    
    [self.jo_playingVideoCell.jo_videoPlayView jo_stopPlay];
    [self playVideoWithCell:bestCell];
}
- (void)handleQuickScrollIfNeed {
    if (!self.jo_playingVideoCell) {
        return;
    }
    
    // Stop play when the cell playing video is un-visible.
    if (![self playingCellIsVisible]) {
        [self jo_stopPlayIfNeed];
    }
}
- (void)playVideoWithCell:(UITableViewCell *)cell {
    NSParameterAssert(cell);
    if(!cell){
        return;
    }
    self.jo_playingVideoCell = cell;
    if (self.jo_delegate && [self.jo_delegate respondsToSelector:@selector(tableView:willPlayVideoOnCell:)]) {
        [self.jo_delegate tableView:self.tableView willPlayVideoOnCell:cell];
    }
}
- (UITableViewCell *)findBestPlayVideoCell {

    CGRect tableViewVisibleFrame = self.tableView.frame;
    if(CGRectIsEmpty(tableViewVisibleFrame)){
        return nil;
    }
    // To find next cell need play video.
    UITableViewCell *targetCell = nil;
    UITableView *tableView = self.tableView;
    NSArray<UITableViewCell *> *visibleCells = [tableView visibleCells];
    if(self.jo_playVideoInVisibleCellsBlock){
        return self.jo_playVideoInVisibleCellsBlock(visibleCells);
    }
    
    CGFloat gap = MAXFLOAT;
    CGRect referenceRect = [tableView.superview convertRect:tableViewVisibleFrame toView:nil];
    
    for (UITableViewCell *cell in visibleCells) {
        if (!(cell.jo_videoURL.absoluteString.length > 0)) {
            continue;
        }
        // If need to play video.
        UIView *strategyView = self.playStrategy == JOScrollPlayStrategyTypeBestCell ? cell : cell.jo_videoPlayView;
        if(!strategyView){
            continue;
        }
        
        CGPoint coordinateCenterPoint = [strategyView.superview convertPoint:strategyView.center toView:nil];
        CGFloat delta = fabs(coordinateCenterPoint.y - referenceRect.size.height * 0.5 - referenceRect.origin.y);
        if (delta < gap) {
            gap = delta;
            targetCell = cell;
        }
    }
    
    return targetCell;
}
- (BOOL)playingCellIsVisible {
    CGRect tableViewVisibleFrame = self.tableView.frame;
    if(CGRectIsEmpty(tableViewVisibleFrame)){
        return NO;
    }
    if(!self.jo_playingVideoCell){
        return NO;
    }
    
    UIView *strategyView = self.playStrategy == JOScrollPlayStrategyTypeBestCell ? self.jo_playingVideoCell : self.jo_playingVideoCell.jo_videoPlayView;
    if(!strategyView){
        return NO;
    }
    return [self viewIsVisibleInTableViewVisibleFrame:strategyView];
}
- (BOOL)viewIsVisibleInTableViewVisibleFrame:(UIView *)view {
    CGRect tableViewVisibleFrame = self.tableView.frame;
    CGRect referenceRect = [self.tableView.superview convertRect:tableViewVisibleFrame toView:nil];
    CGPoint viewLeftTopPoint = view.frame.origin;
    viewLeftTopPoint.y += 1;
    CGPoint topCoordinatePoint = [view.superview convertPoint:viewLeftTopPoint toView:nil];
    BOOL isTopContain = CGRectContainsPoint(referenceRect, topCoordinatePoint);
    
    CGFloat viewBottomY = viewLeftTopPoint.y + view.bounds.size.height;
    viewBottomY -= 2;
    CGPoint viewLeftBottomPoint = CGPointMake(viewLeftTopPoint.x, viewBottomY);
    CGPoint bottomCoordinatePoint = [view.superview convertPoint:viewLeftBottomPoint toView:nil];
    BOOL isBottomContain = CGRectContainsPoint(referenceRect, bottomCoordinatePoint);
    if(!isTopContain && !isBottomContain){
        return NO;
    }
    return YES;
}
@end
