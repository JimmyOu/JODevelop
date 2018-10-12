//
//  NESystemInfoChartViewVC.m
//  SnailReader
//
//  Created by JimmyOu on 2018/10/9.
//  Copyright © 2018年 com.netease. All rights reserved.
//

#import "NESystemInfoChartViewVC.h"
#import "NEConstConstraints.h"
#import "JBLineChartView.h"
#import "NEChartHeaderView.h"
#import "NELineChartFooterView.h"
#import "NEChartInformationView.h"


// Numerics
CGFloat const kJBAreaChartViewControllerChartHeight = 250.0f;
CGFloat const kJBAreaChartViewControllerChartPadding = 10.0f;
CGFloat const kJBAreaChartViewControllerChartHeaderHeight = 75.0f;
CGFloat const kJBAreaChartViewControllerChartHeaderPadding = 20.0f;
CGFloat const kJBAreaChartViewControllerChartFooterHeight = 20.0f;
CGFloat const kJBAreaChartViewControllerChartLineWidth = 2.0f;
CGFloat const kJBAreaChartViewControllerChartSunLineDimmedOpacity = 1.0f;
CGFloat const kJBAreaChartViewControllerChartMoonLineDimmedOpacity = 0.0f;
NSInteger const kJBAreaChartViewControllerMaxNumChartPoints = 12;
#define ARC4RANDOM_MAX 0x100000000

typedef NS_ENUM(NSInteger, JBLineChartLine){
    JBLineChartLineSun,
    JBLineChartLineMoon,
    JBLineChartLineCount
};

@interface NESystemInfoChartViewVC ()<JBLineChartViewDelegate, JBLineChartViewDataSource>

@property (nonatomic, strong) JBLineChartView *lineChartView;
@property (nonatomic, strong) NEChartInformationView *informationView;
@property (nonatomic, strong) NSArray *chartData;
@property (nonatomic, strong) NSArray *timeData;




//- (void)initFakeData;
@end

@implementation NESystemInfoChartViewVC

+ (NSDateFormatter *)defaultDateFormatter {
    static NSDateFormatter *staticDateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticDateFormatter=[[NSDateFormatter alloc] init];
        [staticDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    });
    return staticDateFormatter;
}

- (instancetype)initWithData:(NSArray *)data time:(NSArray *)timeData {
    if (self = [super init]) {
        self.chartData = @[data];
        self.timeData = timeData;
    }
    return self;
}

//- (id)init
//{
//    self = [super init];
//    if (self)
//    {
//        [self initFakeData];
//    }
//    return self;
//}

#pragma mark - Data
//- (void)initFakeData
//{
//    NSMutableArray *mutableLineCharts = [NSMutableArray array];
//    for (int lineIndex=0; lineIndex<JBLineChartLineCount; lineIndex++)
//    {
//        NSMutableArray *mutableChartData = [NSMutableArray array];
//        for (int i=0; i<kJBAreaChartViewControllerMaxNumChartPoints; i++)
//        {
//            [mutableChartData addObject:[NSNumber numberWithFloat:((double)arc4random() / ARC4RANDOM_MAX) * 12]]; // random number between 0 and 12
//        }
//        [mutableLineCharts addObject:mutableChartData];
//    }
//    _chartData = [NSArray arrayWithArray:mutableLineCharts];
//    _monthlySymbols = [[[NSDateFormatter alloc] init] shortMonthSymbols];
//}


