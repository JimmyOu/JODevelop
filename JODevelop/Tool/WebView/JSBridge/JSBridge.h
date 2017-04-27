//
//  JSBridge.h
//  JOFoundation
//
//  Created by JimmyOu on 16/10/20.
//  Copyright © 2016年 JimmyOu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
@protocol XPSuperJSBridgeDelegate <JSExport>

JSExportAs(postMessage,
           - (void)postMessage:(NSDictionary *)jsParams
           );

@end

@interface JSBridge : NSObject <WKScriptMessageHandler,XPSuperJSBridgeDelegate>

/**
 * 持有一个 webView 的弱引用,可能是UIWebView, 也可能是WkWebView
 */
@property (nonatomic, weak) id webView;
/**
 * 用 UIWebView 创建 JSBridge 对象
 * @param webView UIWebView
 * @return JSBridge 对象
 */
+ (instancetype)bridgeWithUIWebView:(UIWebView *)webView;

/**
 * 用 WKWebViewConfiguration 创建 JSBridge 对象, 因为 WkWebView 创建前在 WKWebViewConfiguration 中注入才有效,
 * 所以直接利用 WKWebViewConfiguration 来创建, 创建 JSBridge 之后,再用 WKWebViewConfiguration 创建 WkWebView,
 * 请记得给 JSBridge 对象的 webView 属性赋值
 * @param configuration WKWebViewConfiguration
 * @return JSBridge 对象
 */
+ (instancetype)bridgeWithWKWebViewConfiguration:(WKWebViewConfiguration *)configuration;

/**
 * 当 webView 为 UIWebView 时在 webViewDidFinishLoad 事件中注入 Bridge 脚本
 */
- (void)insertBridgeScript;
@end
