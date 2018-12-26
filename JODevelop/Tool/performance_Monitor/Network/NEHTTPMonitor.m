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

#import "NECustomHttpProtocol.h"

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
    
    return @[[NECustomHttpProtocol class]]; //NSURLProtocol registerClass: 只影响 NSURLSessionConfiguration 的default session， 不影响自定义的NSURLSessionConfiguration
    //如果需要导入其他的自定义NSURLProtocol请在这里增加，当然在使用NSURLSessionConfiguration时增加也可以
}
@end


@interface NEHTTPMonitor()<NECustomHttpProtocolDelegate>
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) NSURLResponse        *response;
@property (nonatomic, strong) NSMutableData        *data;
@property (nonatomic, strong) NSDate               *startDate;
@property (strong, nonatomic) NEHTTPModel *model;

@end
@implementation NEHTTPMonitor

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static NEHTTPMonitor *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[NEHTTPMonitor alloc] init];
    });
    return instance;
}



- (void)networkMonitor:(BOOL)enable {
    NESessionConfigurationManager *sessionManager=[NESessionConfigurationManager defaultManager];

    if (enable) {
        [NECustomHttpProtocol start];
        if (![sessionManager isSwizzle]) {
            [sessionManager swizzle];
        }

    } else {
        [NECustomHttpProtocol finished];
        if ([sessionManager isSwizzle]) {
            [sessionManager unswizzle];
        }
    }
    [NECustomHttpProtocol setDelegate:self];
}

#pragma mark - NECustomHttpProtocolDelegate

- (BOOL)customHTTPProtocol:(NECustomHttpProtocol *)protocol canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
//    assert(protocol != nil);
//#pragma unused(protocol)
//    assert(protectionSpace != nil);
    
    // We accept any server trust authentication challenges.
    
    return [[protectionSpace authenticationMethod] isEqual:NSURLAuthenticationMethodServerTrust];
}

- (void)customHTTPProtocol:(NECustomHttpProtocol *)protocol didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    OSStatus            err;
    NSURLCredential *   credential;
    SecTrustRef         trust;
    SecTrustResultType  trustResult;
    
    trust = [[challenge protectionSpace] serverTrust];
    if (trust == NULL) {
//        assert(NO);
    } else {
        NSMutableArray *pinnedCertificates = [NSMutableArray array];
        NSSet *certificates = [[self class] defaultPinnedCertificates];
        for (NSData *certificateData in certificates) {
            [pinnedCertificates addObject:(__bridge_transfer id)SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certificateData)];
        }
        err = SecTrustSetAnchorCertificates(trust, (__bridge CFArrayRef) pinnedCertificates);
        if (err != noErr) {
//            assert(NO);
        } else {
            err = SecTrustSetAnchorCertificatesOnly(trust, false);
            if (err != noErr) {
//                assert(NO);
            } else {
                err = SecTrustEvaluate(trust, &trustResult);
                if (err != noErr) {
//                    assert(NO);
                } else {
                    if ( (trustResult == kSecTrustResultProceed) || (trustResult == kSecTrustResultUnspecified) ) {
                        credential = [NSURLCredential credentialForTrust:trust];
                        assert(credential != nil);
                    }
                }
            }
        }
    }
    
    [protocol resolveAuthenticationChallenge:challenge withCredential:credential];
}

+ (NSSet *)defaultPinnedCertificates {
    static NSSet *_defaultPinnedCertificates = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        _defaultPinnedCertificates = [self certificatesInBundle:bundle];
    });
    
    return _defaultPinnedCertificates;
}

+ (NSSet *)certificatesInBundle:(NSBundle *)bundle {
    NSArray *paths = [bundle pathsForResourcesOfType:@"cer" inDirectory:@"."];
    
    NSMutableSet *certificates = [NSMutableSet setWithCapacity:[paths count]];
    for (NSString *path in paths) {
        NSData *certificateData = [NSData dataWithContentsOfFile:path];
        [certificates addObject:certificateData];
    }
    
    return [NSSet setWithSet:certificates];
}

@end
