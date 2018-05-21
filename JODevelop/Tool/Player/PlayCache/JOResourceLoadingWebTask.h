//
//  JOResourceLoadingWebTask.h
//  JODevelop
//
//  Created by JimmyOu on 2018/5/15.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JOVideoLoadingRequestTask.h"

@interface JOResourceLoadingWebTask : JOVideoLoadingRequestTask
/*
 downloading task
 */
@property (readonly) NSURLSessionDataTask *dataTask;
/*
 request for downloading task
 */
@property (strong, nonatomic) NSURLRequest *request;
/*
 download options
 */
@property (assign, nonatomic) JOVideoDownloaderOptions options;

/**
 urlsession is injected by others
 */
@property (weak, nonatomic) NSURLSession *unownedSession;


@end
