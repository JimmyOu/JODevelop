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
    }
    return self;
}

- (void)appDidBecomeActive {
    [self resnume];
}

- (void)appWillResignActive {

    [self pause];
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
    if (self.enableMonitor) {
        self.performanceMonitor = [[NEPerfomanceMonitor alloc] init];
        self.performanceMonitor = [NEPerfomanceMonitor sharedInstance];
        [self.performanceMonitor start];
    }
    
    if (self.enableFulencyMonitor) {
        self.fluencyMonitor = [NEFluencyMonitor sharedInstance];
        [self.fluencyMonitor startMonitoring];
    }
    if (self.showDebugView) {
        self.viewManager = [[NEMonitorViewManager alloc] init];
        [self.viewManager show];
    }
    
}

- (void)endMonitor {
    [self.performanceMonitor stop];
    [self.viewManager hide];
}


@end
