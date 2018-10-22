//
//  NESystemInfo.h
//  SnailReader
//
//  Created by JimmyOu on 2018/9/11.
//  Copyright © 2018年 com.netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NESystemInfoModel.h"
@interface NESystemInfo : NSObject

/* Hardware Information */

// System Uptime (dd hh mm)
@property (nonatomic, readonly, nullable) NSString *systemsUptime;


// Device Name
@property (nonatomic, readonly, nullable) NSString *deviceName;

// System Name
@property (nonatomic, readonly, nullable) NSString *systemName;

// System Version
@property (nonatomic, readonly, nullable) NSString *systemsVersion;

// System Device Type (Formatted = iPhone 1)
@property (nonatomic, readonly, nullable) NSString *systemDeviceType;

// Get the Screen Width (X)
@property (nonatomic, readonly) NSInteger screenWidth;

// Get the Screen Height (Y)
@property (nonatomic, readonly) NSInteger screenHeight;

// Get the Screen Brightness
@property (nonatomic, readonly) float screenBrightness;


// Debugger Attached?
@property (nonatomic, readonly) BOOL debuggerAttached;

// Jailbroken?
@property (nonatomic, readonly) BOOL jailbroken;

/* Processor Information */
@property (nonatomic, readonly) NSInteger numberProcessors;

// Number of Active Processors
@property (nonatomic, readonly) NSInteger numberActiveProcessors;

// Processor Usage Information
@property (nonatomic, readonly, nullable) NSArray *processorsUsage;

/* Carrier Information */

// Carrier Name
@property (nonatomic, readonly, nullable) NSString *carrierName;

// Carrier Country
@property (nonatomic, readonly, nullable) NSString *carrierCountry;

// Carrier Mobile Country Code
@property (nonatomic, readonly, nullable) NSString *carrierMobileCountryCode;

// Carrier ISO Country Code
@property (nonatomic, readonly, nullable) NSString *carrierISOCountryCode;

// Carrier Mobile Network Code
@property (nonatomic, readonly, nullable) NSString *carrierMobileNetworkCode;

// Carrier Allows VOIP
@property (nonatomic, readonly) BOOL carrierAllowsVOIP;


/* Battery Information */
@property (nonatomic, readonly) float batteryLevel;

// Charging?
@property (nonatomic, readonly) BOOL charging;

// Fully Charged?
@property (nonatomic, readonly) BOOL fullyCharged;

/* Network Information */

// Get Current IP Address
@property (nonatomic, readonly, nullable) NSString *currentIPAddress;

// Get External IP Address
@property (nonatomic, readonly, nullable) NSString *externalIPAddress;

// Get Cell IP Address
@property (nonatomic, readonly, nullable) NSString *cellIPAddress;

// Get Cell Netmask Address
@property (nonatomic, readonly, nullable) NSString *cellNetmaskAddress;

// Get Cell Broadcast Address
@property (nonatomic, readonly, nullable) NSString *cellBroadcastAddress;

// Get WiFi IP Address
@property (nonatomic, readonly, nullable) NSString *wiFiIPAddress;

// Get WiFi Netmask Address
@property (nonatomic, readonly, nullable) NSString *wiFiNetmaskAddress;

// Get WiFi Broadcast Address
@property (nonatomic, readonly, nullable) NSString *wiFiBroadcastAddress;

// Get WiFi Router Address
@property (nonatomic, readonly, nullable) NSString *wiFiRouterAddress;

// Connected to WiFi?
@property (nonatomic, readonly) BOOL connectedToWiFi;

// Connected to Cellular Network?
@property (nonatomic, readonly) BOOL connectedToCellNetwork;


/* Disk Information */
@property (nonatomic, readonly, nullable) NSString *diskSpace;

// Total Free Disk Space (Raw)
@property (nonatomic, readonly, nullable) NSString *freeDiskSpaceinRaw;

// Total Free Disk Space (Percentage)
@property (nonatomic, readonly, nullable) NSString *freeDiskSpaceinPercent;

// Total Used Disk Space (Raw)
@property (nonatomic, readonly, nullable) NSString *usedDiskSpaceinRaw;

// Total Used Disk Space (Percentage)
@property (nonatomic, readonly, nullable) NSString *usedDiskSpaceinPercent;

// Get the total disk space in long format
@property (nonatomic, readonly) long long longDiskSpace;

// Get the total free disk space in long format
@property (nonatomic, readonly) long long longFreeDiskSpace;


/* Memory Information */
// Total Memory
@property (nonatomic, readonly) double totalMemory;

// Free Memory (Raw)
@property (nonatomic, readonly) double freeMemoryinRaw;

// Free Memory (Percent)
@property (nonatomic, readonly) double freeMemoryinPercent;

// Used Memory (Raw)
@property (nonatomic, readonly) double usedMemoryinRaw;

// Used Memory (Percent)
@property (nonatomic, readonly) double usedMemoryinPercent;

// Active Memory (Raw)
@property (nonatomic, readonly) double activeMemoryinRaw;

// Active Memory (Percent)
@property (nonatomic, readonly) double activeMemoryinPercent;

// Inactive Memory (Raw)
@property (nonatomic, readonly) double inactiveMemoryinRaw;

// Inactive Memory (Percent)
@property (nonatomic, readonly) double inactiveMemoryinPercent;

// Wired Memory (Raw)
@property (nonatomic, readonly) double wiredMemoryinRaw;

// Wired Memory (Percent)
@property (nonatomic, readonly) double wiredMemoryinPercent;

// Purgable Memory (Raw)
@property (nonatomic, readonly) double purgableMemoryinRaw;

// Purgable Memory (Percent)
@property (nonatomic, readonly) double purgableMemoryinPercent;


/* Localization Information */

// Country
@property (nonatomic, readonly, nullable) NSString *country;

// Language
@property (nonatomic, readonly, nullable) NSString *language;

// TimeZone
@property (nonatomic, readonly, nullable) NSString *timeZoneSS;

// Currency Symbol
@property (nonatomic, readonly, nullable) NSString *currency;


/* Application Information */

//app cup usage in percent
@property (nonatomic, readonly) float applicationCPUUsage;

//app memory usage in percent
@property (nonatomic, readonly) float applicationUsedMemory;

// Application Version
@property (nonatomic, readonly, nullable) NSString *applicationVersion;

+ (instancetype _Nonnull )sharedSystemInfo;

- (nullable NSArray <NESystemInfoModel *>*)getAllSystemInformation;
@end
