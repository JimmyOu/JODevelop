//
//  NEPerfomanceMonitor.m
//  JODevelop
//
//  Created by JimmyOu on 2018/8/8.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "NEPerfomanceMonitor.h"
#import "NEAppMonitor.h"
#import "NECPUInfo.h"
#import "NEBatteryInfo.h"
#import "NEMemoryInfo.h"
#import <mach/mach.h>
#include <mach/mach_time.h>

#import "NEMonitorUtils.h"
#import "NEMonitorFileManager.h"
#import "NEMonitorDataCenter.h"
#import "NEMonitorToast.h"
#import "NEMonitorDataCenter.h"
//#define CPUMONITORRATE 80


@interface NEPerfomanceMonitor()
@property (strong, nonatomic) CADisplayLink *displayLink;
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) BOOL isPause;
@property (assign, nonatomic) BOOL isGeneratingReport;
//@property (nonatomic, strong) NSTimer *cpuMonitorTimer;

@end

#pragma mark - 启动时间
static uint64_t loadTime;
static uint64_t applicationRespondedTime = -1;
static mach_timebase_info_data_t timebaseInfo;
//static NSInteger CPUMONITORRATE = 80;

static inline NSTimeInterval MachTimeToSeconds(uint64_t machTime) {
    return ((machTime / 1e9) * timebaseInfo.numer) / timebaseInfo.denom;
}

@implementation NEPerfomanceMonitor {
    //fps
    NSUInteger _historyCount;
    CFTimeInterval _lastTickTimestamp;
    CFTimeInterval _lastUpdateTimestamp;
}

+ (void)load {
    loadTime = mach_absolute_time();
    mach_timebase_info(&timebaseInfo);
    @autoreleasepool { //冷启动时间
        __block id<NSObject> obs;
        obs = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification
                                                                object:nil queue:nil
                                                            usingBlock:^(NSNotification *note) {
                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                    applicationRespondedTime = mach_absolute_time();
                                                                    NSLog(@"StartupMeasurer: it took %f seconds until the app could respond to user interaction.", MachTimeToSeconds(applicationRespondedTime - loadTime));
                                                                });
                                                                [[NSNotificationCenter defaultCenter] removeObserver:obs];
                                                            }];
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isPause = YES;
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkTick:)];
        _displayLink.frameInterval = 2;
        [_displayLink setPaused:YES];
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        
        self.timer = [NSTimer timerWithTimeInterval:5 target:self selector:@selector(updateGraphicInfo) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        
////        //监测 CPU 消耗
//        self.cpuMonitorTimer = [NSTimer scheduledTimerWithTimeInterval:0.02
//                                                                target:self
//                                                              selector:@selector(updateCPUInfo)
//                                                              userInfo:nil
//                                                               repeats:YES];
    }
    return self;
}

- (void)dealloc {
    [_displayLink invalidate];
    [_timer invalidate];
//    [_cpuMonitorTimer invalidate];
}

- (void)start {
    _isPause = NO;
    [_displayLink setPaused:NO];
}
- (void)stop {
    _isPause = YES;
    [_displayLink invalidate];
    
}
- (void)pause {
    _isPause = YES;
    [_displayLink setPaused:YES];
    
}
- (void)resume {
    if (_isPause) {
        [self start];
    }
}
- (void)displayLinkTick:(CADisplayLink *)displayLink {
    [self calculateFPS];
    [self calculateCPU];
    [self calculateMemory];
}
- (void)updateGraphicInfo {
    if (![NEMonitorDataCenter sharedInstance].startGraphicMonitorTime) {
        [NEMonitorDataCenter sharedInstance].startGraphicMonitorTime = [NSDate date];
    }
    
    NSDate *currentDate = [NSDate date];
    NSTimeInterval time = [currentDate timeIntervalSinceDate:[NEMonitorDataCenter sharedInstance].startGraphicMonitorTime];
    
    float cpuUsage = [NECPUInfo appCpuUsage]; //%
    NSUInteger usedMemory =  [NEMemoryInfo getAppUsedMemory];// M
    float batteryLevel = [NEBatteryInfo batteryLevel]; //  1%
    
    if (cpuUsage != -1) {
        
        [[NEMonitorDataCenter sharedInstance].cpu addTime:[NSString stringWithFormat:@"%.0fs",time] value:@(cpuUsage)];
    }
    if (usedMemory != -1) {
        [[NEMonitorDataCenter sharedInstance].memory addTime:[NSString stringWithFormat:@"%.0fs",time] value:@(usedMemory)];
    }
    if (batteryLevel != -1) {
        [[NEMonitorDataCenter sharedInstance].battery addTime:[NSString stringWithFormat:@"%.0fs",time] value:@(batteryLevel)];
    }
}


