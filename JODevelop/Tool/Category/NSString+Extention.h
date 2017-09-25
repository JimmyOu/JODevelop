//
//  NSString+Extention.h
//  JOFoundation
//
//  Created by JimmyOu on 16/11/9.
//  Copyright © 2016年 JimmyOu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extention)
+ (BOOL)isEmpty:(NSString *)str ;
- (NSURL *)toUrl;
+ (BOOL)isUrl:(NSString *)str;
- (NSString *)md5;

- (BOOL)isIdCard; //这个有时候会不准。很少发生。特定设备上会发生
@end
