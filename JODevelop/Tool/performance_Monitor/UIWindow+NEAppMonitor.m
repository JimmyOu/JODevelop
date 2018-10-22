//
//  UIWindow+NEAppMonitor.m
//  SnailReader
//
//  Created by JimmyOu on 2018/10/12.
//  Copyright © 2018年 com.netease. All rights reserved.
//

#import "UIWindow+NEAppMonitor.h"
#import "NEAppMonitor.h"

@implementation UIWindow (NEAppMonitor)
#if defined(DEBUG)||defined(_DEBUG)
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    
    if (event.type == UIEventTypeMotion && event.subtype == UIEventSubtypeMotionShake) {
        
        if ([NEAppMonitor sharedInstance].viewManager.isShowing) {
            [[NEAppMonitor sharedInstance].viewManager show];
        } else {
            [[NEAppMonitor sharedInstance].viewManager hide];
        }
    }
    
}

#endif
@end
