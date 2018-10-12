//
//  SRBaseChartViewController.m
//  SnailReader
//
//  Created by JimmyOu on 2018/10/9.
//  Copyright © 2018年 com.netease. All rights reserved.
//

#import "SRBaseChartViewController.h"

// Views
#import "NEChartTooltipTipView.h"

// Numerics
CGFloat const kJBBaseChartViewControllerAnimationDuration = 0.1f;

@interface SRBaseChartViewController ()

@property (nonatomic, strong) NEChartTooltipView *tooltipView;
@property (nonatomic, strong) NEChartTooltipTipView *tooltipTipView;


@end

@implementation SRBaseChartViewController

- (void)loadView {
    [super loadView];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeTop;
    }
    self.view.backgroundColor = [UIColor whiteColor];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(back)];
}
- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - Orientation

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Setters

- (void)setTooltipVisible:(BOOL)tooltipVisible animated:(BOOL)animated atTouchPoint:(CGPoint)touchPoint
{
    _tooltipVisible = tooltipVisible;
    
    JBChartView *chartView = [self chartView];
    
    if (!chartView)
    {
        return;
    }
    
    if (!self.tooltipView)
    {
        self.tooltipView = [[NEChartTooltipView alloc] init];
        self.tooltipView.alpha = 0.0;
        [self.view addSubview:self.tooltipView];
    }
    
    [self.view bringSubviewToFront:self.tooltipView];
    
    if (!self.tooltipTipView)
    {
        self.tooltipTipView = [[NEChartTooltipTipView alloc] init];
        self.tooltipTipView.alpha = 0.0;
        [self.view addSubview:self.tooltipTipView];
    }
    
    [self.view bringSubviewToFront:self.tooltipTipView];
    
    dispatch_block_t adjustTooltipPosition = ^{
        
        CGPoint originalTouchPoint = [self.view convertPoint:touchPoint fromView:chartView];
        CGPoint convertedTouchPoint = originalTouchPoint; // modified
        JBChartView *chartView = [self chartView];
        if (chartView && !CGPointEqualToPoint(touchPoint, CGPointZero))
        {
            CGFloat minChartX = (chartView.frame.origin.x + ceil(self.tooltipView.frame.size.width * 0.5));
            if (convertedTouchPoint.x < minChartX)
            {
                convertedTouchPoint.x = minChartX;
            }
            CGFloat maxChartX = (chartView.frame.origin.x + chartView.frame.size.width - ceil(self.tooltipView.frame.size.width * 0.5));
            if (convertedTouchPoint.x > maxChartX)
            {
                convertedTouchPoint.x = maxChartX;
            }
            
            self.tooltipView.frame = CGRectMake(convertedTouchPoint.x - ceil(self.tooltipView.frame.size.width * 0.5), CGRectGetMaxY(chartView.headerView.frame), self.tooltipView.frame.size.width, self.tooltipView.frame.size.height);
            
            CGFloat minTipX = (chartView.frame.origin.x + self.tooltipTipView.frame.size.width);
            if (originalTouchPoint.x < minTipX)
            {
                originalTouchPoint.x = minTipX;
            }
            CGFloat maxTipX = (chartView.frame.origin.x + chartView.frame.size.width - self.tooltipTipView.frame.size.width);
            if (originalTouchPoint.x > maxTipX)
            {
                originalTouchPoint.x = maxTipX;
            }
            self.tooltipTipView.frame = CGRectMake(originalTouchPoint.x - ceil(self.tooltipTipView.frame.size.width * 0.5), CGRectGetMaxY(self.tooltipView.frame), self.tooltipTipView.frame.size.width, self.tooltipTipView.frame.size.height);
        }
    };
    
    dispatch_block_t adjustTooltipVisibility = ^{
        self.tooltipView.alpha = self.tooltipVisible ? 1.0 : 0.0;
        self.tooltipTipView.alpha = self.tooltipVisible ? 1.0 : 0.0;
    };
    
    if (animated)
    {
        if (tooltipVisible)
        {
            adjustTooltipPosition();
        }
        
        [UIView animateWithDuration:kJBBaseChartViewControllerAnimationDuration delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            adjustTooltipVisibility();
        } completion:^(BOOL finished) {
            if (!tooltipVisible)
            {
                adjustTooltipPosition();
            }
        }];
    }
    else
    {
        adjustTooltipPosition();
        adjustTooltipVisibility();
    }
}

- (void)setTooltipVisible:(BOOL)tooltipVisible animated:(BOOL)animated
{
    [self setTooltipVisible:tooltipVisible animated:animated atTouchPoint:CGPointZero];
}

- (void)setTooltipVisible:(BOOL)tooltipVisible
{
    [self setTooltipVisible:tooltipVisible animated:NO];
}

#pragma mark - Getters

- (JBChartView *)chartView
{
    // Subclasses should return chart instance for tooltip functionality
    return nil;
}


@end
