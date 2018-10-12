//
//  NESystemInfo.m
//  SnailReader
//
//  Created by JimmyOu on 2018/9/17.
//  Copyright © 2018年 com.netease. All rights reserved.
//

#import "NESystemInfo.h"
@implementation NESystemInfoItem
+ (instancetype)itemWithTitle:(NSString *)title value:(NSString *)value {
    NESystemInfoItem *item = [[NESystemInfoItem alloc] init];
    item.title = title;
    item.value = value;
    return item;
}

@end
@implementation NESystemInfoModel

- (instancetype)initWithObjects:(NSArray< NSString *> *)objects keys:(NSArray<NSString *> *)keys groupName:(NSString *)groupName {
    if (objects.count != keys.count || (objects.count == 0)) {
        return nil;
    }
    if (self = [super init]) {
        self.groupName = groupName;
        NSMutableArray *mul = [NSMutableArray array];
        for (int i = 0; i < objects.count; i++) {
            NSString *value = objects[i];
            NSString *key = keys[i];
            NESystemInfoItem *item = [NESystemInfoItem itemWithTitle:key value:value];
            [mul addObject:item];
        }
        self.items = [mul copy];
    }
    return self;
}

@end
