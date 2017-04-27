//
//  NSDictionary+Extension.m
//  模块化Demo
//
//  Created by JimmyOu on 17/3/14.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "NSDictionary+Extension.h"

@implementation NSDictionary (Extension)

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
    
    return @"{}";
}

- (BOOL)contains:(id)key
{
    if (!key) return NO;
    return self[key] != nil;
}

@end
