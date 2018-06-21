//
//  JOVideoControlBar.h
//  JODevelop
//
//  Created by JimmyOu on 2018/6/20.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JOVideoPlayerProtocol.h"
@interface JOVideoControlBar : UIView<JOVideoPlayerProtocol>

@property (nonatomic, strong, readonly) UIButton *playButton;

@property (nonatomic, strong, readonly) UIView<JOVideoPlayerControlProgressProtocol> *progressView;

@property (nonatomic, strong, readonly) UILabel *timeLabel;

@property (nonatomic, strong, readonly) UIButton *landscapeButton;


@property (nonatomic, weak) UIView *playerView;


@end
