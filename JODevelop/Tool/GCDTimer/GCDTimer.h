//
//  GCDTimer.h
//  JODevelop
//
//  Created by JimmyOu on 2017/11/22.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCDTimer : NSObject
#pragma mark - 类方法初始化，queue如果是nil则用defaultPriority优先级的并发队列
+ (instancetype)scheduledDispatchTimerWithName:(NSString *)timerName
                                  timeInterval:(NSTimeInterval)interval
                                         queue:(dispatch_queue_t)queue
                                       repeats:(BOOL)repeats
                                        action:(dispatch_block_t)action;

- (void)cancelTimerWithName:(NSString *)timerName;

@end
