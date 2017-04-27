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
@end
