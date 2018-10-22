//
//  NEMonitorFileManager.m
//  JODevelop
//
//  Created by JimmyOu on 2018/8/8.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "NEMonitorFileManager.h"
#define REPORT_FILE_SUFFIX @"crash"
@interface NEMonitorFileManager()
@property (strong, nonatomic) dispatch_queue_t ioQueue;
@end
@implementation NEMonitorFileManager

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static NEMonitorFileManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[NEMonitorFileManager alloc] init];
    });
    return manager;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        _ioQueue = dispatch_queue_create("com.NEMonitor.ioQueue", DISPATCH_QUEUE_SERIAL);
        [self deleteOutDateFiles:[self fluentDir]];
        [self deleteOutDateFiles:[self crashDir]];
//        [self deleteOutDateFiles:[self highCPUDir]];
    }
    return self;
}
- (void)saveReportToLocal:(NSString *)report withFileName:(NSString *)fileName type:(NEMonitorFileManagerType)type{
    dispatch_async(self.ioQueue, ^{
        NSString *flentDir = nil;
        switch (type) {
            case NEMonitorFileFluentType:
                flentDir = [self fluentDir];
                break;
            case NEMonitorFileCrashType:
                flentDir = [self crashDir];
                break;
                
            default:
                break;
        }
        NSString *f = [self rename:fileName suffix:REPORT_FILE_SUFFIX inDir:flentDir];
        NSString *filePath = [NSString stringWithFormat:@"%@/%@.%@", flentDir, f, REPORT_FILE_SUFFIX];
        [report writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        NSLog(@"write file to fluent Dir:%@",flentDir);
    });
}

- (NSString *)rename:(NSString *)filename suffix:(NSString *)suffix inDir:(NSString *)dir {
    NSArray *filenames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:nil];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"%@(.*)\\.%@", filename, suffix] options:0 error:nil];
    NSInteger maxIndex = 0;
    for (NSString *f in filenames) {
        NSArray *matches = [regex matchesInString:f options:0 range:NSMakeRange(0, f.length)];
        for (NSTextCheckingResult *match in matches) {
            NSString *matchText = [f substringWithRange:[match rangeAtIndex:1]];
            NSString *index = @"1";
            if (matchText.length > 0) {
                index = [matchText stringByReplacingOccurrencesOfString:@"[" withString:@""];
                index = [index stringByReplacingOccurrencesOfString:@"]" withString:@""];
            }
            maxIndex = MAX(maxIndex, index.integerValue);
        }
    }
    if (maxIndex > 0) {
        filename = [NSString stringWithFormat:@"%@[%@]", filename, @(maxIndex + 1)];
    }
    return filename;
}
- (void)addNewRetainCycle:(NSString *)retainStr {
    NSString *gapString = @"\n--------->retainCycle<----------\n";
    if(![[NSFileManager defaultManager] fileExistsAtPath:[self cycleFile]]) {
        [gapString writeToFile:[self cycleFile] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
     NSFileHandle *outFile = [NSFileHandle fileHandleForWritingAtPath:[self cycleFile]];
    
    if (outFile) {
        NSData *buffer = [retainStr dataUsingEncoding:NSUTF8StringEncoding];
        [outFile seekToEndOfFile];
        [outFile writeData:buffer];
        [outFile seekToEndOfFile];
        [outFile writeData:[gapString dataUsingEncoding:NSUTF8StringEncoding]];
        [outFile closeFile];
    }
}
- (void)deleteOutDateFiles:(NSString *)dir {
    dispatch_async(self.ioQueue, ^{
        NSURL *diskCacheURL = [NSURL fileURLWithPath:dir];
        NSArray <NSString *> *resourceKeys = @[NSURLIsDirectoryKey, NSURLContentModificationDateKey];
        NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:diskCacheURL
                                                                     includingPropertiesForKeys:resourceKeys
                                                                                        options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                                   errorHandler:NULL];
        
        NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-60 * 60 * 24 * 3];// delete files >= 3
        NSMutableArray<NSURL *> *urlsToDelete = [NSMutableArray array];
        
        @autoreleasepool {
            for (NSURL *fileURL in fileEnumerator) {
                NSError *error;
                NSDictionary<NSString *, id> *resourceValues = [fileURL resourceValuesForKeys:resourceKeys error:&error];
                if (error || !resourceValues || [resourceValues[NSURLIsDirectoryKey] boolValue]) {
                    continue;
                }
                
                NSDate *modificationDate = resourceValues[NSURLContentModificationDateKey];
                if ([[modificationDate laterDate:expirationDate] isEqualToDate:expirationDate]) {
                    [urlsToDelete addObject:fileURL];
                    continue;
                }
            }
        }
        for (NSURL *fileURL in urlsToDelete) {
            [[NSFileManager defaultManager] removeItemAtURL:fileURL error:nil];
        }
        
    });
}

- (NSString *)monitorDir {
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *dir = [NSString stringWithFormat:@"%@/NEMonitor", docDir];
    return dir;
}
- (NSString *)fluentDir {
    NSString *dir = [NSString stringWithFormat:@"%@/fluent", [self monitorDir]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return dir;
}

- (NSString *)crashDir {
    NSString *dir = [NSString stringWithFormat:@"%@/crash", [self monitorDir]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return dir;
}

//- (NSString *)highCPUDir {
//    NSString *dir = [NSString stringWithFormat:@"%@/highCPU", [self monitorDir]];
//    if (![[NSFileManager defaultManager] fileExistsAtPath:dir]) {
//        [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
//    }
//    return dir;
//}

- (NSString *)cycleFile {
    NSString *dir = [self monitorDir];
    [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *path = [NSString stringWithFormat:@"%@/cycle", dir];
    return path;
}

@end
