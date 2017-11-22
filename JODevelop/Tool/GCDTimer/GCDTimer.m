//
//  GCDTimer.m
//  JODevelop
//
//  Created by JimmyOu on 2017/11/22.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "GCDTimer.h"

@interface GCDTimer()

@property (nonatomic, strong) NSMutableDictionary *timerContainer;
@end
@implementation GCDTimer

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.timerContainer = [NSMutableDictionary new];
    }
    return self;
}


//设置一个timerContainer容器捕获所有timer，key：timerName ，value：timer
+ (instancetype)scheduledDispatchTimerWithName:(NSString *)timerName
                          timeInterval:(NSTimeInterval)interval
                                 queue:(dispatch_queue_t)queue
                               repeats:(BOOL)repeats
                                action:(dispatch_block_t)action {
    
    NSParameterAssert(timerName);
    GCDTimer *gcdTimer = [[GCDTimer alloc] init];
    if (!queue) {
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    dispatch_source_t timer = [gcdTimer.timerContainer objectForKey:timerName];
    if (!timer) {
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        [gcdTimer.timerContainer setObject:timer forKey:timerName];
        dispatch_resume(timer);
    }
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC), interval * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);
    __weak GCDTimer *weakTimer = gcdTimer;
    dispatch_source_set_event_handler(timer, ^{
        action();
        if (!repeats) {
            [weakTimer cancelTimerWithName:timerName];
        }
    });
    return gcdTimer;
}

- (void)cancelTimerWithName:(NSString *)timerName {
    dispatch_source_t timer = [self.timerContainer objectForKey:timerName];
    if (!timer) {
        return ;
    }
    [self.timerContainer removeObjectForKey:timerName];
    dispatch_source_cancel(timer);
}

@end
