//
//  NEFluencyMonitor.m
//  JODevelop
//
//  Created by JimmyOu on 2018/8/8.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "NEFluencyMonitor.h"
#import "NEMonitorUtils.h"
#import "NEMonitorFileManager.h"
#import "NEMonitorDataCenter.h"
#import "NEMonitorToast.h"

dispatch_queue_t ne_fluency_monitor_queue() {
    static dispatch_queue_t ne_fluency_monitor_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ne_fluency_monitor_queue = dispatch_queue_create("com.ne_fluency_monitor_queue", NULL);
    });
    return ne_fluency_monitor_queue;
}
#define STUCKMONITORRATE 88
@interface NEFluencyMonitor() {
    NSInteger _timeoutCount;
    CFRunLoopObserverRef _runLoopObserver;
    BOOL _isGeneratingReport;
    CFTimeInterval _timeInterval;
}
@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@property (nonatomic, assign) CFRunLoopActivity runLoopActivity;
@end

@implementation NEFluencyMonitor

static void runLoopObserverCallBack(CFRunLoopObserverRef observer,
                                    CFRunLoopActivity activity,
                                    void* info)
{
    NEFluencyMonitor *appFluencyMonitor = (__bridge NEFluencyMonitor*)info;
    appFluencyMonitor.runLoopActivity = activity;
    appFluencyMonitor ->_timeInterval = CACurrentMediaTime();
    dispatch_semaphore_signal(appFluencyMonitor.semaphore);
}
- (void)dealloc
{
    [self stopMonitoring];
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static NEFluencyMonitor *monitor;
    dispatch_once(&onceToken, ^{
        monitor = [[NEFluencyMonitor alloc] init];
    });
    return monitor;
}
- (void)stopMonitoring
{
    if (!_runLoopObserver)
        return;
    
    CFRunLoopRemoveObserver(CFRunLoopGetMain(), _runLoopObserver, kCFRunLoopCommonModes);
    CFRelease(_runLoopObserver);
    _runLoopObserver = NULL;
    _timeInterval = 0;
}

- (void)startMonitoring
{
    // 已经有runloopObserver在监听时直接返回，不重复创建runloopObserver监听
    if (_runLoopObserver) {
        return;
    }
    _timeInterval = 0;
    //  创建信号量
    self.semaphore = dispatch_semaphore_create(0);
    
    
    // 注册RunLoop的状态监听
    CFRunLoopObserverContext context = {
        0,
        (__bridge void*)self,
        NULL,
        NULL
    };
    
    _runLoopObserver = CFRunLoopObserverCreate(kCFAllocatorDefault,
                                               kCFRunLoopAllActivities,
                                               YES,
                                               0,
                                               &runLoopObserverCallBack,
                                               &context);
    CFRunLoopAddObserver(CFRunLoopGetMain(),
                         _runLoopObserver,
                         kCFRunLoopCommonModes);
    
    // 在子线程监控时长
    dispatch_async(ne_fluency_monitor_queue(), ^{
        while (YES)
        {
            // 假定连续5次超时50ms认为卡顿(也包含了单次超时250ms)
            long st = dispatch_semaphore_wait(self.semaphore, dispatch_time(DISPATCH_TIME_NOW, STUCKMONITORRATE*NSEC_PER_MSEC));
            if (st != 0) {
                if (!self->_runLoopObserver) {
                    self->_timeoutCount = 0;
                    self.semaphore = 0;
                    self.runLoopActivity = 0;
                    return;
                }
                
                if (self.runLoopActivity == kCFRunLoopBeforeSources ||
                    self.runLoopActivity == kCFRunLoopAfterWaiting)
                {
                    if (++self->_timeoutCount < 3)
                        continue;
                    
                    [self handleCallbacksStackForMainThreadStucked];
                    //获取当前的vc，获取当前的view，获取当前的响应链
                    
                }
            }
            self->_timeoutCount = 0;
        }
    });
    
}

- (void)handleCallbacksStackForMainThreadStucked
{
    CGFloat time = CACurrentMediaTime() - self->_timeInterval;
    if (_isGeneratingReport) {
        return;
    }
    NSString *backtraceLogs = [NEMonitorUtils genMainCallStackReport];
    if (!backtraceLogs) {
        return;
    }
    _isGeneratingReport = YES;
    NSMutableString *logs = [NSMutableString stringWithFormat:@"卡顿时间:%.2f s",time];
    [logs appendString:backtraceLogs];
    [[NEMonitorFileManager shareInstance] saveReportToLocal:logs withFileName:[NEMonitorDataCenter sharedInstance].currentVCName type:NEMonitorFileFluentType];
    _isGeneratingReport = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
       [NEMonitorToast showToast:@"卡顿"];
    });
}


@end
