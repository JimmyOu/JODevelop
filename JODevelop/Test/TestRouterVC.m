//
//  TestRouterVC.m
//  JODevelop
//
//  Created by JimmyOu on 17/4/13.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "TestRouterVC.h"
#import "AXDRouterImport.h"
#import <WebKit/WebKit.h>
#import "JSBridge.h"

@interface TestRouterVC ()<UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *uiWebView;

@property (nonatomic, strong) WKWebView *wkWebView;

@property (nonatomic, strong) JSBridge *jsBridge;

@end

@implementation TestRouterVC

#pragma mark – VC life cycle
- (void)viewDidLoad{
    [super viewDidLoad];
}
- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    /*******       1.testRouter      *******/
    //    [self routerTest];
    
    /*******       2.UIWebTest       *******/
    [self UIWebTest];
    
    /*******       3.WKWebTest       *******/
    //[self WKWebTest];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)routerTest {
    /**1.app内动态调用**/
    NSLog(@"/**1.app内动态调用**/");
    [[AXDRouter sharedInstance] doLogin:^(NSInteger result) {
        NSLog(@"%d",(int)result);
    }];
    
    [[AXDRouter sharedInstance] doBussiness];
    
    id returnValue = [[AXDRouter sharedInstance] doBussiness:^(NSInteger result) {
        NSLog(@"%d",(int)result);
    }];
    NSLog(@"%@",[returnValue class]);
    
    
    /**2.通过协议调用**/
    NSLog(@"/**2.通过协议调用**/");
    
    [AXDRouter dispatchInvokesWithUrl:@"axd://login/dologin"];
    
    [AXDRouter dispatchInvokesWithUrl:@"axd://login/dologin?pram1=hello"];
    
    id returnValue2 = [AXDRouter dispatchInvokesWithUrl:@"axd://login/dologin_protocol?pram1=hello"];
    NSLog(@"%@",[returnValue2 class]);
    
}

- (void)WKWebTest {
    
    //1.初始化
    [[AXDRouter sharedInstance] js_install];
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    _jsBridge = [JSBridge bridgeWithWKWebViewConfiguration:configuration];
    _wkWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 20, kScreenWidth, (kScreenHeight- 20) * 0.5) configuration:configuration];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"web" ofType:@"html"];
    [_wkWebView loadHTMLString:[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil] baseURL:nil];
    [self.view addSubview:_wkWebView];
    
}

- (void)UIWebTest {
    
    //1.初始化
    [[AXDRouter sharedInstance] js_install];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, (kScreenHeight- 20) * 0.5)];
    webView.delegate = self;
    _jsBridge = [JSBridge bridgeWithUIWebView:webView];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"web" ofType:@"html"];
    [webView loadHTMLString:[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil] baseURL:nil];
    [self.view addSubview:webView];
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [_jsBridge insertBridgeScript];
}

@end
