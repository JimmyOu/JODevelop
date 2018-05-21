//
//  JOVideoPlayerCachePath.h
//  JODevelop
//
//  Created by JimmyOu on 2018/5/15.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JOVideoPlayerCachePath : NSObject

/**
 video cache path
 */
+ (NSString *)videoCachePath;

/**
  fetch CachePath for key
 */
+ (NSString *)videoCachePathForKey:(NSString *)key;

/**
 create VideoFile for Key

 @return VideoFile
 */
+ (NSString *)createVideoFileIfNeededForKey:(NSString *)key;

/**
 fetch IndexFilePath for key
 */
+ (NSString *)videoCacheIndexFilePathForKey:(NSString *)key;

/**
 create IndexFilePath for Key
 
 @return IndexFilePath
 */
+ (NSString *)createVideoIndexFileIfNeededForKey:(NSString *)key;


@end
