//
//  JOVideoPlayerCacheFile.m
//  JODevelop
//
//  Created by JimmyOu on 2018/5/15.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "JOVideoPlayerCacheFile.h"
#import "JOVideoPlayerCompat.h"
#import <pthread.h>


@interface JOVideoPlayerCacheFile()
@property (nonatomic, strong) NSMutableArray<NSValue *> *internalFragmentRanges; //这里面的东西会被拼接，完成就会拼接成一个完整的长度为视频长度的完整的range

@property (nonatomic, strong) NSFileHandle *writeFileHandle;

@property (nonatomic, strong) NSFileHandle *readFileHandle;

@property(nonatomic, assign) BOOL completed;

@property (nonatomic, assign) NSUInteger fileLength;

@property (nonatomic, assign) NSUInteger readOffset;

@property (nonatomic, copy) NSDictionary *responseHeaders;

@property (nonatomic) pthread_mutex_t lock;
@end
static const NSString *kJOVideoPlayerCacheFileZoneKey = @"kJOVideoPlayerCacheFileZoneKey"; //cached fragments ranges
static const NSString *kJOVideoPlayerCacheFileSizeKey = @"kJOVideoPlayerCacheFileSizeKey"; //文件大小Key
static const NSString *kJOVideoPlayerCacheFileResponseHeadersKey = @"kJOVideoPlayerCacheFileResponseHeadersKey";

@implementation JOVideoPlayerCacheFile

+ (instancetype)cacheFileWithFilePath:(NSString *)filePath indexFilePath:(NSString *)indexFilePath {
    return [[self alloc] initWithFilePath:filePath indexFilePath:indexFilePath];
}
- (instancetype)initWithFilePath:(NSString *)filePath indexFilePath:(NSString *)indexFilePath {
    JOMainThreadAssert;
    NSParameterAssert(filePath.length && indexFilePath.length);
    if (!filePath.length || !indexFilePath.length) {
        return nil;
    }
    if (self = [super init]) {
        _cacheFilePath = filePath;
        _indexFilePath = indexFilePath;
        _internalFragmentRanges = [[NSMutableArray alloc] init];
        _readFileHandle = [NSFileHandle fileHandleForReadingAtPath:_cacheFilePath];
        _writeFileHandle = [NSFileHandle fileHandleForWritingAtPath:_cacheFilePath];
        Init_PThread_Lock(&_lock);
        NSString *indexStr = [NSString stringWithContentsOfFile:self.indexFilePath encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [indexStr dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *indexDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                        options:NSJSONReadingMutableContainers | NSJSONReadingAllowFragments
                                                                          error:nil];
        if (![self serializeIndex:indexDictionary]) {
            [self truncateFileWithFileLength:0];
        }
        [self checkIsCompleted];
    }
    return self;
}

- (instancetype)init
{
    NSAssert(NO, @"Please use given initializer method");
    return [self initWithFilePath:@""
                    indexFilePath:@""];
}

- (void)dealloc {
    [self.readFileHandle closeFile];
    [self.writeFileHandle closeFile];
    pthread_mutex_destroy(&_lock);
}
#pragma mark - Properties
- (NSUInteger)cachedDataBound {
    if (self.internalFragmentRanges.count > 0) {
        NSRange range = [[self.internalFragmentRanges lastObject] rangeValue];
        return NSMaxRange(range);
    }
    return 0;
}
- (BOOL)isFileLengthValid {
    return self.fileLength != 0;
}

- (BOOL)isCompleted {
    return self.completed;
}

- (BOOL)isEOF {
    if (self.readOffset + 1 >= self.fileLength) {
        return YES;
    }
    return NO;
}

#pragma mark - Range
- (NSArray<NSValue *> *)fragmentRanges {
    return self.internalFragmentRanges;
}

- (void)mergeRangesIfNeeded {
    JOMainThreadAssert;
    int lock = pthread_mutex_trylock(&_lock);
    for (int i = 0; i < self.internalFragmentRanges.count; ++i) {
        if ((i + 1) < self.internalFragmentRanges.count) {
            NSRange currentRange = [self.internalFragmentRanges[i] rangeValue];
            NSRange nextRange = [self.internalFragmentRanges[i + 1] rangeValue];
            if (JORangeCanMerge(currentRange, nextRange)) {
             [self.internalFragmentRanges removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(i, 2)]];
            [self.internalFragmentRanges insertObject:[NSValue valueWithRange:NSUnionRange(currentRange, nextRange)] atIndex:i];
                i -= 1;
            }
        }
    }
    if (!lock) {
        pthread_mutex_unlock(&_lock);
    }
}

