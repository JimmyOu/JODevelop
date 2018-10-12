//
//  NELocalizationInfo.h
//  SnailReader
//
//  Created by JimmyOu on 2018/9/14.
//  Copyright © 2018年 com.netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NELocalizationInfo : NSObject

// Country
+ (nullable NSString *)country;

// Language
+ (nullable NSString *)language;

// TimeZone
+ (nullable NSString *)timeZone;

// Currency Symbol
+ (nullable NSString *)currency;

@end
