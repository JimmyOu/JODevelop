//
//  NECrashVoid.m
//  SnailReader
//
//  Created by JimmyOu on 2018/8/31.
//  Copyright © 2018年 com.netease. All rights reserved.
//

#import "NECrashVoidManager.h"
#import "NSObject+NECrashVoid.h"
#import "NSArray+NECrashVoid.h"
#import "NSDictionary+NECrashVoid.h"
#import "NSString+NECrashVoid.h"
#import "NSAttributedString+NECrashVoid.h"

@implementation NECrashVoidManager

+ (void)swizzle {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [NSObject swizzle];
        
        [NSArray swizzle];
        [NSMutableArray swizzle];
        
        [NSDictionary swizzle];
        [NSMutableDictionary swizzle];
        
        [NSString swizzle];
        [NSMutableString swizzle];
        
        [NSAttributedString swizzle];
        [NSMutableAttributedString swizzle];
    });
}

@end
