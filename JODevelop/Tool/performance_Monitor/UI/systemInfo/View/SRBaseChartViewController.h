//
//  SRBaseChartViewController.h
//  SnailReader
//
//  Created by JimmyOu on 2018/10/9.
//  Copyright © 2018年 com.netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JBChartView.h"
#import "NEChartTooltipView.h"



NS_ASSUME_NONNULL_BEGIN

@interface SRBaseChartViewController : UIViewController

@property (nonatomic, strong, readonly) NEChartTooltipView *tooltipView;
@property (nonatomic, assign) BOOL tooltipVisible;

// Settres
- (void)setTooltipVisible:(BOOL)tooltipVisible animated:(BOOL)animated atTouchPoint:(CGPoint)touchPoint;
- (void)setTooltipVisible:(BOOL)tooltipVisible animated:(BOOL)animated;

// Getters
- (JBChartView *)chartView; // subclasses to return chart instance for tooltip functionality

@end

NS_ASSUME_NONNULL_END
