//
//  JOVideoPlayerCache.m
//  JODevelop
//
//  Created by JimmyOu on 2018/5/15.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "JOVideoPlayerCache.h"
#import "JOVideoPlayerCompat.h"
#import "JOVideoPlayerCachePath.h"
#import <CommonCrypto/CommonDigest.h>
#include <sys/mount.h>


static const NSInteger kDefaultCacheMaxAge = 60*60*24*7; // 1 week
static const NSInteger kDefaultCacheMaxSize = 1024*1024*1024; // 1 GB

@implementation JOVideoPlayerCacheConfiguration
- (instancetype)init
{
    self = [super init];
    if (self) {
        _maxCacheAge = kDefaultCacheMaxAge;
        _maxCacheSize = kDefaultCacheMaxSize;
    }
    return self;
}
@end

@interface JOVideoPlayerCache()

@property (strong, nonatomic) dispatch_queue_t ioQueue;

@property (strong, nonatomic) NSFileManager *fileManager;

@end

@implementation JOVideoPlayerCache

- (instancetype)initWithCacheConfiguration:(JOVideoPlayerCacheConfiguration *)cacheConfigration {
    if (self = [super init]) {
        _ioQueue = dispatch_queue_create("come.JO.JOPlayerCache", DISPATCH_QUEUE_SERIAL);
        _cacheConfiguration = (cacheConfigration== nil) ? [[JOVideoPlayerCacheConfiguration alloc] init] : cacheConfigration;
        _fileManager = [NSFileManager defaultManager];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteExpiredFiles) name:UIApplicationWillTerminateNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backgroudDeleteOldFiles) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}
- (instancetype)init
{
    NSAssert(NO, @"use initWithCacheConfiguration or sharedInstance");
    return [self initWithCacheConfiguration:nil];
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static JOVideoPlayerCache *instance ;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] initWithCacheConfiguration:nil];
    });
    
    return instance;
}

#pragma mark - Query
- (void)diskVideoExistsWithKey:(NSString *)key completion:(JOVideoPlayerCheckCacheCompletion)completion {
    dispatch_async(_ioQueue, ^{
        BOOL exists = [self.fileManager fileExistsAtPath:[JOVideoPlayerCachePath videoCachePathForKey:key]];
        if (completion) {
            JODispatchASyncOnMainThread(^{
                completion(exists);
            });
        }
    });
}

- (void)queryCacheOperationForKey:(NSString *)key completion:(JOVideoPlayerCacheQueryCompletion)completion {
    if (!key) {
        if (completion) {
            JODispatchSyncOnMainThread(^{
                completion(nil, JOVideoPlayerCacheTypeNone);
            });
        }
        return;
    }
    
    dispatch_async(_ioQueue, ^{
        BOOL exists = [self.fileManager fileExistsAtPath:[JOVideoPlayerCachePath videoCachePathForKey:key]];
        if (!exists) {
            if (completion) {
                JODispatchSyncOnMainThread(^{
                    completion(nil, JOVideoPlayerCacheTypeNone);
                });
            }
            return;
        }
        
        BOOL isCacheFull = ![self.fileManager fileExistsAtPath:[JOVideoPlayerCachePath videoCacheIndexFilePathForKey:key]];
        if(isCacheFull){
            if (completion) {
                JODispatchSyncOnMainThread(^{
                    completion([JOVideoPlayerCachePath videoCachePathForKey:key], JOVideoPlayerCacheTypeFull);
                });
            }
            return;
        }
        
        if (completion) {
            JODispatchSyncOnMainThread(^{
                completion([JOVideoPlayerCachePath videoCachePathForKey:key], JOVideoPlayerCacheTypeFragment);
            });
        }
    });
}

- (BOOL)diskVideoExistsOnPath:(NSString *)path {
    return [self.fileManager fileExistsAtPath:path];
}

