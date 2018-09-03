//
//  NEHTTPModel.m
//  SnailReader
//
//  Created by JimmyOu on 2018/8/17.
//  Copyright © 2018年 com.netease. All rights reserved.
//

#import "NEHTTPModel.h"
#import "NEMonitorUtils.h"
#import "NEHTTPModelManager.h"

@implementation NEHTTPModel


-(void)setNe_request:(NSURLRequest *)ne_request_new{
    _ne_request=ne_request_new;
    self.requestURLString=[_ne_request.URL absoluteString];
    
    switch (_ne_request.cachePolicy) {
        case 0:
            self.requestCachePolicy=@"NSURLRequestUseProtocolCachePolicy";
            break;
        case 1:
            self.requestCachePolicy=@"NSURLRequestReloadIgnoringLocalCacheData";
            break;
        case 2:
            self.requestCachePolicy=@"NSURLRequestReturnCacheDataElseLoad";
            break;
        case 3:
            self.requestCachePolicy=@"NSURLRequestReturnCacheDataDontLoad";
            break;
        case 4:
            self.requestCachePolicy=@"NSURLRequestUseProtocolCachePolicy";
            break;
        case 5:
            self.requestCachePolicy=@"NSURLRequestReloadRevalidatingCacheData";
            break;
        default:
            self.requestCachePolicy=@"";
            break;
    }
    
    self.requestTimeoutInterval=[[NSString stringWithFormat:@"%.1lf",_ne_request.timeoutInterval] doubleValue];
    self.requestHTTPMethod=_ne_request.HTTPMethod;
    
    for (NSString *key in [_ne_request.allHTTPHeaderFields allKeys]) {
        self.requestAllHTTPHeaderFields=[NSString stringWithFormat:@"%@%@",self.requestAllHTTPHeaderFields,[self formateRequestHeaderFieldKey:key object:[_ne_request.allHTTPHeaderFields objectForKey:key]]];
    }
    
    [self appendCookieStringAfterRequestAllHTTPHeaderFields];
    
    if (self.requestAllHTTPHeaderFields.length>1) {
        if ([[self.requestAllHTTPHeaderFields substringFromIndex:self.requestAllHTTPHeaderFields.length-1] isEqualToString:@"\n"]) {
            self.requestAllHTTPHeaderFields=[self.requestAllHTTPHeaderFields substringToIndex:self.requestAllHTTPHeaderFields.length-1];
        }
    }
    if (self.requestAllHTTPHeaderFields.length>6) {
        if ([[self.requestAllHTTPHeaderFields substringToIndex:6] isEqualToString:@"(null)"]) {
            self.requestAllHTTPHeaderFields=[self.requestAllHTTPHeaderFields substringFromIndex:6];
        }
    }
    
    if ([_ne_request HTTPBody].length>512) {
        self.requestHTTPBody=@"requestHTTPBody too long";
    }else{
        self.requestHTTPBody=[[NSString alloc] initWithData:[_ne_request HTTPBody] encoding:NSUTF8StringEncoding];
    }
    if (self.requestHTTPBody.length>1) {
        if ([[self.requestHTTPBody substringFromIndex:self.requestHTTPBody.length-1] isEqualToString:@"\n"]) {
            self.requestHTTPBody=[self.requestHTTPBody substringToIndex:self.requestHTTPBody.length-1];
        }
    }
    
}
- (void)appendCookieStringAfterRequestAllHTTPHeaderFields
{
    NSString *host = self.ne_request.URL.host;
    NSArray *cookieArray = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    NSMutableArray *cookieValueArray = [NSMutableArray array];
    for (NSHTTPCookie *cookie in cookieArray) {
        NSString *domain = [cookie.properties valueForKey:NSHTTPCookieDomain];
        NSRange range = [host rangeOfString:domain];
        NSComparisonResult result = [cookie.expiresDate compare:[NSDate date]];
        
        if(range.location != NSNotFound && result == NSOrderedDescending)
        {
            [cookieValueArray addObject:[NSString stringWithFormat:@"%@=%@",cookie.name,cookie.value]];
        }
    }
    if(cookieValueArray.count > 0)
    {
        NSString *cookieString = [cookieValueArray componentsJoinedByString:@";"];
        
        self.requestAllHTTPHeaderFields = [self.requestAllHTTPHeaderFields stringByAppendingString:[self formateRequestHeaderFieldKey:@"Cookie" object:cookieString]];
    }
}
- (void)setNe_response:(NSHTTPURLResponse *)ne_response_new {
    
    _ne_response=ne_response_new;
    
    self.responseMIMEType=@"";
    self.responseExpectedContentLength=@"";
    self.responseTextEncodingName=@"";
    self.responseSuggestedFilename=@"";
    self.responseStatusCode=200;
    self.responseAllHeaderFields=@"";
    
    self.responseMIMEType=[_ne_response MIMEType];
    self.responseExpectedContentLength=[NSString stringWithFormat:@"%lld",[_ne_response expectedContentLength]];
    self.responseTextEncodingName=[_ne_response textEncodingName];
    self.responseSuggestedFilename=[_ne_response suggestedFilename];
    self.responseStatusCode=(int)_ne_response.statusCode;
    
    for (NSString *key in [_ne_response.allHeaderFields allKeys]) {
        NSString *headerFieldValue=[_ne_response.allHeaderFields objectForKey:key];
        if ([key isEqualToString:@"Content-Security-Policy"]) {
            if ([[headerFieldValue substringFromIndex:12] isEqualToString:@"'none'"]) {
                headerFieldValue=[headerFieldValue substringToIndex:11];
            }
        }
        self.responseAllHeaderFields=[NSString stringWithFormat:@"%@%@:%@\n",self.responseAllHeaderFields,key,headerFieldValue];
        
    }
    
    if (self.responseAllHeaderFields.length>1) {
        if ([[self.responseAllHeaderFields substringFromIndex:self.responseAllHeaderFields.length-1] isEqualToString:@"\n"]) {
            self.responseAllHeaderFields=[self.responseAllHeaderFields substringToIndex:self.responseAllHeaderFields.length-1];
        }
    }
    
}

- (void)synchronize {
    self.requestFlow = [NEMonitorUtils getRequestLength:self.ne_request];
    self.responseFlow = [NEMonitorUtils getResponseLength:self.ne_response withData:self.data];
    self.totalFlow = self.requestFlow + self.responseFlow;
    //    double flowCount=[[[NSUserDefaults standardUserDefaults] objectForKey:@"flowCount"] doubleValue];
    //    if (!flowCount) {
    //        flowCount=0.0;
    //    }
    //    flowCount=flowCount+self.response.expectedContentLength/(1024.0*1024.0);
    //    [[NSUserDefaults standardUserDefaults] setDouble:flowCount forKey:@"flowCount"];
    //    [[NSUserDefaults standardUserDefaults] synchronize];//https://github.com/coderyi/NetworkEye/pull/6
        [[NEHTTPModelManager sharedInstance] addModel:self];
    
}

#pragma ults
- (NSString *)formateRequestHeaderFieldKey:(NSString *)key object:(id)obj
{
    return [NSString stringWithFormat:@"%@:%@\n",key?:@"",obj?:@""];
}

@end