- (void)addRange:(NSRange)range completion:(dispatch_block_t)completion {
    if (range.length == 0 || range.location >= self.fileLength) {
        return;
    }
    JODispatchSyncOnMainThread(^{
        int lock = pthread_mutex_trylock(&self->_lock);
        BOOL inserted = NO;
        for (int i = 0; i < self.internalFragmentRanges.count; ++i) {
            NSRange currentRange = [self.internalFragmentRanges[i] rangeValue];
            if (currentRange.location > range.location) {
                [self.internalFragmentRanges insertObject:[NSValue valueWithRange:range] atIndex:i];
                inserted = YES;
                break;
            }
        }
        if (!inserted) {
            [self.internalFragmentRanges addObject:[NSValue valueWithRange:range]];
        }
        if (!lock) {
            pthread_mutex_unlock(&self->_lock);
        }
        [self mergeRangesIfNeeded];
        [self checkIsCompleted];
        if (completion) {
            completion();
        }
    });
}

- (NSRange)cachedRangeForRange:(NSRange)range {
    NSRange cachedRange = [self cachedRangeContainsPosition:range.location];
    NSRange ret = NSIntersectionRange(cachedRange, range);
    if (ret.length > 0) {
        return ret;
    } else {
        return JOInvalidRange;
    }
}

- (NSRange)cachedRangeContainsPosition:(NSUInteger)position {
    if (position >= self.fileLength) {
        return JOInvalidRange;
    }
    int lock = pthread_mutex_trylock(&_lock);
    for (int i = 0; i < self.internalFragmentRanges.count; i++) {
        NSRange range = [self.internalFragmentRanges[i] rangeValue];
        if (NSLocationInRange(position, range)) {
            return range;
        }
    }
    if (!lock) {
        pthread_mutex_unlock(&_lock);
    }
    return JOInvalidRange;
}

- (NSRange)firstNotCachedRangeFromPosition:(NSUInteger)position {
    if (position >= self.fileLength) {
        return JOInvalidRange;
    }
    int lock = pthread_mutex_trylock(&_lock);
    NSRange targetRange = JOInvalidRange;
    NSUInteger start = position;
    for (int i = 0; i < self.internalFragmentRanges.count; i++) {
        NSRange range = [self.internalFragmentRanges[i] rangeValue];
        if (NSLocationInRange(start, range)) {
            start = NSMaxRange(range);
        } else {
            if (start >= NSMaxRange(range)) {
                continue;
            } else {
                targetRange = NSMakeRange(start, range.location - start);
            }
        }
    }
    if (start < self.fileLength) {
        targetRange = NSMakeRange(start, self.fileLength - start);
    }
    if (!lock) {
        pthread_mutex_unlock(&_lock);
    }
    return targetRange;
    
}
- (void)checkIsCompleted {
    int lock = pthread_mutex_trylock(&_lock);
    self.completed = NO;
    if (self.internalFragmentRanges && self.internalFragmentRanges.count == 1) {
        NSRange range = [self.internalFragmentRanges[0] rangeValue];
        if (range.location == 0 && (range.length == self.fileLength)) {
            self.completed = YES;
            [NSFileManager.defaultManager removeItemAtPath:self.indexFilePath error:nil];
        }
    }
    if (!lock) {
        pthread_mutex_unlock(&_lock);
    }
}