- (void)loadView {
    // Do any additional setup after loading the view.
    [super loadView];
    self.view.backgroundColor = kJBColorLineChartControllerBackground;
    
    self.lineChartView = [[JBLineChartView alloc] init];
    self.lineChartView.frame = CGRectMake(kJBAreaChartViewControllerChartPadding, kJBAreaChartViewControllerChartPadding, self.view.bounds.size.width - (kJBAreaChartViewControllerChartPadding * 2), kJBAreaChartViewControllerChartHeight);
    self.lineChartView.delegate = self;
    self.lineChartView.dataSource = self;
    self.lineChartView.headerPadding =kJBAreaChartViewControllerChartHeaderPadding;
    self.lineChartView.backgroundColor = kJBColorLineChartBackground;
    
    NEChartHeaderView *headerView = [[NEChartHeaderView alloc] initWithFrame:CGRectMake(kJBAreaChartViewControllerChartPadding, ceil(self.view.bounds.size.height * 0.5) - ceil(kJBAreaChartViewControllerChartHeaderHeight * 0.5), self.view.bounds.size.width - (kJBAreaChartViewControllerChartPadding * 2), kJBAreaChartViewControllerChartHeaderHeight)];
    headerView.titleLabel.text = self.titleText;
    headerView.titleLabel.textColor = kJBColorLineChartHeader;
    headerView.titleLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.25];
    headerView.titleLabel.shadowOffset = CGSizeMake(0, 1);
    headerView.subtitleLabel.text = [NSString stringWithFormat:@"startMonitorTime = %@",[[NESystemInfoChartViewVC defaultDateFormatter] stringFromDate:self.startDate]];
    headerView.subtitleLabel.textColor = kJBColorLineChartHeader;
    headerView.subtitleLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.25];
    headerView.subtitleLabel.shadowOffset = CGSizeMake(0, 1);
    headerView.separatorColor = kJBColorLineChartHeaderSeparatorColor;
    self.lineChartView.headerView = headerView;
    
    
    NELineChartFooterView *footerView = [[NELineChartFooterView alloc] initWithFrame:CGRectMake(kJBAreaChartViewControllerChartPadding, ceil(self.view.bounds.size.height * 0.5) - ceil(kJBAreaChartViewControllerChartFooterHeight * 0.5), self.view.bounds.size.width - (kJBAreaChartViewControllerChartPadding * 2), kJBAreaChartViewControllerChartFooterHeight)];
    footerView.backgroundColor = [UIColor clearColor];
    footerView.leftLabel.text = [[self.timeData firstObject] uppercaseString];
    footerView.leftLabel.textColor = [UIColor whiteColor];
    footerView.rightLabel.text = [[self.timeData lastObject] uppercaseString];;
    footerView.rightLabel.textColor = [UIColor whiteColor];
    footerView.sectionCount = 12;
    self.lineChartView.footerView = footerView;
    
    [self.view addSubview:self.lineChartView];
    
    self.informationView = [[NEChartInformationView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, CGRectGetMaxY(self.lineChartView.frame), self.view.bounds.size.width, self.view.bounds.size.height - CGRectGetMaxY(self.lineChartView.frame) - CGRectGetMaxY(self.navigationController.navigationBar.frame))];
    [self.informationView setValueAndUnitTextColor:[UIColor colorWithWhite:1.0 alpha:0.75]];
    [self.informationView setTitleTextColor:kJBColorLineChartHeader];
    [self.informationView setTextShadowColor:nil];
    [self.informationView setSeparatorColor:kJBColorLineChartHeaderSeparatorColor];
    [self.view addSubview:self.informationView];
    
    [self.lineChartView reloadData];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.lineChartView setState:JBChartViewStateExpanded];
}


#pragma mark - JBLineChartViewDataSource

- (NSUInteger)numberOfLinesInLineChartView:(JBLineChartView *)lineChartView
{
    return [self.chartData count];
}

- (NSUInteger)lineChartView:(JBLineChartView *)lineChartView numberOfVerticalValuesAtLineIndex:(NSUInteger)lineIndex
{
    return [[self.chartData objectAtIndex:lineIndex] count];
}

- (BOOL)lineChartView:(JBLineChartView *)lineChartView showsDotsForLineAtLineIndex:(NSUInteger)lineIndex
{
    return NO;
}

