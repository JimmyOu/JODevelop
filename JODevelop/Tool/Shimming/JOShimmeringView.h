//
//  JOShimmeringView.h
//  模块化Demo
//
//  Created by JimmyOu on 17/3/30.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JOShimmering.h"

@interface JOShimmeringView : UIView<JOShimmering>

@property (nonatomic, strong) UIView *contentView;

@end
