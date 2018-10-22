//
//  JOMonitorUtils.h
//  JODevelop
//
//  Created by JimmyOu on 2018/8/7.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <mach/mach.h>

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

@end
