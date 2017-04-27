//
//  RootItemModel.m
//  JODevelop
//
//  Created by JimmyOu on 17/4/13.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "RootItemModel.h"

@implementation RootItemModel

- (instancetype)initWithDict:(NSDictionary *)dic {
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}
+ (instancetype)itemWithDict:(NSDictionary *)dic {
    return [[self alloc] initWithDict:dic];
}

@end