#pragma mark - clear cache
- (void)removeVideoCacheForKey:(NSString *)key completion:(dispatch_block_t)completion {
    dispatch_async(_ioQueue, ^{
        BOOL exists = [self.fileManager fileExistsAtPath:[JOVideoPlayerCachePath videoCachePathForKey:key]];
        if (exists) {
            [self.fileManager removeItemAtPath:[JOVideoPlayerCachePath videoCachePathForKey:key] error:nil];
            [self.fileManager removeItemAtPath:[JOVideoPlayerCachePath videoCacheIndexFilePathForKey:key] error:nil];
            JODispatchSyncOnMainThread(^{
                if (completion) {
                    completion();
                }
            });
        }
    });
}

- (void)removeAllExpiredFilesOnCompletion:(dispatch_block_t)completion {
    dispatch_async(self.ioQueue, ^{
        NSURL *diskCacheURL = [NSURL fileURLWithPath:[JOVideoPlayerCachePath videoCachePath] isDirectory:YES];
        NSArray<NSString *> *resourceKeys = @[NSURLIsDirectoryKey, NSURLContentModificationDateKey, NSURLTotalFileAllocatedSizeKey];
        // This enumerator prefetches useful properties for our cache files.
        NSDirectoryEnumerator *fileEnumerator = [self.fileManager enumeratorAtURL:diskCacheURL
                                                       includingPropertiesForKeys:resourceKeys
                                                                          options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                     errorHandler:NULL];
        
        NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-self.cacheConfiguration.maxCacheAge];
        NSMutableDictionary<NSURL *, NSDictionary<NSString *, id> *> *cacheFiles = [NSMutableDictionary dictionary];
        NSUInteger currentCacheSize = 0;
        
        // Enumerate all of the files in the cache directory.  This loop has two purposes:
        //
        //  1. Removing files that are older than the expiration date.
        //  2. Storing file attributes for the size-based cleanup pass.
        
        NSMutableArray<NSURL *> *urlsToDelete = [NSMutableArray new];
        @autoreleasepool {
            for (NSURL *fileURL in fileEnumerator) {
                NSError *error;
                NSDictionary<NSString *, id> *resourceValues = [fileURL resourceValuesForKeys:resourceKeys error:&error];
                
                //Skip directories and errors
                if (error || !resourceValues || [resourceValues[NSURLIsDirectoryKey] boolValue]) {
                    continue;
                }
                
                //Remove files olders than expiration date
                NSDate *modificationDate = resourceValues[NSURLContentModificationDateKey];
                if ([[modificationDate laterDate:expirationDate] isEqualToDate:expirationDate]) {
                    [urlsToDelete addObject:fileURL];
                    continue;
                }
                
                //Store a reference to this file and account for its total size.
                NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
                currentCacheSize += totalAllocatedSize.unsignedIntegerValue;
                cacheFiles[fileURL] = resourceValues;
            }
        }
        
        for (NSURL *fileURL in urlsToDelete) {
            [self.fileManager removeItemAtURL:fileURL error:nil];
        }
        
        //if our remaining disk cache exceeds a configured maximum size, perform a second sise-based cleanup pass.
        if (self.cacheConfiguration.maxCacheSize > 0 && currentCacheSize > self.cacheConfiguration.maxCacheSize) {
            const NSUInteger desiredCacheSize = self.cacheConfiguration.maxCacheSize / 2;
            //sort the remaining cache files by their last modification time (oldest first).
            NSArray<NSURL *> *sortedFiles = [cacheFiles keysSortedByValueWithOptions:NSSortConcurrent usingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                return [obj1[NSURLContentModificationDateKey] compare:obj2[NSURLContentModificationDateKey]];
            }];
            
            //delete files until we fall below desired cache size.
            for (NSURL *fileURL in sortedFiles) {
                if ([self.fileManager removeItemAtURL:fileURL error:nil]) {
                    NSDictionary<NSString *, id> *resouceValues = cacheFiles[fileURL];
                    NSNumber *totalAllocatedSize = resouceValues[NSURLTotalFileAllocatedSizeKey];
                    currentCacheSize -= totalAllocatedSize.unsignedIntegerValue;
                    
                    if (currentCacheSize < desiredCacheSize) {
                        break;
                    }
                }
            }
        }
        if (completion) {
            JODispatchSyncOnMainThread(completion);
        }
    });
}