#pragma mark - Index
- (BOOL)serializeIndex:(NSDictionary *)indexDictionary {
    if (![indexDictionary isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    int lock = pthread_mutex_trylock(&_lock);
    NSNumber *fileSize = indexDictionary[kJOVideoPlayerCacheFileSizeKey];
    if (fileSize && [fileSize isKindOfClass:[NSNumber class]]) {
        self.fileLength = [fileSize unsignedIntegerValue];
    }
    if (self.fileLength == 0) {
        if (!lock) {
            pthread_mutex_unlock(&_lock);
        }
        return NO;
    }
    [self.internalFragmentRanges removeAllObjects];
    NSMutableArray *rangeArray = indexDictionary[kJOVideoPlayerCacheFileZoneKey];
    for (NSString *rangeStr in rangeArray) {
        NSRange range = NSRangeFromString(rangeStr);
        [self.internalFragmentRanges addObject:[NSValue valueWithRange:range]];
    }
    self.responseHeaders = indexDictionary[kJOVideoPlayerCacheFileResponseHeadersKey];
    if (!lock) {
        pthread_mutex_unlock(&_lock);
    }
    return YES;
}



- (NSString *)unserializeIndex {
    int lock = pthread_mutex_trylock(&_lock);
    NSMutableArray *rangeArray = [[NSMutableArray alloc] init];
    for (NSValue *range in self.internalFragmentRanges) {
        [rangeArray addObject:NSStringFromRange([range rangeValue])];
    }
    NSMutableDictionary *dict = [@{
                                  kJOVideoPlayerCacheFileSizeKey:@(self.fileLength),
                                  kJOVideoPlayerCacheFileZoneKey:rangeArray
                                  } mutableCopy];
    if (self.responseHeaders) {
        dict[kJOVideoPlayerCacheFileResponseHeadersKey] = self.responseHeaders;
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    if (data) {
        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (!lock) {
            pthread_mutex_unlock(&_lock);
        }
        return dataString;
    }
    if (!lock) {
        pthread_mutex_unlock(&_lock);
    }
    return nil;
    
}

- (BOOL)synchronize {
    NSString *indexString = [self unserializeIndex];
    int lock = pthread_mutex_trylock(&_lock);
    [self.writeFileHandle synchronizeFile];
    BOOL synchronize = YES;
    if (!self.isCompleted) {
        synchronize = [indexString writeToFile:self.indexFilePath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    }
    if (!lock) {
        pthread_mutex_unlock(&_lock);
    }
    return synchronize;
}



#pragma mark - File

- (BOOL)truncateFileWithFileLength:(NSUInteger)fileLength {
    NSLog(@"Truncate file to lenth: %lu",fileLength);
    if (!self.writeFileHandle) {
        return NO;
    }
    int lock = pthread_mutex_trylock(&_lock);
    self.fileLength = fileLength;
    @try {
        //将文件长度设置为offset
        [self.writeFileHandle truncateFileAtOffset:self.fileLength * sizeof(Byte)];
        //将当前文件的操作位置设置为文件末尾处
        unsigned long long end = [self.writeFileHandle seekToEndOfFile];
        if (end != self.fileLength) {
            if (!lock) {
                pthread_mutex_unlock(&_lock);
            }
            return NO;
        }
        
    }
    @catch (NSException * e){
        NSLog(@"Truncate file raise exception: %@", e);
        if (!lock) {
            pthread_mutex_unlock(&_lock);
        }
        return NO;
    }
    if (!lock) {
        pthread_mutex_unlock(&_lock);
    }
    return YES;
}
- (void)removeCache {
    [[NSFileManager defaultManager] removeItemAtPath:self.cacheFilePath error:NULL];
    [[NSFileManager defaultManager] removeItemAtPath:self.indexFilePath error:NULL];
}
- (BOOL)storeResponse:(NSHTTPURLResponse *)response {
    BOOL success = YES;
    if (![self isFileLengthValid]) {
        success = [self truncateFileWithFileLength:(NSUInteger)response.jo_fileLength];
    }
    self.responseHeaders = [[response allHeaderFields] copy];
    success = success && [self synchronize];
    return success;
}
- (void)storeVideoData:(NSData *)data atOffset:(NSUInteger)offset synchronize:(BOOL)synchronize storedCompletion:(dispatch_block_t)completion {
    NSParameterAssert(self.writeFileHandle);
    @try {
        [self.writeFileHandle seekToFileOffset:offset];
        [self.writeFileHandle jo_safeWriteData:data];
    }
    @catch (NSException * e){
        NSLog(@"Write file raise a error = %@", e);
    }
    [self addRange:NSMakeRange(offset, [data length]) completion:completion];
    if (synchronize) {
        [self synchronize];
    }
}

#pragma mark -  read data
- (NSData *)dataWithRange:(NSRange)range {
    if (!JOValidFileRange(range)) {
        return nil;
    }
    if (self.readOffset != range.location) {
        [self seekToPosition:range.location];
    }
    return [self readDataWithLength:range.length];
}

- (NSData *)readDataWithLength:(NSUInteger)length {
    NSRange range = [self cachedRangeForRange:NSMakeRange(self.readOffset, length)];
    if (JOValidFileRange(range)) {
        int lock = pthread_mutex_trylock(&_lock);
        NSData *data = [self.readFileHandle readDataOfLength:range.length];
        self.readOffset += data.length;
        if (!lock) {
            pthread_mutex_unlock(&_lock);
        }
        return data;
    }
    return nil;
}
#pragma mark - seek
- (void)seekToPosition:(NSUInteger)position {
    int lock = pthread_mutex_trylock(&_lock);
    [self.readFileHandle seekToFileOffset:position];
    self.readOffset = (NSUInteger)self.readFileHandle.offsetInFile;
    if (!lock) {
        pthread_mutex_unlock(&_lock);
    }
}
- (void)seekToEnd {
    int lock = pthread_mutex_trylock(&_lock);
    [self.readFileHandle seekToEndOfFile];
    self.readOffset = (NSUInteger)self.readFileHandle.offsetInFile;
    if (!lock) {
        pthread_mutex_unlock(&_lock);
    }
}
@end
