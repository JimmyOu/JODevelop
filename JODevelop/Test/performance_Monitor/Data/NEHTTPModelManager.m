//
//  NEHTTPModelManager.m
//  SnailReader
//
//  Created by JimmyOu on 2018/8/20.
//  Copyright © 2018年 com.netease. All rights reserved.
//

#import "NEHTTPModelManager.h"
@interface NEHTTPModelManager()
@property (strong, nonatomic) NSMutableArray *netModels;
@end
@implementation NEHTTPModelManager
- (void)addModel:(NEHTTPModel *)model {
    [self.netModels addObject:model];
}
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static NEHTTPModelManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[NEHTTPModelManager alloc] init];
    });
    return manager;
}
- (NSMutableArray *)netModels {
    if (!_netModels) {
        _netModels = [NSMutableArray array];
    }
    return _netModels;
}

@end
