//
//  NEMonitorNetworkDetailViewController.m
//  SnailReader
//
//  Created by JimmyOu on 2018/8/23.
//  Copyright © 2018年 com.netease. All rights reserved.
//

#import "NEMonitorNetworkDetailViewController.h"
#import "NEHTTPModel.h"
@interface NEMonitorNetworkDetailViewController()

@end
@implementation NEMonitorNetworkDetailViewController {
    UIActivityIndicatorView *_loadingView;
    UIWebView *_webView;
    UIImageView *_imageView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _webView = [[UIWebView alloc] init];
    _webView.hidden = YES;
    [self.view addSubview:_webView];
    
    _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_loadingView startAnimating];
    [self.view addSubview:_loadingView];
    
    [self reloadData];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self resizeViews];
}
- (void)reloadData
{
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        NSData *data = [NSData dataWithContentsOfFile:self->_filePath];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self didLoadFileData:data];
//        });
//    });
}

- (void)didLoadFileData:(NSData *)data
{
//    [_loadingView stopAnimating];
//    [_loadingView removeFromSuperview];
//    
//    NSString *ext = [[[_filePath lastPathComponent] pathExtension] lowercaseString];
//    if ([ext isEqualToString:@"jpg"]
//        || [ext isEqualToString:@"jpeg"]
//        || [ext isEqualToString:@"png"]) {
//        UIImage *image = [UIImage imageWithData:data];
//        _imageView = [[UIImageView alloc] initWithImage:image];
//        [self.view addSubview:_imageView];
//    } else {
//        _webView.hidden = NO;
//        NSURL *baseURL = nil;
//        [_webView loadData:data MIMEType:[self detectMimeType:ext] textEncodingName:@"UTF-8" baseURL:baseURL];
//    }
}
- (void)resizeViews
{
    _imageView.frame = self.view.bounds;
    _webView.frame = self.view.bounds;
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self resizeViews];
}
- (NSString *)detectMimeType:(NSString *)type
{
    NSString *m_MIMEType = nil;
    if ( [type isEqualToString:@"docx"] ) {
        m_MIMEType = @"application/vnd.openxmlformats-officedocument.wordprocessingml.document";
    }
    else if( [type isEqualToString:@"xlsm"] )
    {
        m_MIMEType = @"application/vnd.ms-excel.sheet.macroEnabled.12";
    }
    else if( [type isEqualToString:@"mm"] || [type isEqualToString:@"m"] || [type isEqualToString:@"h"])
    {
        m_MIMEType = @"text/plain";
    }
    else if( [type isEqualToString:@"kdh"] )
    {
        m_MIMEType = @"application/octet-stream";
    }
    else if( [type isEqualToString:@"ini"] || [type isEqualToString:@"stp"] )
    {
        m_MIMEType = @"text/plain";
    }
    else if( [type isEqualToString:@"csv"] )
    {
        m_MIMEType = @"text/csv";
    }
    else if( [type isEqualToString:@"O"] )
    {
        m_MIMEType = @"text/ics";
    }
    else if( [type isEqualToString:@"vsd"] )
    {
        m_MIMEType = @"application/x-visio";
    }
    else if( [type isEqualToString:@"java"] || [type isEqualToString:@"plist"] )
    {
        m_MIMEType = @"text/plain";
    }
    else if ([type isEqualToString:@"txt"] ) {
        m_MIMEType = @"text/plain";
        
    }
    else if ([type isEqualToString:@"rtf"] ) {
        m_MIMEType = @"text/rtf";
        
    }
    else if ( [type isEqualToString:@"html"] || [type isEqualToString:@"htm"] ) {
        m_MIMEType = @"text/html";
        
    }
    else if ( [type isEqualToString:@"cpp"] || [type isEqualToString:@"c"] || [type isEqualToString:@"js"] ) {
        m_MIMEType = @"text/plain";
        
    }
    else if ( [type isEqualToString:@"pdf"] ) {
        m_MIMEType = @"application/pdf";
        
    }
    else if ( [type isEqualToString:@"docm"] ) {
        m_MIMEType = @"application/vnd.ms-word.document.macroEnabled.12";
        
    }
    else if ( [type isEqualToString:@"doc"] ) {
        m_MIMEType = @"application/msword";
        
    }
    else if ( [type isEqualToString:@"dot"] ) {
        m_MIMEType = @"application/msword";
        
    }
    else if ( [type isEqualToString:@"xls"] ) {
        m_MIMEType = @"application/vnd.ms-excel";
        
    }
    else if ( [type isEqualToString:@"xlsx"] ) {
        m_MIMEType = @"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
    }
    else if ( [type isEqualToString:@"ppt"] ) {
        m_MIMEType = @"application/vnd.ms-powerpoint";
        
    }
    else if ( [type isEqualToString:@"pps"] ) {
        m_MIMEType = @"application/vnd.ms-powerpoint";
        
    }
    else if ( [type isEqualToString:@"pptx"] ) {
        m_MIMEType = @"application/vnd.openxmlformats-officedocument.presentationml.presentation";
        
    }
    else if ([type isEqualToString:@"xml"] ) {
        m_MIMEType = @"text/plain";
        
    }
    else if ([type isEqualToString:@"log"] ) {
        m_MIMEType = @"text/plain";
    }
    else{
        m_MIMEType = @"text/plain"; // default
    }
    return m_MIMEType;
}




@end