- (void)clearDiskOnCompletion:(dispatch_block_t)completion {
    dispatch_async(self.ioQueue, ^{
        [self.fileManager removeItemAtPath:[JOVideoPlayerCachePath videoCachePath] error:nil];
        if (completion) {
            JODispatchSyncOnMainThread(completion);
        }
    });
}

#pragma mark - File Name
- (NSString *)cacheFileNameForKey:(NSString *)key {
    NSParameterAssert(key);
    if (!key) {
        return nil;
    }
    if ([key length]) {
        NSString *strippedQueryKey = [[NSURL URLWithString:key] absoluteStringByStrippingQuery];
        key = strippedQueryKey.length ? strippedQueryKey : key;
    }
    const char *str = key.UTF8String;
    if (str == NULL) str = "";
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10],
                          r[11], r[12], r[13], r[14], r[15]];
    return filename;

}

#pragma mark - Cache Info
- (BOOL)haveFreeSizeToCacheFileWithSize:(NSUInteger)fileSize {
    unsigned long long freeSizeOfDevice = [self getDiskFreeSize];
    if (fileSize > freeSizeOfDevice) {
        return NO;
    }
    return YES;
}
- (unsigned long long)getSize {
     unsigned long long size = 0;
    NSString *videoCachePath = [JOVideoPlayerCachePath videoCachePath];
    NSDirectoryEnumerator *fileEnumerator_video = [self.fileManager enumeratorAtPath:videoCachePath];
    for (NSString *fileName in fileEnumerator_video) {
        NSString *filePath = [videoCachePath stringByAppendingPathComponent:fileName];
        NSDictionary<NSString *, id> *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        size += [attrs fileSize];
    }
    return size;
}
- (NSUInteger)getDiskCount {
     NSUInteger count = 0;
    NSString *videoCachePath = [JOVideoPlayerCachePath videoCachePath];
    NSDirectoryEnumerator *fileEnumerator_video = [self.fileManager enumeratorAtPath:videoCachePath];
    count += fileEnumerator_video.allObjects.count;
    return count;
}
- (void)calculateSizeOnCompletion:(JOVideoPlayerCaculateSizeCompletion)completion {
    NSString *videoFilePath = [JOVideoPlayerCachePath videoCachePath];
    NSURL *diskCacheURL_video = [NSURL fileURLWithPath:videoFilePath isDirectory:YES];
    
    dispatch_async(self.ioQueue, ^{
        NSUInteger fileCount = 0;
        NSUInteger totalSize = 0;
        NSDirectoryEnumerator *fileEnumerator_video = [self.fileManager enumeratorAtURL:diskCacheURL_video includingPropertiesForKeys:@[NSFileSize] options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:NULL];
        for (NSURL *fileURL in fileEnumerator_video) {
            NSNumber *fileSize;
            [fileURL getResourceValue:&fileSize forKey:NSURLFileSizeKey error:NULL];
            totalSize += fileSize.unsignedIntegerValue;
            fileCount += 1;
        }
        
        if (completion) {
            JODispatchSyncOnMainThread(^{
                completion(fileCount, totalSize);
            });
        }
        
    });
    
}

- (unsigned long long)getDiskFreeSize{
    struct statfs buf;
    unsigned long long freespace = -1;
    if(statfs("/var", &buf) >= 0){
        freespace = (long long)(buf.f_bsize * buf.f_bfree);
    }
    return freespace;
}

#pragma mark - private
- (void)deleteExpiredFiles {
    [self removeAllExpiredFilesOnCompletion:nil];
}
- (void)backgroudDeleteOldFiles {
    if ([UIApplication respondsToSelector:@selector(sharedApplication)]) {
        __block UIBackgroundTaskIdentifier bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:bgTask];
            bgTask = UIBackgroundTaskInvalid;
        }];
        
        // Start the long-running task and return immediately.
        [self removeAllExpiredFilesOnCompletion:^{
            [[UIApplication sharedApplication] endBackgroundTask:bgTask];
            bgTask = UIBackgroundTaskInvalid;
        }];
        
    }
}


@end
