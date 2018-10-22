//
//  NECarrierInfo.h
//  SnailReader
//
//  Created by JimmyOu on 2018/9/14.
//  Copyright © 2018年 com.netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NECarrierInfo : NSObject

// Carrier Name
+ (nullable NSString *)carrierName;

// Carrier Country
+ (nullable NSString *)carrierCountry;

// Carrier Mobile Country Code
+ (nullable NSString *)carrierMobileCountryCode;

// Carrier ISO Country Code
+ (nullable NSString *)carrierISOCountryCode;

// Carrier Mobile Network Code
+ (nullable NSString *)carrierMobileNetworkCode;

// Carrier Allows VOIP
+ (BOOL)carrierAllowsVOIP;

@end
