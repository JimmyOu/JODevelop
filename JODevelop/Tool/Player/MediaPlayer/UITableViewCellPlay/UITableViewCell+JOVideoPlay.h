//
//  UITableViewCell+JOVideoPlay.h
//  JODevelop
//
//  Created by JimmyOu on 2018/6/21.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger , JOVideoPlayerUnreachableCellType) {
    JOVideoPlayerUnreachableCellTypeNone = 0,
    JOVideoPlayerUnreachableCellTypeTop = 1,
    JOVideoPlayerUnreachableCellTypeDown = 2
};

@interface UITableViewCell (JOVideoPlay)

@property (nonatomic, nullable) NSURL *jo_videoURL;

@property (nonatomic, nullable) UIView *jo_videoPlayView;

@property(nonatomic) JOVideoPlayerUnreachableCellType jo_unreachableCellType;


@end
