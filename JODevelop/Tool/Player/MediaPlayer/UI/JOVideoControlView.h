//
//  JOVideoControlView.h
//  JODevelop
//
//  Created by JimmyOu on 2018/6/20.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JOVideoPlayerProtocol.h"
@interface JOVideoControlView : UIView<JOVideoPlayerProtocol>

@property (nonatomic, strong, readonly) UIView<JOVideoPlayerProtocol> *controlBar;

@property (nonatomic, strong, readonly) UIImage *blurImage;


- (instancetype)initWithControlBar:(UIView<JOVideoPlayerProtocol> *_Nullable)controlBar
                         blurImage:(UIImage *_Nullable)blurImage NS_DESIGNATED_INITIALIZER;

@end
