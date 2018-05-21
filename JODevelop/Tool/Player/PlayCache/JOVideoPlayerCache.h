//
//  JOVideoPlayerCache.h
//  JODevelop
//
//  Created by JimmyOu on 2018/5/15.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JOVideoPlayerCacheConfiguration:NSObject

/**
 缓存最多存在的时间，秒为单位。 default 1 week
 */
@property (assign, nonatomic) NSInteger maxCacheAge;

/**
 缓存的maxSize，in bytes， default 1 G
 如果缓存超出，会按照cache的时间删掉video
 */
@property (assign, nonatomic) NSInteger maxCacheSize;

/**
 default yes
 */
@property (assign, nonatomic) BOOL shouldDisableiCloud;
@end

typedef NS_ENUM(NSInteger, JOVideoPlayerCacheType)   {
    
    /**
     * The video wasn't available the caches, but was downloaded from the web.
     */
    JOVideoPlayerCacheTypeNone,
    
    /**
     * The video was obtained on the disk cache, and the video is cache finished.
     */
    JOVideoPlayerCacheTypeFull,
    
    /**
     * The video was obtained on the disk cache, but the video does not cache finish.
     */
    JOVideoPlayerCacheTypeFragment,
    
    /**
     * A location video.
     */
    JOVideoPlayerCacheTypeLocation
};

typedef void(^JOVideoPlayerCacheQueryCompletion)(NSString * _Nullable videoPath, JOVideoPlayerCacheType cacheType);

typedef void(^JOVideoPlayerCheckCacheCompletion)(BOOL isInDiskCache);

typedef void(^JOVideoPlayerCaculateSizeCompletion)(NSUInteger fileCount, NSUInteger totalSize);

@interface JOVideoPlayerCache : NSObject

@property (readonly) JOVideoPlayerCacheConfiguration *cacheConfiguration;

- (instancetype)initWithCacheConfiguration:(JOVideoPlayerCacheConfiguration * _Nullable)cacheConfigration NS_DESIGNATED_INITIALIZER;

+ (instancetype)sharedInstance;

#pragma mark - query

/**
 异步查询
 
 @param key describe video url
 @param completion completion will always invoker at mainQueue
 */
- (void)diskVideoExistsWithKey:(NSString *)key completion:(JOVideoPlayerCheckCacheCompletion _Nullable)completion;
/**
 异步查询
 
 @param key describe video url
 @param completion completion will always invoker at mainQueue
 */
- (void)queryCacheOperationForKey:(NSString *)key completion:(JOVideoPlayerCacheQueryCompletion _Nullable)completion;

- (BOOL)diskVideoExistsOnPath:(NSString *)path;

#pragma mark - clear cache

/**
 async remove cache for key

 */
- (void)removeVideoCacheForKey:(NSString *)key completion:(dispatch_block_t _Nullable)completion;

/**
 async remove all expiredFiles
 */
- (void)removeAllExpiredFilesOnCompletion:(dispatch_block_t _Nullable)completion;

/**
 async remove all cache files
 */
- (void)clearDiskOnCompletion:(dispatch_block_t _Nullable)completion;

#pragma mark - cache info

- (BOOL)haveFreeSizeToCacheFileWithSize:(NSUInteger)fileSize;

- (unsigned long long)getDiskFreeSize;

//get size used by disk cache
- (unsigned long long)getSize;

/**
 get number of medias in cache
 */
- (NSUInteger)getDiskCount;

/**
 calculate cache size asynchronously
 */
- (void)calculateSizeOnCompletion:(JOVideoPlayerCaculateSizeCompletion _Nullable)completion;

#pragma mark - File Name

/**
    get file name for give key
 */
- (NSString *)cacheFileNameForKey:(NSString *)key;

@end
