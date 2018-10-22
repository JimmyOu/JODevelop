//
//  NESystemInfoChartViewVC.h
//  SnailReader
//
//  Created by JimmyOu on 2018/10/9.
//  Copyright © 2018年 com.netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRBaseChartViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, NESystemInfoChartType){
    NESystemInfoChartTypeCPU,
    NESystemInfoChartTypeMemory,
    NESystemInfoChartTypeBattery
};

@interface NESystemInfoChartViewVC : SRBaseChartViewController

@property (nonatomic, copy) NSString *titleText;
@property (strong, nonatomic) NSDate *startDate;
@property (assign, nonatomic) NESystemInfoChartType type;

- (instancetype)initWithData:(NSArray *)data time:(NSArray *)timeData;


@end

NS_ASSUME_NONNULL_END
