//
//  NEHTTPMonitor.m
//  SnailReader
//
//  Created by JimmyOu on 2018/8/17.
//  Copyright © 2018年 com.netease. All rights reserved.
//

#import "NEHTTPMonitor.h"
#import "NEHTTPModel.h"
#import <objc/runtime.h>
#import "NEMonitorUtils.h"


@interface NESessionConfigurationManager:NSObject
+ (instancetype)defaultManager;
@property (assign, nonatomic) BOOL isSwizzle;
- (void)swizzle;
- (void)unswizzle;

@end
@implementation NESessionConfigurationManager
+ (instancetype)defaultManager {
    static dispatch_once_t onceToken;
    static NESessionConfigurationManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[NESessionConfigurationManager alloc] init];
    });
    return instance;
}
- (void)swizzle {
    self.isSwizzle=YES;
    Class cls = NSClassFromString(@"__NSCFURLSessionConfiguration") ?: NSClassFromString(@"NSURLSessionConfiguration");
    [self swizzleSelector:@selector(protocolClasses) fromClass:cls toClass:[self class]];
    
}
- (void)unswizzle {
    self.isSwizzle=NO;
    Class cls = NSClassFromString(@"__NSCFURLSessionConfiguration") ?: NSClassFromString(@"NSURLSessionConfiguration");
    [self swizzleSelector:@selector(protocolClasses) fromClass:cls toClass:[self class]];
}

- (void)swizzleSelector:(SEL)selector fromClass:(Class)original toClass:(Class)stub {
    
    Method originalMethod = class_getInstanceMethod(original, selector);
    Method stubMethod = class_getInstanceMethod(stub, selector);
    if (!originalMethod || !stubMethod) {
        [NSException raise:NSInternalInconsistencyException format:@"Couldn't load NEURLSessionConfiguration."];
    }
    method_exchangeImplementations(originalMethod, stubMethod);
}
- (NSArray *)protocolClasses {
    
    return @[[NEHTTPMonitor class]]; //NSURLProtocol registerClass: 只影响 NSURLSessionConfiguration 的default session， 不影响自定义的NSURLSessionConfiguration
    //如果需要导入其他的自定义NSURLProtocol请在这里增加，当然在使用NSURLSessionConfiguration时增加也可以
}
@end

static NSString * kOurRecursiveRequestFlagProperty = @"com.CustomHTTPProtocol";

@interface NEHTTPMonitor()<NSURLSessionTaskDelegate, NSURLSessionDataDelegate>
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) NSOperationQueue     *sessionDelegateQueue;
@property (nonatomic, strong) NSURLResponse        *response;
@property (nonatomic, strong) NSMutableData        *data;
@property (nonatomic, strong) NSDate               *startDate;
@property (strong, nonatomic) NEHTTPModel *model;

@end
@implementation NEHTTPMonitor

+ (void)networkMonitor:(BOOL)enable {
    [[NSUserDefaults standardUserDefaults ] setDouble:enable forKey:@"NEHTTPMonitorEnable"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NESessionConfigurationManager *sessionManager=[NESessionConfigurationManager defaultManager];
    if (enable) {
        [NSURLProtocol registerClass:[NEHTTPMonitor class]];
        if (![sessionManager isSwizzle]) {
            [sessionManager swizzle];
        }
    } else {
        [NSURLProtocol unregisterClass:[NEHTTPMonitor class]];
        if ([sessionManager isSwizzle]) {
            [sessionManager unswizzle];
        }
    }
}
+ (BOOL)networkMonitorEnable {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"NEHTTPMonitorEnable"] boolValue];
}

#pragma mark key method
+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if (![request.URL.scheme isEqualToString:@"http"] &&
        ![request.URL.scheme isEqualToString:@"https"]) {
        return NO;
    }
    
    if ([NSURLProtocol propertyForKey:kOurRecursiveRequestFlagProperty inRequest:request] ) {
        return NO;
    }
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    //处理过的就打个标记避免死循环
    NSMutableURLRequest *mutableReqeust = [request mutableCopy];
    [NSURLProtocol setProperty:@YES
                        forKey:kOurRecursiveRequestFlagProperty
                     inRequest:mutableReqeust];
    return [mutableReqeust copy];
}

