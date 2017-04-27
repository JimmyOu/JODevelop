//
//  NSString+Extention.m
//  JOFoundation
//
//  Created by JimmyOu on 16/11/9.
//  Copyright © 2016年 JimmyOu. All rights reserved.
//

#import "NSString+Extention.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Extention)
+ (BOOL)isEmpty:(NSString *)str {
    if (!str) {
        return YES;
    }
    return [str isEmpty];
}
- (BOOL)isEmpty {
    if (self) {
        if ([self isKindOfClass:[NSNull class]]) {
            return YES;
        }
        if ([self isEqual:[NSNull null]]) {
            return YES;
        }
        NSString *trimString = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        return (trimString.length == 0);
    }
    return YES;
}
- (NSURL *)toUrl
{
    NSURL *result = [NSURL URLWithString:self];
    if (!result) {
        result = [NSURL URLWithString:[self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    
    if (!result) {
        result = [NSURL URLWithString:@""];
    }
    
    return result;
}
+ (BOOL)isUrl:(NSString *)str
{
    if (nil == str) {
        return NO;
    }
    
    return [str isUrl];
}

- (BOOL)isUrl
{
    // @"(https?|ftp|file)://[-A-Z0-9+&@#/%?=~_|!:,.;]*[-A-Z0-9+&@#/%=~_|]"
    NSRegularExpression *regular = [[NSRegularExpression alloc]
                                    initWithPattern:@"((http|ftp|https|file)://)(([a-zA-Z0-9\\._-]+\\.[a-zA-Z]{2,6})|([0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}))(:[0-9]{1,4})*(/[a-zA-Z0-9\\&%_\\./-~-]*)?"
                                    options:NSRegularExpressionCaseInsensitive
                                    error:nil];
    
    NSUInteger numberOfMatches = [regular numberOfMatchesInString:self
                                                          options:NSMatchingAnchored
                                                            range:NSMakeRange(0, self.length)];
    
    return (numberOfMatches > 0);
}
- (NSString *)md5
{
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result);
    
    return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]];
}

@end
