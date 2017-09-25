//
//  NSArray+Extension.m
//  JOFoundation
//
//  Created by JimmyOu on 16/11/9.
//  Copyright © 2016年 JimmyOu. All rights reserved.
//

#import "NSArray+Extension.h"

@implementation NSArray (Extension)

- (id)safeObjectAtIndex:(NSUInteger)index {
    return index < self.count ? self[index] : nil;
}

- (NSString *)toJson
{
    if ([NSJSONSerialization isValidJSONObject:self]) {
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
        if (error) {
            return error.localizedDescription;
        }
        else {
            NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            return json;
        }
    }
    
    return @"[]";
}
@end

@implementation NSMutableArray(Extension)

#pragma mark - 外部扩展方法
- (void)safeAddObject:(id)obj
{
    if (obj) {
        [self addObject:obj];
    }
}

@end
