//
//  NEMonitorDataCenter.h
//  JODevelop
//
//  Created by JimmyOu on 2018/8/7.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NEAppGraphicModel.h"
@interface NEMonitorDataCenter : NSObject

@property (strong, nonatomic) NSString *currentVCName;
@property (assign, nonatomic) NSInteger fps;
@property (strong, nonatomic) NSDate *startGraphicMonitorTime;
@property (nonatomic, copy) NSString *startGraphicMonitorTimeStr;

@property (strong, nonatomic) NEAppGraphicModel *battery;
@property (strong, nonatomic) NEAppGraphicModel *cpu;
@property (strong, nonatomic) NEAppGraphicModel *memory;


+ (instancetype)sharedInstance;

@end
