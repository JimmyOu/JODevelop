//
//  NEIndicatorWindow.m
//  JODevelop
//
//  Created by JimmyOu on 2018/8/7.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "NEIndicatorWindow.h"
#import "NEAppMonitor.h"
#import "SMCallTrace.h"
#define NE_IOS_VERSION ([[[UIDevice currentDevice] systemVersion] floatValue])
#define NE_IS_LANDSCAPE UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])
#define NE_SCREEN_WIDTH (NE_IOS_VERSION >= 8.0 ? [[UIScreen mainScreen] bounds].size.width : (NE_IS_LANDSCAPE ? [[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.width))

@interface NEIndicatorWindow()
@property (strong, nonatomic) UIButton *startTrace;

@end

@implementation NEIndicatorWindow
- (instancetype)init {
    if (NE_IOS_VERSION >= 9.0) {
        self = [super init];
    } else {
        self = [super initWithFrame:[UIScreen mainScreen].bounds];
    }
    if (self) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = [UIColor clearColor];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
        [_containerView addGestureRecognizer:pan];
        
        UIViewController *winRootVC = [[UIViewController alloc] init];
        [winRootVC.view addSubview:_containerView];
        self.backgroundColor = [UIColor clearColor];
        self.windowLevel = UIWindowLevelStatusBar + 10.0;
        self.rootViewController = winRootVC;
        
        [self setupUI];
        
        [self render];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}
- (void)panGesture:(UIPanGestureRecognizer *)pan {
    CGPoint location = [pan locationInView:pan.view.superview];
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        {
            _containerView.center = location;
        }
            break;
        case UIGestureRecognizerStateChanged:
            _containerView.center = location;
            break;
            
        case UIGestureRecognizerStateEnded:
            
            break;
        default:
            break;
    }
}
- (void)setupUI {
    CGFloat containerWidth = 75;
    CGFloat statusBarHeight = 20;
    UIStackView *stackView = [[UIStackView alloc] initWithFrame:CGRectMake(0, 0, containerWidth, statusBarHeight * 3)];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.distribution = UIStackViewDistributionFillEqually;
    _fpsButton = [[UIButton alloc] init];
    _fpsButton.backgroundColor = [UIColor grayColor];
    _fpsButton.titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
    _fpsButton.titleLabel.textColor = [UIColor whiteColor];
    _fpsButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_fpsButton setTitle:@" -- " forState:UIControlStateNormal];
    [_fpsButton addTarget:self action:@selector(didTapTipsButton) forControlEvents:UIControlEventTouchUpInside];
    
    [stackView addArrangedSubview:_fpsButton];
    
    
    _cpuUsageButton = [[UIButton alloc] init];
    _cpuUsageButton.backgroundColor = [UIColor grayColor];
    _cpuUsageButton.titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
    _cpuUsageButton.titleLabel.textColor = [UIColor whiteColor];
    _cpuUsageButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_cpuUsageButton setTitle:@" -- " forState:UIControlStateNormal];
    [_cpuUsageButton addTarget:self action:@selector(didTapTipsButton) forControlEvents:UIControlEventTouchUpInside];
    
    [stackView addArrangedSubview:_cpuUsageButton];
    
    
    _memoryUsageButton = [[UIButton alloc] init];
    _memoryUsageButton.backgroundColor = [UIColor grayColor];
    _memoryUsageButton.titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
    _memoryUsageButton.titleLabel.textColor = [UIColor whiteColor];
    _memoryUsageButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_memoryUsageButton setTitle:@" -- " forState:UIControlStateNormal];
    [_memoryUsageButton addTarget:self action:@selector(didTapTipsButton) forControlEvents:UIControlEventTouchUpInside];
    
    [stackView addArrangedSubview:_memoryUsageButton];
    
    [_containerView addSubview:stackView];
    
#if TARGET_IPHONE_SIMULATOR

#else
    _startTrace = [[UIButton alloc] init];
    _startTrace.layer.borderWidth = 1;
    _startTrace.layer.borderColor = [UIColor redColor].CGColor;
    _startTrace.backgroundColor = [UIColor lightGrayColor];
    _startTrace.titleLabel.font = [UIFont boldSystemFontOfSize:11.0];
    [_startTrace setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _startTrace.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_startTrace setTitle:@"开始追踪" forState:UIControlStateNormal];
    [_startTrace setTitle:@"停止追踪" forState:UIControlStateSelected];
    [_startTrace addTarget:self action:@selector(startTraceClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [_containerView addSubview:_startTrace];
#endif
    
    

    

}

- (void)startTraceClick:(UIButton *)btn {
    btn.selected = !btn.selected;
    if (btn.selected) {
        btn.backgroundColor = [UIColor greenColor];
        [SMCallTrace startWithMaxDepth:[NEAppMonitor sharedInstance].depth];
    } else {
        btn.backgroundColor = [UIColor lightGrayColor];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [SMCallTrace stopSaveAndClean];
        });
    }
}

- (void)orientationDidChange:(NSNotification *)notification {
    if (!self.hidden) {
        [self render];
    }
}
-(void)render {
    CGFloat screenWidth = NE_SCREEN_WIDTH;
    CGFloat containerWidth = 75;
    CGFloat statusBarHeight = 20;
    CGFloat statusBarWidth = screenWidth;
    CGFloat orignX = 0.0;
    
    CGFloat top = 5;
    CGFloat height = 50;
    if (@available(iOS 11.0, *)) {
        orignX = self.safeAreaInsets.top;
    }
    
    if (NE_IS_LANDSCAPE) {
        _containerView.frame = CGRectMake(screenWidth - containerWidth * 1.5, orignX, containerWidth, statusBarHeight * 3 + top + height);
    } else {
        _containerView.frame = CGRectMake(statusBarWidth - containerWidth * 1.5, orignX, containerWidth, statusBarHeight * 3 + top + height);
    }
    _startTrace.frame = CGRectMake(10, top + statusBarHeight * 3, height, height);
    
    _startTrace.layer.cornerRadius = height * 0.5;
    _startTrace.clipsToBounds = YES;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.hidden) {
        return nil;
    }
    if (event.type == UIEventTypeTouches && CGRectContainsPoint(_containerView.frame, point)) {
        CGPoint target = [self convertPoint:point toView:_containerView];
        if (CGRectContainsPoint(_startTrace.frame, target)) {
            return _startTrace;
        } else {
           return _fpsButton;
        }
    }
    return nil;
    
}
- (void)didTapTipsButton {
    [self.delegate indicatorWindowTapTipsButton:self];
}

@end