- (BOOL)lineChartView:(JBLineChartView *)lineChartView smoothLineAtLineIndex:(NSUInteger)lineIndex
{
    return YES;
}

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView dimmedSelectionOpacityAtLineIndex:(NSUInteger)lineIndex
{
    if (lineIndex == JBLineChartLineMoon)
    {
        return kJBAreaChartViewControllerChartMoonLineDimmedOpacity;
    }
    else
    {
        return kJBAreaChartViewControllerChartSunLineDimmedOpacity;
    }
}

#pragma mark - JBLineChartViewDelegate

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView verticalValueForHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    return [[[self.chartData objectAtIndex:lineIndex] objectAtIndex:horizontalIndex] floatValue];
}

- (void)lineChartView:(JBLineChartView *)lineChartView didSelectLineAtIndex:(NSUInteger)lineIndex horizontalIndex:(NSUInteger)horizontalIndex touchPoint:(CGPoint)touchPoint
{
    NSNumber *valueNumber = [[self.chartData objectAtIndex:lineIndex] objectAtIndex:horizontalIndex];
    NSString *unitText = (self.type == NESystemInfoChartTypeMemory) ? @"M":@"%";
    [self.informationView setValueText:[NSString stringWithFormat:@"%.1f", [valueNumber floatValue]] unitText:unitText];
    [self.informationView setTitleText:self.titleText];
    [self.informationView setHidden:NO animated:YES];
    [self setTooltipVisible:YES animated:YES atTouchPoint:touchPoint];
    [self.tooltipView setText:[[self.timeData objectAtIndex:horizontalIndex] uppercaseString]];
}

- (void)didDeselectLineInLineChartView:(JBLineChartView *)lineChartView
{
    [self.informationView setHidden:YES animated:YES];
    [self setTooltipVisible:NO animated:YES];
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView colorForLineAtLineIndex:(NSUInteger)lineIndex
{
    return (lineIndex == JBLineChartLineSun) ? kJBColorAreaChartDefaultSunLineColor: kJBColorAreaChartDefaultMoonLineColor;
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView fillColorForLineAtLineIndex:(NSUInteger)lineIndex
{
    return (lineIndex == JBLineChartLineSun) ? kJBColorAreaChartDefaultSunAreaColor : kJBColorAreaChartDefaultMoonAreaColor;
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView colorForDotAtHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    return (lineIndex == JBLineChartLineSun) ? kJBColorAreaChartDefaultSunLineColor: kJBColorAreaChartDefaultMoonLineColor;
}

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView widthForLineAtLineIndex:(NSUInteger)lineIndex
{
    return kJBAreaChartViewControllerChartLineWidth;
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView verticalSelectionColorForLineAtLineIndex:(NSUInteger)lineIndex
{
    return [UIColor whiteColor];
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView selectionColorForLineAtLineIndex:(NSUInteger)lineIndex
{
    return (lineIndex == JBLineChartLineSun) ? kJBColorAreaChartDefaultSunSelectedLineColor: kJBColorAreaChartDefaultMoonSelectedLineColor;
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView selectionFillColorForLineAtLineIndex:(NSUInteger)lineIndex
{
    return (lineIndex == JBLineChartLineSun) ? kJBColorAreaChartDefaultSunSelectedAreaColor : kJBColorAreaChartDefaultMoonSelectedAreaColor;
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView selectionColorForDotAtHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    return (lineIndex == JBLineChartLineSun) ? kJBColorAreaChartDefaultSunSelectedLineColor: kJBColorAreaChartDefaultMoonSelectedLineColor;
}

- (JBLineChartViewLineStyle)lineChartView:(JBLineChartView *)lineChartView lineStyleForLineAtLineIndex:(NSUInteger)lineIndex
{
    return JBLineChartViewLineStyleSolid;
}


#pragma mark - Overrides

- (JBChartView *)chartView
{
    return self.lineChartView;
}

@end
