//
//  NSString+NECrashVoid.m
//  SnailReader
//
//  Created by JimmyOu on 2018/8/31.
//  Copyright © 2018年 com.netease. All rights reserved.
//

#import "NSString+NECrashVoid.h"
#import "NEMonitorUtils.h"

@implementation NSString (NECrashVoid)

+ (void)swizzle {
    Class stringClass = NSClassFromString(@"__NSCFConstantString");
    
    //characterAtIndex
    [NEMonitorUtils ne_swizzleSEL:@selector(characterAtIndex:)
                          withSEL:@selector(avoidCrashCharacterAtIndex:)
                         forClass:stringClass];
    
    //substringFromIndex
    [NEMonitorUtils ne_swizzleSEL:@selector(substringFromIndex:)
                          withSEL:@selector(avoidCrashSubstringFromIndex:)
                         forClass:stringClass];
    
    //substringToIndex
    [NEMonitorUtils ne_swizzleSEL:@selector(substringToIndex:)
                          withSEL:@selector(avoidCrashSubstringToIndex:)
                         forClass:stringClass];
    
    //substringWithRange:
    [NEMonitorUtils ne_swizzleSEL:@selector(substringWithRange:)
                          withSEL:@selector(avoidCrashSubstringWithRange:)
                         forClass:stringClass];
    
    //stringByReplacingOccurrencesOfString:
    [NEMonitorUtils ne_swizzleSEL:@selector(stringByReplacingOccurrencesOfString:withString:)
                              withSEL:@selector(avoidCrashStringByReplacingOccurrencesOfString:withString:)
                             forClass:stringClass];
    
    //stringByReplacingOccurrencesOfString:withString:options:range:
    [NEMonitorUtils ne_swizzleSEL:@selector(stringByReplacingOccurrencesOfString:withString:options:range:)
                                  withSEL:@selector(avoidCrashStringByReplacingOccurrencesOfString:withString:options:range:)
                                 forClass:stringClass];
    
    //stringByReplacingCharactersInRange:withString:
    [NEMonitorUtils ne_swizzleSEL:@selector(stringByReplacingCharactersInRange:withString:)
                          withSEL:@selector(avoidCrashStringByReplacingCharactersInRange:withString:)
                         forClass:stringClass];
    
}
- (unichar)avoidCrashCharacterAtIndex:(NSUInteger)index {
    
    unichar characteristic;
    @try {
        characteristic = [self avoidCrashCharacterAtIndex:index];
    }
    @catch (NSException *exception) {
        [NEMonitorUtils notifyWithException:exception];
    }
    @finally {
        return characteristic;
    }
}

- (NSString *)avoidCrashSubstringFromIndex:(NSUInteger)from {
    
    NSString *subString = nil;
    
    @try {
        subString = [self avoidCrashSubstringFromIndex:from];
    }
    @catch (NSException *exception) {
        [NEMonitorUtils notifyWithException:exception];
        subString = nil;
    }
    @finally {
        return subString;
    }
}
- (NSString *)avoidCrashSubstringToIndex:(NSUInteger)to {
    
    NSString *subString = nil;
    
    @try {
        subString = [self avoidCrashSubstringToIndex:to];
    }
    @catch (NSException *exception) {
        [NEMonitorUtils notifyWithException:exception];
        subString = nil;
    }
    @finally {
        return subString;
    }
}

- (NSString *)avoidCrashSubstringWithRange:(NSRange)range {
    
    NSString *subString = nil;
    
    @try {
        subString = [self avoidCrashSubstringWithRange:range];
    }
    @catch (NSException *exception) {
        [NEMonitorUtils notifyWithException:exception];
        subString = nil;
    }
    @finally {
        return subString;
    }
}

- (NSString *)avoidCrashStringByReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement {
    
    NSString *newStr = nil;
    
    @try {
        newStr = [self avoidCrashStringByReplacingOccurrencesOfString:target withString:replacement];
    }
    @catch (NSException *exception) {
        [NEMonitorUtils notifyWithException:exception];
        newStr = nil;
    }
    @finally {
        return newStr;
    }
}

- (NSString *)avoidCrashStringByReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement options:(NSStringCompareOptions)options range:(NSRange)searchRange {
    
    NSString *newStr = nil;
    
    @try {
        newStr = [self avoidCrashStringByReplacingOccurrencesOfString:target withString:replacement options:options range:searchRange];
    }
    @catch (NSException *exception) {
        [NEMonitorUtils notifyWithException:exception];
        newStr = nil;
    }
    @finally {
        return newStr;
    }
}

- (NSString *)avoidCrashStringByReplacingCharactersInRange:(NSRange)range withString:(NSString *)replacement {
    
    
    NSString *newStr = nil;
    
    @try {
        newStr = [self avoidCrashStringByReplacingCharactersInRange:range withString:replacement];
    }
    @catch (NSException *exception) {
        [NEMonitorUtils notifyWithException:exception];
        newStr = nil;
    }
    @finally {
        return newStr;
    }
}

@end

@implementation NSMutableString (NECrashVoid)

+ (void)swizzle {
    Class stringClass = NSClassFromString(@"__NSCFString");
    
    //replaceCharactersInRange
    [NEMonitorUtils ne_swizzleSEL:@selector(characterAtIndex:)
                          withSEL:@selector(avoidCrashCharacterAtIndex:)
                         forClass:stringClass];
    
    
    //insertString:atIndex:
    [NEMonitorUtils ne_swizzleSEL:@selector(characterAtIndex:)
                          withSEL:@selector(avoidCrashCharacterAtIndex:)
                         forClass:stringClass];
    
    
    //deleteCharactersInRange
    [NEMonitorUtils ne_swizzleSEL:@selector(characterAtIndex:)
                          withSEL:@selector(avoidCrashCharacterAtIndex:)
                         forClass:stringClass];
    
}

@end
