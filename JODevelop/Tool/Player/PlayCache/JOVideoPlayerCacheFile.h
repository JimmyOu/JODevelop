//
//  JOVideoPlayerCacheFile.h
//  JODevelop
//
//  Created by JimmyOu on 2018/5/15.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JOVideoPlayerCacheFile : NSObject
/**
 * The cache file path of video data.
 */
@property (readonly) NSString *cacheFilePath;

/**
 * The index file cache path. because the video datas cache in disk maybe are discontinuous like:
 * "01010101*********0101*****010101010101"(the 0 and 1 represent video data, and the  * represent no data).
 * So we need index to map this video data, and the index file is a colletion of indexes store in disk.
 */
@property (readonly, nullable) NSString *indexFilePath;
/**
 * The video data expected length.
 * Note this value is not always equal to the cache video data length.
 */
@property (readonly) NSUInteger fileLength;
/**
 * The fragment of video data that cached in disk.
 */
@property (readonly, nullable) NSArray<NSValue *> *fragmentRanges;
/**
 * The offset of read postion.
 */
@property (readonly) NSUInteger readOffset;
/**
 * The response header from web.
 */
@property (readonly, nullable) NSDictionary *responseHeaders;
/**
 * A flag represent the video data is cache finished or not.
 */
@property (readonly) BOOL isCompleted;
/**
 * A flag represent read offset is point to the end of video data file.
 */
@property (readonly) BOOL isEOF;

/**
 * A flag represent file length is greater than 0.
 */
@property (readonly) BOOL isFileLengthValid;

/**
 * The cached video data length.
 */
@property (readonly) NSUInteger cachedDataBound;

/**
 * Convenience method to fetch instance of this class.
 * Note this class take responsibility for save video data to disk and read cached video from disk.
 *
 * @param filePath      The video data cache path.
 * @param indexFilePath The index file cache path.
 *
 * @return A instance of this class.
 */
+ (instancetype)cacheFileWithFilePath:(NSString *)filePath
                        indexFilePath:(NSString *)indexFilePath;

/**
 * Designated initializer method.
 * Note this class take responsibility for save video data to disk and read cached video from disk.
 *
 * @param filePath      The video data cache path.
 * @param indexFilePath The index file cache path.
 *
 * @return A instance of this class.
 */
- (instancetype)initWithFilePath:(NSString *)filePath
                   indexFilePath:(NSString *)indexFilePath NS_DESIGNATED_INITIALIZER;


#pragma mark - Store

/**
 * Call this method to store video data to disk.
 *
 * @param data        Video data.
 * @param offset      The offset of the data in video file.
 * @param synchronize A flag indicator store index to index file synchronize or not.
 * @param completion  Call when store the data finished.
 */
- (void)storeVideoData:(NSData *)data
              atOffset:(NSUInteger)offset
           synchronize:(BOOL)synchronize
      storedCompletion:(dispatch_block_t)completion;

/**
 * Set the response from web when request video data.
 *
 * @param response The response from web when request video data.
 *
 * @return The result of storing response.
 */
- (BOOL)storeResponse:(NSHTTPURLResponse *)response;

/**
 * Store index to index file synchronize.
 *
 * @return The result of store index to index file successed or failed.
 */
- (BOOL)synchronize;

#pragma mark - Read
/**
 * Fetch data from the readOffset to given length position.
 * Note call `seekToPosition:` to set the readOffset before call this method.
 * Note the data not always have video data if the data not cached in disk.
 *
 * @param length The length of data.
 *
 * @return Data from the header to given length position.
 */
- (NSData * _Nullable)readDataWithLength:(NSUInteger)length;

/**
 * Fetch data in given range.
 * Note the data not always have video data if the data not cached in disk.
 *
 * @param range The range in file.
 *
 * @return Data in given range.
 */
- (NSData *)dataWithRange:(NSRange)range;

#pragma mark - Remove
/**
 * Remove the cached video data.
 */
- (void)removeCache;


#pragma mark - Range

/**
 * Fetch the cached video data range for given range.
 *
 * @param range A given range.
 *
 * @return The cached video data range for given range.
 */
- (NSRange)cachedRangeForRange:(NSRange)range;

/**
 * Fetch the range of cached video data contain given position.
 *
 * @param position A position point to a point of video file.
 *
 * @return The range of cached video data contain given position.
 */
- (NSRange)cachedRangeContainsPosition:(NSUInteger)position;

/**
 * Find the first range of video data not cached in given postion.{firstNoteCacheLocation, fileLength - firstNoteCacheLocation}
 *
 * @param position A position point to a point of video file.
 *
 * @return The first range of video data not cached in given postion.
 */
- (NSRange)firstNotCachedRangeFromPosition:(NSUInteger)position;


#pragma mark - Seek

/**
 * Set the fileHandle seek to the given offset.
 *
 * @param position A position point to a point of video file.
 */
- (void)seekToPosition:(NSUInteger)position;

/**
 * Set the fileHandle seek to end of file.
 */
- (void)seekToEnd;






@end
