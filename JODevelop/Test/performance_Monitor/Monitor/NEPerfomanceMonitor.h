//
//  NEPerfomanceMonitor.h
//  JODevelop
//
//  Created by JimmyOu on 2018/8/8.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NEPerfomanceMonitor : NSObject

- (void)start;
- (void)stop;
- (void)pause;
- (void)resume;

@end
