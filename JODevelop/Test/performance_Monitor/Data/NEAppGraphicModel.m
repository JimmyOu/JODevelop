//
//  NEAppGraphicModel.m
//  SnailReader
//
//  Created by JimmyOu on 2018/10/9.
//  Copyright © 2018年 com.netease. All rights reserved.
//

#import "NEAppGraphicModel.h"

@interface NEAppGraphicModel()
@property (strong, nonatomic) NSMutableArray *times_mul;
@property (strong, nonatomic) NSMutableArray *values_mul;

@end
@implementation NEAppGraphicModel
- (NSArray *)times {
    return [_times_mul copy];
}
- (NSArray *)values {
    return [_values_mul copy];
}
- (void)addTime:(NSNumber *)time value:(NSNumber *)value {
    if (!_values_mul) {
        _times_mul = [NSMutableArray array];
    }
    if (!_values_mul) {
        _values_mul = [NSMutableArray array];
    }
    [_times_mul addObject:time];
    [_values_mul addObject:value];
}
- (void)clearAllData {
    [self.times_mul removeAllObjects];
    [self.values_mul removeAllObjects];
}

@end
