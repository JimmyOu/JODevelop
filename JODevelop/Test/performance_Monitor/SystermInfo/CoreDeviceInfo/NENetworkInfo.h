//
//  NENetworkInfo.h
//  SnailReader
//
//  Created by JimmyOu on 2018/9/11.
//  Copyright © 2018年 com.netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NENetworkInfo : NSObject

// Get Current IP Address
+ (nullable NSString *)currentIPAddress;

// Get the External IP Address
+ (nullable NSString *)externalIPAddress;

// Get Cell IP Address
+ (nullable NSString *)cellIPAddress;

// Get Cell IPv6 Address
+ (nullable NSString *)cellIPv6Address;

// Get Cell Netmask Address
+ (nullable NSString *)cellNetmaskAddress;

// Get Cell Broadcast Address
+ (nullable NSString *)cellBroadcastAddress;

// Get WiFi IP Address
+ (nullable NSString *)wiFiIPAddress;

// Get WiFi IPv6 Address
+ (nullable NSString *)wiFiIPv6Address;

// Get WiFi Netmask Address
+ (nullable NSString *)wiFiNetmaskAddress;

// Get WiFi Broadcast Address
+ (nullable NSString *)wiFiBroadcastAddress;

// Get WiFi Router Address
+ (nullable NSString *)wiFiRouterAddress;

// Connected to WiFi?
+ (BOOL)connectedToWiFi;

// Connected to Cellular Network?
+ (BOOL)connectedToCellNetwork;


@end
