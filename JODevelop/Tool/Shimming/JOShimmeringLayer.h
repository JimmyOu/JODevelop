//
//  JOShimmeringLayer.h
//  模块化Demo
//
//  Created by JimmyOu on 17/3/30.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "JOShimmering.h"

@interface JOShimmeringLayer : CALayer <JOShimmering>

//! @abstract The content layer to be shimmered.
@property (strong, nonatomic) CALayer *contentLayer;

@end
