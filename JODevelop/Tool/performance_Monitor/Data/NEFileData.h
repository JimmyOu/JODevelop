//
//  NEFileData.h
//  JODevelop
//
//  Created by JimmyOu on 2018/8/9.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NEFileItem: NSObject

@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *name;
@property (assign, nonatomic) BOOL isDir;
@property (assign, nonatomic) unsigned long long size;
@property (strong, nonatomic) NSDate *modifyDate;
@property (assign, nonatomic) NSInteger subPathCount;

@end

@interface NEFileData : NSObject

@property (nonatomic, strong) NSString *currentDir;

- (NSInteger)numberOfSections;
- (NSInteger)itemCountAtSecion:(NSInteger)section;
- (NEFileItem *)itemAtIndex:(NSInteger)index section:(NSInteger)section;
- (void)reloadData;

@end
