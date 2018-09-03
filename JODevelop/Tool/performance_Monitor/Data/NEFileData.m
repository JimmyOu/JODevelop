//
//  NEFileData.m
//  JODevelop
//
//  Created by JimmyOu on 2018/8/9.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "NEFileData.h"

@implementation NEFileItem

@end

@implementation NEFileData {
    NSMutableDictionary *_dirContents;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        _dirContents = [[NSMutableDictionary alloc] init];
    }
    return self;
}
- (void)setCurrentDir:(NSString *)currentDir {
    if (![_currentDir isEqualToString:currentDir]) {
        _currentDir = currentDir;
        [self listDir];
    }
}
- (void)listDir {
    NSMutableArray *sections = [NSMutableArray array];
    NSMutableArray *files = [NSMutableArray array];
    NSMutableArray *dirs = [NSMutableArray array];
    NSArray *fileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_currentDir error:nil];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    for (NSString *filename in fileNames) {
        NEFileItem *item = [[NEFileItem alloc] init];
        NSString *path = [NSString stringWithFormat:@"%@/%@",_currentDir,filename];
        NSDictionary *fileAttr = [fileManager attributesOfItemAtPath:path error:nil];
        item.path = path;
        item.name = filename;
        item.size = [fileAttr fileSize];
        item.modifyDate = [fileAttr fileModificationDate];
        if ([[fileAttr fileType] isEqualToString:NSFileTypeDirectory]) {
            item.isDir = YES;
        }
        if (item.isDir) {
            NSArray *fileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:item.path error:nil];
            item.subPathCount = fileNames.count;
            [dirs addObject:item];
        } else {
            [files addObject:item];
        }
    }
    
    NSComparator c = ^NSComparisonResult(NEFileItem *item1, NEFileItem *item2) {
        if ([item1.modifyDate timeIntervalSince1970] > [item2.modifyDate timeIntervalSince1970]) {
            return NSOrderedAscending;
        } else if ([item1.modifyDate timeIntervalSince1970] < [item2.modifyDate timeIntervalSince1970]) {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    };
    [dirs sortUsingComparator:c];
    [files sortUsingComparator:c];
    [sections addObject:dirs];
    [sections addObject:files];
    _dirContents[_currentDir] = sections;
}

- (NSInteger)numberOfSections {
    NSMutableArray *sections = _dirContents[_currentDir];
    return sections.count;
}
- (NSInteger)itemCountAtSecion:(NSInteger)section {
    NSMutableArray *sections = _dirContents[_currentDir];
    NSMutableArray *items = sections[section];
    return items.count;
}
- (NEFileItem *)itemAtIndex:(NSInteger)index section:(NSInteger)section {
    NSMutableArray *sections = _dirContents[_currentDir];
    NSMutableArray *items = sections[section];
    return items[index];
}
- (void)reloadData
{
    [self listDir];
}
@end
