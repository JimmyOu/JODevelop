//
//  JOVideoPlayerCachePath.m
//  JODevelop
//
//  Created by JimmyOu on 2018/5/15.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "JOVideoPlayerCachePath.h"
#import "JOVideoPlayerCache.h"
#import "JOVideoPlayerCompat.h"

static NSString * const kJOVideoPlayerCacheVideoPathDomain = @"/com.jovideoplayer.www";
static NSString * const kJOVideoPlayerCacheVideoFileExtension = @".mp4"; //缓存了视频
static NSString * const kJOVideoPlayerCacheVideoIndexFileExtension = @".index"; //如果有这个，代表视频为一些片段

@implementation JOVideoPlayerCachePath

+ (NSString *)videoCachePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject
                      stringByAppendingPathComponent:kJOVideoPlayerCacheVideoPathDomain];
    if (![fileManager fileExistsAtPath:path]) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

+ (NSString *)videoCachePathForKey:(NSString *)key {
    
    NSString *videoCachePath = [self videoCachePath];
    NSParameterAssert(key);
    NSParameterAssert(videoCachePath);
    
    if (!key || !videoCachePath) {
        return nil;
    }
    NSString *filePath = [videoCachePath stringByAppendingPathComponent:[[JOVideoPlayerCache sharedInstance] cacheFileNameForKey:key]];
    filePath = [filePath stringByAppendingString:kJOVideoPlayerCacheVideoFileExtension];
    return filePath;
}

+ (NSString *)createVideoFileIfNeededForKey:(NSString *)key {
    NSString *filePath = [self videoCachePathForKey:key];
    if (!filePath) {
        return nil;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath]) {
        [fileManager createFileAtPath:filePath contents:nil attributes:nil];
    }
    return filePath;
}

+ (NSString *)videoCacheIndexFilePathForKey:(NSString *)key {
    NSString *videoCachePath = [self videoCachePath];
    NSParameterAssert(key);
    NSParameterAssert(videoCachePath);
    if (!key) {
        return nil;
    }
    NSString *filePath = [videoCachePath stringByAppendingPathComponent:[[JOVideoPlayerCache sharedInstance] cacheFileNameForKey:key]];
    filePath = [filePath stringByAppendingString:kJOVideoPlayerCacheVideoIndexFileExtension];
    return filePath;
}

+ (NSString *)createVideoIndexFileIfNeededForKey:(NSString *)key {
    NSString *filePath = [self videoCacheIndexFilePathForKey:key];
    if(!filePath){
        return nil;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath]) {
        [fileManager createFileAtPath:filePath contents:nil attributes:nil];
    }
    return filePath;
}
@end
