//
//  JOMonitorUtils.m
//  JODevelop
//
//  Created by JimmyOu on 2018/8/7.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "NEMonitorUtils.h"
#import <objc/runtime.h>
#import <mach/mach.h>
#import "SMCallStack.h"
#import <dlfcn.h>
#import <mach-o/ldsyms.h>

NSString *const NEMonitorExceptionThrowNotifiation = @"NEMonitorExceptionThrowNotifiation";
NSString *const NEMonitorExceptionThrowNotifiationErrorKey = @"NEMonitorExceptionThrowNotifiationErrorKey";
NSString *const NEMonitorExceptionThrowNotifiationErrorCallStack = @"NEMonitorExceptionThrowNotifiationErrorCallStack";

@implementation NEMonitorUtils
+ (void)ne_swizzleSEL:(SEL)originalSEL withSEL:(SEL)swizzledSEL forClass:(Class)clz {
    Method originalMethod = class_getInstanceMethod(clz, originalSEL);
    Method swizzledMethod = class_getInstanceMethod(clz, swizzledSEL);
    
    BOOL didAddMethod =
    class_addMethod(clz,
                    originalSEL,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(clz,
                            swizzledSEL,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}
+ (void)ne_swizzleClassSEL:(SEL)originalSEL withSEL:(SEL)swizzledSEL forClass:(Class)clz {
    Method method1 = class_getClassMethod(clz, originalSEL);
    Method method2 = class_getClassMethod(clz, swizzledSEL);
    method_exchangeImplementations(method1, method2);
}
+ (NSString *)genCallStackReport {
    @try {
        return [SMCallStack callStackWithType:SMCallStackTypeAll];
    }
    @catch (NSException * e){
        return @"";
    }
}
+ (NSString *)genMainCallStackReport {
    @try {
        return [SMCallStack callStackWithType:SMCallStackTypeMain];
    }
    @catch (NSException * e){
        return @"";
    }
}
+ (NSString *)genCurrentThreadCallStackReport {
    @try {
        return [SMCallStack callStackWithType:SMCallStackTypeCurrent];
    }
    @catch (NSException * e){
        return @"";
    }
}
+ (NSString *)genThreadCallStackReportWithThread:(thread_t)thread {
    @try {
        return smStackOfThread(thread);
    }
    @catch (NSException * e){
        return @"";
    }
}
+ (void)notifyWithException:(NSException *)exception {
    // 记录调用栈信息
    NSMutableArray<NSString *> *callbackSymbolsMArray = [[exception callStackSymbols] mutableCopy];
    NSString *callbackSymbols = [callbackSymbolsMArray componentsJoinedByString:@"\n"];
    callbackSymbols = callbackSymbols ?:@"";
    NSString *name = exception.name ?:@"";
    NSString *reason = exception.reason?:@"";
    NSError *error = [NSError errorWithDomain:name code:0 userInfo:@{NSLocalizedDescriptionKey:reason}];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NEMonitorExceptionThrowNotifiation object:self userInfo:@{NEMonitorExceptionThrowNotifiationErrorKey:error, NEMonitorExceptionThrowNotifiationErrorCallStack:callbackSymbols}];
    });
}
+ (void)notifyWithError:(NSError *)error {
    NSString *callbackString = [[self genCurrentThreadCallStackReport] mutableCopy];
    dispatch_async(dispatch_get_main_queue(), ^{
    [[NSNotificationCenter defaultCenter] postNotificationName:NEMonitorExceptionThrowNotifiation object:self userInfo:@{NEMonitorExceptionThrowNotifiationErrorKey:error, NEMonitorExceptionThrowNotifiationErrorCallStack:callbackString}];
    });
}
+ (NSUInteger)getResponseLength:(NSHTTPURLResponse *)response withData:(NSData *)data{
    int64_t responseLength = 0;
    if (response && [response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSDictionary<NSString *, NSString *> *headerFields = httpResponse.allHeaderFields;
        NSUInteger headersLength = [self p_getHeadersLength:headerFields];
        int64_t contentLength = (httpResponse.expectedContentLength != NSURLResponseUnknownLength) ?
        httpResponse.expectedContentLength :
        data.length;
        responseLength = headersLength + contentLength;
    }
    return (int)responseLength;
}

+ (NSString *)statusCodeStringFromURLResponse:(NSURLResponse *)response
{
    NSString *httpResponseString = nil;
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSString *statusCodeDescription = nil;
        if (httpResponse.statusCode == 200) {
            // Prefer OK to the default "no error"
            statusCodeDescription = @"OK";
        } else {
            statusCodeDescription = [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode];
        }
        httpResponseString = [NSString stringWithFormat:@"%ld %@", (long)httpResponse.statusCode, statusCodeDescription];
    }
    return httpResponseString;
}
+ (NSString *)formateStringFromRequestDuration:(NSTimeInterval)duration
{
    NSString *string = @"0s";
    if (duration > 0.0) {
        if (duration < 1.0) {
            string = [NSString stringWithFormat:@"%dms", (int)(duration * 1000)];
        } else if (duration < 10.0) {
            string = [NSString stringWithFormat:@"%.2fs", duration];
        } else {
            string = [NSString stringWithFormat:@"%.1fs", duration];
        }
    }
    return string;
}


