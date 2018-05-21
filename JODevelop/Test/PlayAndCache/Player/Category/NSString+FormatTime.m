//
//  NSString+FormatTime.m
//  边下边播Demo
//
//  Created by JimmyOu on 2018/5/8.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "NSString+FormatTime.h"

@implementation NSString (FormatTime)

+ (NSString *)formatTime:(CGFloat)time {
    long videocurrent = ceil(time);
    
    NSString *str = nil;
    if (videocurrent < 3600) {
        str =  [NSString stringWithFormat:@"%02li:%02li",lround(floor(videocurrent/60.f)),lround(floor(videocurrent/1.f))%60];
    } else {
        str =  [NSString stringWithFormat:@"%02li:%02li:%02li",lround(floor(videocurrent/3600.f)),lround(floor(videocurrent%3600)/60.f),lround(floor(videocurrent/1.f))%60];
    }
    return str;
}

@end