- (void)startLoading {
    self.startDate                                        = [NSDate date];
    self.data                                             = [NSMutableData data];
    NSURLSessionConfiguration *configuration              = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.sessionDelegateQueue                             = [[NSOperationQueue alloc] init];
    self.sessionDelegateQueue.maxConcurrentOperationCount = 1;
    self.sessionDelegateQueue.name                        = @"com.hehttpMonitor.session.queue";
    NSURLSession *session                                 = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:self.sessionDelegateQueue];
    self.dataTask                                         = [session dataTaskWithRequest:self.request];
    [self.dataTask resume];
    
    self.model = [[NEHTTPModel alloc] init];
    self.model.ne_request = self.request;
    self.model.startDateString = [self stringWithDate:[NSDate date]];
    self.model.myID = [NSString stringWithFormat:@"%@",[[self class] nextRequestID]];
    
}

- (void)stopLoading {
    [self.dataTask cancel];
    self.dataTask           = nil;
    self.model.ne_response      = (NSHTTPURLResponse *)self.response;
    self.model.statusCodeString = [NEMonitorUtils statusCodeStringFromURLResponse:(NSHTTPURLResponse *)self.response];
    self.model.endDateString = [self stringWithDate:[NSDate date]];
    NSDate *from = [self dateFromString:self.model.startDateString];
    NSTimeInterval duraiton = [self timeIntervalFrom:from toDate:[NSDate date]];
    self.model.formateDuation = [NEMonitorUtils formateStringFromRequestDuration:duraiton];
    self.model.data = self.data;
    NSString *mimeType      = self.response.MIMEType;
    if ([mimeType isEqualToString:@"application/json"]) {
        self.model.receiveJSONData = [self responseJSONFromData:self.data];
    } else if ([mimeType isEqualToString:@"text/javascript"]) {
        // try to parse json if it is jsonp request
        NSString *jsonString = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
        // formalize string
        if ([jsonString hasSuffix:@")"]) {
            jsonString = [NSString stringWithFormat:@"%@;", jsonString];
        }
        if ([jsonString hasSuffix:@");"]) {
            NSRange range = [jsonString rangeOfString:@"("];
            if (range.location != NSNotFound) {
                range.location++;
                range.length = [jsonString length] - range.location - 2; // removes parens and trailing semicolon
                jsonString = [jsonString substringWithRange:range];
                NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                self.model.receiveJSONData = [self responseJSONFromData:jsonData];
            }
        }
        
    }else if ([mimeType isEqualToString:@"application/xml"] ||[mimeType isEqualToString:@"text/xml"]){
        NSString *xmlString = [[NSString alloc]initWithData:self.data encoding:NSUTF8StringEncoding];
        if (xmlString && xmlString.length>0) {
            self.model.receiveJSONData = xmlString;//example http://webservice.webxml.com.cn/webservices/qqOnlineWebService.asmx/qqCheckOnline?qqCode=2121
        }
    }
    [self.model synchronize];
}


#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    self.model.error = error;
    if (!error) {
        [self.client URLProtocolDidFinishLoading:self];
    } else if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled) {
    } else {
        [self.client URLProtocol:self didFailWithError:error];
    }
    self.dataTask = nil;
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
    [self.data appendData:data];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    completionHandler(NSURLSessionResponseAllow);
    self.response = response;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    if (response != nil){
        self.response = response;
        [[self client] URLProtocol:self wasRedirectedToRequest:request redirectResponse:response];
    }
}

#pragma mark - Utils

-(id)responseJSONFromData:(NSData *)data {
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

- (NSString *)stringWithDate:(NSDate *)date {
    NSString *destDateString = [[NEHTTPMonitor defaultDateFormatter] stringFromDate:date];
    return destDateString;
}
- (NSDate *)dateFromString:(NSString *)dateStr {
   return [[NEHTTPMonitor defaultDateFormatter] dateFromString:dateStr];
}
- (NSTimeInterval)timeIntervalFrom:(NSDate *)from toDate:(NSDate *)to {
    NSTimeInterval fromTime = [from timeIntervalSinceReferenceDate];
    NSTimeInterval toTime = [to timeIntervalSinceReferenceDate];
    return (toTime - fromTime);
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

+ (NSString *)nextRequestID
{
    return [[NSUUID UUID] UUIDString];
}



@end
