//
//  UITableView+JOVideoPlay.m
//  JODevelop
//
//  Created by JimmyOu on 2018/6/21.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "UITableView+JOVideoPlay.h"
#import "JOVideoPlayerTableViewHelper.h"
#import <objc/runtime.h>

@interface UITableView()

@property (strong, nonatomic) JOVideoPlayerTableViewHelper *helper;

@end

@implementation UITableView (JOVideoPlay)
- (void)setJo_delegate:(id<JOTableViewVideoPlayDelegate>)jo_delegate {
    self.helper.jo_delegate = jo_delegate;
}
- (id<JOTableViewVideoPlayDelegate>)jo_delegate {
    return self.helper.jo_delegate;
}
- (UITableViewCell *)jo_playingVideoCell {
    return self.helper.jo_playingVideoCell;
}
- (void)setJo_playingVideoCell:(UITableViewCell *)jo_playingVideoCell {
    self.helper.jo_playingVideoCell = jo_playingVideoCell;
}
- (void)setJo_playStrategy:(JOScrollPlayStrategyType)jo_playStrategy {
    self.helper.playStrategy = jo_playStrategy;
}
- (JOScrollPlayStrategyType)jo_playStrategy {
    return self.helper.playStrategy;
}
- (void)setJo_playVideoInVisibleCellsBlock:(JOPlayVideoInVisibleCellsBlock)jo_playVideoInVisibleCellsBlock {
    self.helper.jo_playVideoInVisibleCellsBlock = jo_playVideoInVisibleCellsBlock;
}
- (JOPlayVideoInVisibleCellsBlock)jo_playVideoInVisibleCellsBlock {
    return self.helper.jo_playVideoInVisibleCellsBlock;
}

/**
 寻找到需要播放的cell。must be called after reloadData && didAppear
 */
- (void)jo_playVideoInVisibleCellsIfNeed {
    [self.helper jo_playVideoInVisibleCellsIfNeed];
}

/**
 stop playing ifNeeded
 */
- (void)jo_stopPlayIfNeed {
    [self.helper jo_stopPlayIfNeed];
}

/**
 must called in 'scrollViewDidScroll:'
 */
- (void)jo_scrollViewDidScroll {
    [self.helper jo_scrollViewDidScroll];
}
/**
 must called in 'scrollViewDidEndDecelerating:'
 */
- (void)jo_scrollViewDidEndDecelerating {
    [self.helper jo_scrollViewDidEndDecelerating];
}

/**
 must called in `scrollViewDidEndDragging:willDecelerate:`
 */
- (void)jo_scrollViewDidEndDraggingWillDecelerate:(BOOL)decelerate {
    [self.helper jo_scrollViewDidEndDraggingWillDecelerate:decelerate];
}

- (void)jo_playCellAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
    [self.helper playVideoWithCell:cell];
}


#pragma mark -private
- (JOVideoPlayerTableViewHelper *)helper {
    JOVideoPlayerTableViewHelper *helper = objc_getAssociatedObject(self, _cmd);
    if (!helper) {
        helper = [[JOVideoPlayerTableViewHelper alloc] initWithTableView:self];
        objc_setAssociatedObject(self, _cmd, helper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return helper;
}

@end
