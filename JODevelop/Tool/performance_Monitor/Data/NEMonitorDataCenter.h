//
//  NEMonitorDataCenter.h
//  JODevelop
//
//  Created by JimmyOu on 2018/8/7.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NEMonitorDataCenter : NSObject

@property (strong, nonatomic) NSString *currentVCName;
@property (assign, nonatomic) NSInteger fps;


+ (instancetype)sharedInstance;

@end
