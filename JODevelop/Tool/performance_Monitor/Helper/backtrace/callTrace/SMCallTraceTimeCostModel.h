//
//  SMCallTraceTimeCostModel.h
//  DecoupleDemo
//
//  Created by JimmyOu on 2018/11/14.
//  Copyright © 2018年 com.netease. All rights reserved.

#import <Foundation/Foundation.h>

@interface SMCallTraceTimeCostModel : NSObject
@property (assign, nonatomic) long long pkid; //主键
@property (nonatomic, copy) NSString *className;       //类名
@property (nonatomic, copy) NSString *methodName;      //方法名
@property (nonatomic, assign) NSTimeInterval timeCost;   //时间消耗
@property (nonatomic, assign) NSUInteger callDepth;      //Call 层级
@property (nonatomic, copy) NSString *path;              //路径
@property (nonatomic, assign) BOOL lastCall;             //是否是最后一个 Call
@property (nonatomic, assign) NSUInteger frequency;      //访问频次

@property (nonatomic, strong) NSArray <SMCallTraceTimeCostModel *> *subCosts;
@property (nonatomic, assign) BOOL isClassMethod;        //是否是类方法

- (NSString *)des;

@end
