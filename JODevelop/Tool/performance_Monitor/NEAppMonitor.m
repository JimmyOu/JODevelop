//
//  JOAppMonitor.m
//  JODevelop
//
//  Created by JimmyOu on 2018/8/6.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "NEAppMonitor.h"
#import "NEMonitorUtils.h"
#import "NEMonitorDataCenter.h"
#import "NEPerfomanceMonitor.h"
#import "NEMonitorViewManager.h"
#import "NEFluencyMonitor.h"
#import "NEHTTPMonitor.h"
#import "NECrashVoidManager.h"
#import "NEMonitorFileManager.h"
#import "NEMonitorToast.h"
#if defined(DEBUG)||defined(_DEBUG)
@implementation UIViewController(Monitor)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [NEMonitorUtils ne_swizzleSEL:@selector(viewWillAppear:) withSEL:@selector(ne_viewWillAppear:) forClass:[UIViewController class]];
    });
}
- (void)ne_viewWillAppear:(BOOL)animated {
    NSString *name = NSStringFromClass([self class]);
    if (![name isEqualToString:@"UIInputWindowController"]) {
        [NEMonitorDataCenter sharedInstance].currentVCName = name;
        NSLog(@"currentVCName = %@", [NEMonitorDataCenter sharedInstance].currentVCName);
    }
    [self ne_viewWillAppear:animated];

}

@end

@interface NEAppMonitor()
@property (strong, nonatomic) NEPerfomanceMonitor *performanceMonitor;
@property (strong, nonatomic) NEMonitorViewManager *viewManager;
@property (strong, nonatomic) NEFluencyMonitor *fluencyMonitor;
@end
@implementation NEAppMonitor

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static NEAppMonitor *monitor = nil;
    dispatch_once(&onceToken, ^{
        monitor = [[NEAppMonitor alloc] init];
    });
    return monitor;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillCrash:) name:NEMonitorExceptionThrowNotifiation object:nil];
    }
    return self;
}

- (void)appDidBecomeActive {
    [self resnume];
}

- (void)appWillResignActive {
    [self pause];
}
- (void)appWillCrash:(NSNotification *)notification {
   NSString *stack = notification.userInfo[NEMonitorExceptionThrowNotifiationErrorCallStack];
    [[NEMonitorFileManager shareInstance] saveReportToLocal:stack withFileName:[NEMonitorDataCenter sharedInstance].currentVCName type:NEMonitorFileCrashType];
    dispatch_async(dispatch_get_main_queue(), ^{
        [NEMonitorToast showToast:@"出现Crash"];
    });
}
- (void)pause {
    [self.performanceMonitor pause];
    [self.fluencyMonitor stopMonitoring];
}
- (void)resnume {
    [self.performanceMonitor resume];
    [self.fluencyMonitor startMonitoring];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)startMonitor {
    self.enablePerformanceMonitor = YES;
    self.enableFulencyMonitor = YES;
    self.enableNetworkMonitor = YES;
    self.enableVoidCrashOnLine = YES;
    //debug View
    self.viewManager = [[NEMonitorViewManager alloc] init];
    [self.viewManager show];
    
    if (self.enableVoidCrashOnLine) {
        [NECrashVoidManager swizzle];
    }
}
- (void)setEnableFulencyMonitor:(BOOL)enableFulencyMonitor {
    if (_enableFulencyMonitor != enableFulencyMonitor) {
        _enableFulencyMonitor = enableFulencyMonitor;
        if (enableFulencyMonitor) {
            self.fluencyMonitor = [NEFluencyMonitor sharedInstance];
            [self.fluencyMonitor startMonitoring];
        } else {
            [self.fluencyMonitor stopMonitoring];
        }
    }
}
- (void)setEnablePerformanceMonitor:(BOOL)enablePerformanceMonitor {
    if (_enablePerformanceMonitor != enablePerformanceMonitor) {
        _enablePerformanceMonitor = enablePerformanceMonitor;
        if (enablePerformanceMonitor) {
            self.performanceMonitor = [[NEPerfomanceMonitor alloc] init];
            [self.performanceMonitor start];
        } else {
            [self.performanceMonitor stop];
        }
    }
}
- (void)setEnableNetworkMonitor:(BOOL)enableNetworkMonitor {
    if (_enableNetworkMonitor != enableNetworkMonitor) {
        _enableNetworkMonitor = enableNetworkMonitor;
        [NEHTTPMonitor networkMonitor:enableNetworkMonitor];
    }
}

- (void)endMonitor {
    [self.performanceMonitor stop];
    [self.fluencyMonitor stopMonitoring];
    [self.viewManager hide];
    [NEHTTPMonitor networkMonitor:NO];
}


@end
#endif