//- (void)updateCPUInfo { //这里弄出来的只是timer的堆栈，看不到信息
//    thread_act_array_t threads;
//    mach_msg_type_number_t threadCount = 0;
//    const task_t thisTask = mach_task_self();
//    kern_return_t kr = task_threads(thisTask, &threads, &threadCount);
//    if (kr != KERN_SUCCESS) {
//        return;
//    }
//    for (int i = 0; i < threadCount; i++) {
//        thread_info_data_t threadInfo;
//        thread_basic_info_t threadBaseInfo;
//        mach_msg_type_number_t threadInfoCount = THREAD_INFO_MAX;
//        if (thread_info((thread_act_t)threads[i], THREAD_BASIC_INFO, (thread_info_t)threadInfo, &threadInfoCount) == KERN_SUCCESS) {
//            threadBaseInfo = (thread_basic_info_t)threadInfo;
//            if (!(threadBaseInfo->flags & TH_FLAGS_IDLE)) {
//                integer_t cpuUsage = threadBaseInfo->cpu_usage / 10;
//                if (cpuUsage > CPUMONITORRATE) {
//                    [self generateCallStackIfNeeded:threads[i]];
//
//                }
//            }
//        }
//    }
//}
//- (void)generateCallStackIfNeeded:(thread_t)thread {
//    if (_isGeneratingReport) {
//        return;
//    }
//    NSString *backtraceLogs =  [NEMonitorUtils genThreadCallStackReportWithThread:thread];
//
//    if (!backtraceLogs || [backtraceLogs containsString:@"[NEPerfomanceMonitor generateCallStackIfNeeded:]"]) {
//        return;
//    }
//    _isGeneratingReport = YES;
//    [[NEMonitorFileManager shareInstance] saveReportToLocal:backtraceLogs withFileName:[NEMonitorDataCenter sharedInstance].currentVCName type:NEMonitorFileHighCPUType];
//    _isGeneratingReport = NO;
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [NEMonitorToast showToast:@"高CPU"];
//    });
//}
- (void)calculateFPS {
    _lastTickTimestamp = CACurrentMediaTime() * 1000.0;
    if (_lastUpdateTimestamp <= 0) {
        _lastUpdateTimestamp = self.displayLink.timestamp;
        return;
    }
    
    _historyCount += self.displayLink.frameInterval;
    
    CFTimeInterval interval = self.displayLink.timestamp - _lastUpdateTimestamp;
    if(interval >= 1) {
        _lastUpdateTimestamp = self.displayLink.timestamp;
        NSInteger currentFPS = _historyCount / interval;
        _historyCount = 0;
         [[NEAppMonitor sharedInstance].viewManager setFPS:currentFPS];
    }
}
- (void)calculateCPU {
    float cpuUsage = [NECPUInfo appCpuUsage];
    [[NEAppMonitor sharedInstance].viewManager setCPU:cpuUsage];
}
- (void)calculateMemory {
    [[NEAppMonitor sharedInstance].viewManager setMemory:[NEMemoryInfo getAppUsedMemory]];
}


@end
