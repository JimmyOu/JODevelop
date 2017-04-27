//
//  JSBridge.m
//  JOFoundation
//
//  Created by JimmyOu on 16/10/20.
//  Copyright © 2016年 JimmyOu. All rights reserved.
//

#import "JSBridge.h"
#import "NSDictionary+Extension.h"
#import "JSPluginManager.h"
#import "NSString+Extention.h"
@interface JSBridge ()

@end

static NSString *const kBridgeNamespace = @"appJS";

@implementation JSBridge

+ (instancetype)bridgeWithUIWebView:(UIWebView *)webView {
    JSBridge *bridge = [[JSBridge alloc] init];
    bridge.webView = webView;
    return bridge;
}

+ (instancetype)bridgeWithWKWebViewConfiguration:(WKWebViewConfiguration *)configuration {
    JSBridge *bridge = [[JSBridge alloc] init];
    WKUserContentController *controller = [[WKUserContentController alloc] init];
    [controller addScriptMessageHandler:bridge name:kBridgeNamespace];
    configuration.userContentController = controller;
    return bridge;
}



//调用js方法
- (void)callJS:(NSString *)jsMethod params:(NSDictionary *)params completion:(void (^)(id result, NSError * error))completion {
    NSString *jsCmd = [NSString stringWithFormat:@"%@(%@)", jsMethod, [params toJson]];
    if ([_webView isKindOfClass:[UIWebView class]]) {
        JSContext *context = [self context];
        JSValue *result = [context evaluateScript:jsCmd];
        if (completion) {
            completion(result,nil);
        }
    } else if ([_webView isKindOfClass:[WKWebView class]]) {
        WKWebView *wkWebView = _webView;
        [wkWebView evaluateJavaScript:jsCmd completionHandler:completion];
    }
}
//js传递来的数据，开始解析啦
- (void)dispatchJSCall:(NSDictionary *)jsCall {
    //调用原生方法
    [[JSPluginManager sharedInstance] dispatchJSCall:jsCall completion:^(NSString *jsMethod, JSResult *result) {
        if (![NSString isEmpty:jsMethod]) {//调用原生结束，我们通过jsMethod调回给H5
            dispatch_async(dispatch_get_main_queue(), ^{
                [self callJS:jsMethod params:[result toDict] completion:nil];
            });
        }
    }];
}

#pragma mark - UIWebView
//js传递来的数据
- (void)postMessage:(NSDictionary *)jsMessage
{
    NSLog(@"didReciveJSMessageFromUIWebView, jsMessage = %@",jsMessage);
    [self dispatchJSCall:jsMessage];
}
- (JSContext *)context {
    return [_webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
}
- (void)insertBridgeScript {
    if ([_webView isKindOfClass:[UIWebView class]]) {
        JSContext *context = [self context];
        context[kBridgeNamespace] = self;
    }
}
#pragma mark - WKWebView
#pragma mark - WKScriptMessageHandler
//js传递来的数据
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:kBridgeNamespace]) {
        if ([message.body isKindOfClass:[NSDictionary class]]) {
            NSDictionary *jsMessage = message.body;
            [self dispatchJSCall:jsMessage];
        }
    }
}
@end
