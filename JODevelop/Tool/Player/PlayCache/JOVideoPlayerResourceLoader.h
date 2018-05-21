//
//  JOVideoPlayerResourceLoader.h
//  JODevelop
//
//  Created by JimmyOu on 2018/5/15.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class JOVideoPlayerResourceLoader, JOResourceLoadingWebTask, JOVideoPlayerCacheFile;
@protocol JOVideoPlayerResourceLoaderDelegate<NSObject>
@required
- (void)resourceLoader:(JOVideoPlayerResourceLoader *)resourceLoader didReceiveLoadingWebTask:(JOResourceLoadingWebTask *)webTask;
@end
@interface JOVideoPlayerResourceLoader : NSObject<AVAssetResourceLoaderDelegate>

@property (weak, nonatomic) id<JOVideoPlayerResourceLoaderDelegate> delegate;
@property (readonly, nonnull) NSURL *customURL;
@property (readonly, nonnull) JOVideoPlayerCacheFile *cacheFile;

+ (instancetype)resourceLoaderWithCustomURL:(NSURL *)url;

@end
