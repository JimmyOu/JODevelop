//
//  NEMonitorViewManager.h
//  JODevelop
//
//  Created by JimmyOu on 2018/8/7.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NEMonitorViewManager : NSObject

- (void)setFPS:(float)fps;
- (void)setCPU:(float)cpu;
- (void)setMemory:(float)memory;

- (void)show;
- (void)hide;
- (BOOL)isShowing;

@end
