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
#import "NEMemoryInfo.h"
#import <mach/mach_time.h>

@interface NEPerfomanceMonitor()
@property (strong, nonatomic) CADisplayLink *displayLink;
@property (assign, nonatomic) BOOL isPause;

@end

#pragma mark - 启动时间
static uint64_t loadTime;
static uint64_t applicationRespondedTime = -1;
static mach_timebase_info_data_t timebaseInfo;

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
    }
    return self;
}

- (void)dealloc {
    [_displayLink invalidate];
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
