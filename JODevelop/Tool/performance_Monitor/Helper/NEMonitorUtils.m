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
#import "BSBacktraceLogger.h"

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
      return [BSBacktraceLogger bs_backtraceOfAllThread];
    }
    @catch (NSException * e){
        return @"";
    }
}
+ (NSString *)genCurrentThreadCallStackReport {
    @try {
        return [BSBacktraceLogger bs_backtraceOfCurrentThread];
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
           [[NSNotificationCenter defaultCenter] postNotificationName:NEMonitorExceptionThrowNotifiation object:@{NEMonitorExceptionThrowNotifiationErrorKey:error, NEMonitorExceptionThrowNotifiationErrorCallStack:callbackSymbols}];
    });
}
+ (void)notifyWithError:(NSError *)error {
    NSString *callbackString = [[self genCurrentThreadCallStackReport] mutableCopy];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NEMonitorExceptionThrowNotifiation object:@{NEMonitorExceptionThrowNotifiationErrorKey:error, NEMonitorExceptionThrowNotifiationErrorCallStack:callbackString}];
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
    return responseLength;
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

@end
