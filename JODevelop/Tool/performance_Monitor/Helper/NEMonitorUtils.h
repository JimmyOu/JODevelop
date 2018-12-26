//
//  JOMonitorUtils.h
//  JODevelop
//
//  Created by JimmyOu on 2018/8/7.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <mach/mach.h>
#import "UIView+Extension.h"
#import "UIColor+Extension.h"

extern NSString *const NEMonitorExceptionThrowNotifiation;
extern NSString *const NEMonitorExceptionThrowNotifiationErrorKey;
extern NSString *const NEMonitorExceptionThrowNotifiationErrorCallStack;

@interface NEMonitorUtils : NSObject

+ (void)ne_swizzleSEL:(SEL)originalSEL withSEL:(SEL)swizzledSEL forClass:(Class)clz;
+ (void)ne_swizzleClassSEL:(SEL)originalSEL withSEL:(SEL)swizzledSEL forClass:(Class)clz;


/**
 获取所有堆栈的调用信息
 */
+ (NSString *)genCallStackReport;
/**
  获取当前堆栈的调用信息
 */
+ (NSString *)genCurrentThreadCallStackReport;
/**
 获取Main thread堆栈的调用信息
 */
+ (NSString *)genMainCallStackReport;
/**
 获取当指定堆栈的调用信息
 */
+ (NSString *)genThreadCallStackReportWithThread:(thread_t)thread;

//获取requestLength
+ (NSUInteger)getRequestLength:(NSURLRequest *)request;

//获取responseLength
+ (NSUInteger)getResponseLength:(NSHTTPURLResponse *)response withData:(NSData *)data;

#pragma mark - help
+ (__kindof UIViewController *)currentPresentVC;

+ (NSString *)statusCodeStringFromURLResponse:(NSURLResponse *)response;

+ (NSString *)formateStringFromRequestDuration:(NSTimeInterval)duration;

+ (void)notifyWithException:(NSException *)exception;
+ (void)notifyWithError:(NSError *)error;


/**
 获取app生成的所有类的名字
 */
+ (NSArray<NSString *> *)fetchAllAppClassName;

+ (NSArray<NSString *> *)filterViewControllerClassFromClasses:(NSArray<NSString *> *)allClass;



#pragma mark - Utils
+ (id)responseJSONFromData:(NSData *)data;

+ (NSString *)stringWithDate:(NSDate *)date;

+ (NSDate *)dateFromString:(NSString *)dateStr;

+ (NSTimeInterval)timeIntervalFrom:(NSDate *)from toDate:(NSDate *)to;

+ (NSString *)nextRequestID;

@end