+ (NSUInteger)getRequestLength:(NSURLRequest *)request {
    NSDictionary<NSString *, NSString *> *headerFields = request.allHTTPHeaderFields;
    NSDictionary<NSString *, NSString *> *cookiesHeader = [self p_getCookiesWithURL:request.URL];
    if (cookiesHeader.count) {
        NSMutableDictionary *headerFieldsWithCookies = [NSMutableDictionary dictionaryWithDictionary:headerFields];
        [headerFieldsWithCookies addEntriesFromDictionary:cookiesHeader];
        headerFields = [headerFieldsWithCookies copy];
    }
    
    NSUInteger headersLength = [self p_getHeadersLength:headerFields];
    NSUInteger bodyLength = [self p_getRequestLength:request];
    return headersLength + bodyLength;
}
+ (NSUInteger)p_getHeadersLength:(NSDictionary *)headers {
    NSUInteger headersLength = 0;
    if (headers) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:headers
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
        headersLength = data.length;
    }
    
    return headersLength;
}
+ (NSUInteger)p_getRequestLength:(NSURLRequest *)request {
    NSUInteger bodyLength = [request.HTTPBody length];
     NSData *bodyData;
    if (request.HTTPBody == nil) {
        uint8_t d[1024] = {0};
        NSInputStream *stream = request.HTTPBodyStream;
        NSMutableData *data = [[NSMutableData alloc] init];
        [stream open];
        while ([stream hasBytesAvailable]) {
            NSInteger len = [stream read:d maxLength:1024];
            if (len > 0 && stream.streamError == nil) {
                [data appendBytes:(void *)d length:len];
            }
        }
        bodyData = [data copy];
        [stream close];
        return data.length;
    } else {
        return bodyLength;
    }
}

+ (NSDictionary<NSString *, NSString *> *)p_getCookiesWithURL:(NSURL *)url {
    NSDictionary<NSString *, NSString *> *cookiesHeader;
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray<NSHTTPCookie *> *cookies = [cookieStorage cookiesForURL:url];
    if (cookies.count) {
        cookiesHeader = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
    }
    return cookiesHeader;
}
+ (__kindof UIViewController *)currentPresentVC {
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *hostVC = rootVC;
    while (hostVC.presentedViewController) {
        hostVC = hostVC.presentedViewController;
    }
    hostVC = hostVC ?: rootVC;
    return hostVC;
}

+ (NSArray<NSString *> *)fetchAllAppClassName {
    
    unsigned int count;
    const char **classes;
    Dl_info info;
    
    //1.获取app的路径
    dladdr(&_mh_execute_header, &info);
    
    //2.返回当前运行的app的所有类的名字，并传出个数
    //classes：二维数组 存放所有类的列表名称
    //count：所有的类的个数
    classes = objc_copyClassNamesForImage(info.dli_fname, &count);
    NSMutableArray *classList = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count; i++) {
        NSString *className = [NSString stringWithCString:classes[i] encoding:NSUTF8StringEncoding];
        if (![className isEqualToString:@""] && className) {
            [classList addObject:className];
        }
    }
    return [classList copy];
}

+ (NSArray<NSString *> *)filterViewControllerClassFromClasses:(NSArray<NSString *> *)allClass {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:allClass.count];
    for (NSString *cls in allClass) {
        Class class = NSClassFromString(cls);
        if ([class isSubclassOfClass:[UIViewController class]]) {
            [array addObject:cls];
        }
    }
    return [array copy];
    
}


+ (id)responseJSONFromData:(NSData *)data {
    if(data == nil) return nil;
    NSError *error = nil;
    id returnValue = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if(error) {
        NSLog(@"JSON Parsing Error: %@", error);
        //https://github.com/coderyi/NetworkEye/issues/3
        return nil;
    }
    //https://github.com/coderyi/NetworkEye/issues/1
    if (!returnValue || returnValue == [NSNull null]) {
        return nil;
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:returnValue options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

+ (NSString *)stringWithDate:(NSDate *)date {
    NSString *destDateString = [[self defaultDateFormatter] stringFromDate:date];
    return destDateString;
}

+ (NSDate *)dateFromString:(NSString *)dateStr {
    return [[self defaultDateFormatter] dateFromString:dateStr];
}

+ (NSTimeInterval)timeIntervalFrom:(NSDate *)from toDate:(NSDate *)to {
    NSTimeInterval fromTime = [from timeIntervalSinceReferenceDate];
    NSTimeInterval toTime = [to timeIntervalSinceReferenceDate];
    return (toTime - fromTime);
}

+ (NSString *)nextRequestID {
    return [[NSUUID UUID] UUIDString];
}

+ (NSDateFormatter *)defaultDateFormatter {
    static NSDateFormatter *staticDateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticDateFormatter=[[NSDateFormatter alloc] init];
        [staticDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    });
    return staticDateFormatter;
}

@end
