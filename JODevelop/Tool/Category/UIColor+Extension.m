//
//  UIColor+Extension.m
//  模块化Demo
//
//  Created by JimmyOu on 17/3/21.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "UIColor+Extension.h"

@implementation UIColor (Extension)

+ (nonnull instancetype)colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha
{
    CGFloat red            = 0;
    CGFloat green          = 0;
    CGFloat blue           = 0;
    CGFloat mAlpha         = alpha;
    NSUInteger minusLength = 0;
    
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    if ([hexString hasPrefix:@"#"]) {
        scanner.scanLocation = 1;
        minusLength          = 1;
    }
    
    if ([hexString hasPrefix:@"0x"]) {
        scanner.scanLocation = 2;
        minusLength          = 2;
    }
    
    UInt64 hexValue = 0;
    [scanner scanHexLongLong:&hexValue];
    switch (hexString.length - minusLength) {
        case 3: {
            red   = (CGFloat)((hexValue & 0xF00) >> 8) / 15.0;
            green = (CGFloat)((hexValue & 0x0F0) >> 4) / 15.0;
            blue  = (CGFloat)(hexValue & 0x00F) / 15.0;
            
            break;
        }
        case 4: {
            red    = (CGFloat)((hexValue & 0xF000) >> 12) / 15.0;
            green  = (CGFloat)((hexValue & 0x0F00) >> 8) / 15.0;
            blue   = (CGFloat)((hexValue & 0x00F0) >> 4) / 15.0;
            mAlpha = (CGFloat)(hexValue & 0x00F) / 15.0;
            
            break;
        }
        case 6: {
            red    = (CGFloat)((hexValue & 0xFF0000) >> 16) / 255.0;
            green  = (CGFloat)((hexValue & 0x00FF00) >> 8) / 255.0;
            blue   = (CGFloat)(hexValue & 0x0000FF) / 255.0;
            
            break;
        }
        case 8: {
            red    = (CGFloat)((hexValue & 0xFF000000) >> 24) / 255.0;
            green  = (CGFloat)((hexValue & 0x00FF0000) >> 16) / 255.0;
            blue   = (CGFloat)((hexValue & 0x0000FF00) >> 8) / 255.0;
            mAlpha = (CGFloat)(hexValue & 0x000000FF) / 255.0;
            
            break;
        }
        default:
            break;
    }
    
    return [self colorWithRed:red green:green blue:blue alpha:mAlpha];
}

+ (nonnull instancetype)colorWithHexString:(NSString *)hexString
{
    return [self colorWithHexString:hexString alpha:1.0];
}
+ (nonnull instancetype)randomColor
{
    static BOOL seeded = NO;
    if(!seeded) {
        seeded = YES;
        srandom((unsigned)time(NULL));
    }
    CGFloat red = (CGFloat)random()/(CGFloat)RAND_MAX;
    CGFloat blue = (CGFloat)random()/(CGFloat)RAND_MAX;
    CGFloat green = (CGFloat)random()/(CGFloat)RAND_MAX;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
}


@end
