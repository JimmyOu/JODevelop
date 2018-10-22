//
//  NESystemInfo.m
//  SnailReader
//
//  Created by JimmyOu on 2018/9/11.
//  Copyright © 2018年 com.netease. All rights reserved.
//

#import "NESystemInfo.h"
#import "NEHardware.h"
#import "NEJailbreakCheck.h"
#import "NECPUInfo.h"
#import "NEBatteryInfo.h"
#import "NENetworkInfo.h"
#import "NEDiskInfo.h"
#import "NEMemoryInfo.h"
#import "NELocalizationInfo.h"
#import "NECarrierInfo.h"
@implementation NESystemInfo

+ (instancetype)sharedSystemInfo {
    static dispatch_once_t onceToken;
    static NESystemInfo *info = nil;
    dispatch_once(&onceToken, ^{
        info = [[NESystemInfo alloc] init];
    });
    return info;
}
- (NSString *)systemsUptime {
    NSString *valid = [NEHardware systemUptime];
    if (valid == nil || valid.length <= 0) {
        // Invalid value
        valid = @"Unknown";
    }
    return valid;
}
- (NSString *)deviceName {
    NSString *valid = [NEHardware deviceName];
    if (valid == nil || valid.length <= 0) {
        // Invalid value
        valid = @"Unknown";
    }
    return valid;
}
- (NSString *)systemName {
    NSString *valid = [NEHardware systemName];
    if (valid == nil || valid.length <= 0) {
        // Invalid value
        valid = @"Unknown";
    }
    return valid;
}
- (NSString *)systemsVersion {
    NSString *valid = [NEHardware systemVersion];
    if (valid == nil || valid.length <= 0) {
        // Invalid value
        valid = @"Unknown";
    }
    return valid;
}
- (NSString *)systemDeviceType {
    NSString *valid = [NEHardware systemDeviceType];
    if (valid == nil || valid.length <= 0) {
        // Invalid value
        valid = @"Unknown";
    }
    return valid;
}
- (NSInteger)screenWidth {
    return [NEHardware screenWidth];
    
}
- (NSInteger)screenHeight {
    return [NEHardware screenHeight];
}
-(float)screenBrightness {
   return [NEHardware screenBrightness];
}
- (BOOL)debuggerAttached {
    return [NEHardware debugger];
}
-  (BOOL)jailbroken {
    return [NEJailbreakCheck jailbroken];
}
- (NSInteger)numberProcessors {
    return [NECPUInfo numberProcessors];
}
- (NSInteger)numberActiveProcessors {
    return [NECPUInfo numberActiveProcessors];
}
- (NSArray *)processorsUsage {
    return [NECPUInfo processorsUsage];
}

- (NSString *)carrierName {
    NSString *valid = [NECarrierInfo carrierName];
    if (valid == nil || valid.length <= 0) {
        // Invalid value
        valid = @"Unknown";
    }
    return valid;
}

- (NSString *)carrierCountry {
    NSString *valid = [NECarrierInfo carrierCountry];
    if (valid == nil || valid.length <= 0) {
        // Invalid value
        valid = @"Unknown";
    }
    return valid;
}

- (NSString *)carrierMobileCountryCode {
    NSString *valid = [NECarrierInfo carrierMobileCountryCode];
    if (valid == nil || valid.length <= 0) {
        // Invalid value
        valid = @"Unknown";
    }
    return valid;
}

- (NSString *)carrierISOCountryCode {
    NSString *valid = [NECarrierInfo carrierISOCountryCode];
    if (valid == nil || valid.length <= 0) {
        // Invalid value
        valid = @"Unknown";
    }
    return valid;
}

- (NSString *)carrierMobileNetworkCode {
    NSString *valid = [NECarrierInfo carrierMobileNetworkCode];
    if (valid == nil || valid.length <= 0) {
        // Invalid value
        valid = @"Unknown";
    }
    return valid;
}

- (BOOL)carrierAllowsVOIP {
    return [NECarrierInfo carrierAllowsVOIP];
}

- (float)batteryLevel {
    return [NEBatteryInfo batteryLevel];
}
- (BOOL)charging {
    return [NEBatteryInfo charging];
}

- (BOOL)fullyCharged {
    return [NEBatteryInfo fullyCharged];
}


- (NSString *)currentIPAddress {
    NSString *valid = [NENetworkInfo currentIPAddress];
    if (valid == nil || valid.length <= 0) {
        // Invalid value
        valid = @"Unknown";
    }
    return valid;
}
- (NSString *)externalIPAddress {
    NSString *valid = [NENetworkInfo externalIPAddress];
    if (valid == nil || valid.length <= 0) {
        // Invalid value
        valid = @"Unknown";
    }
    return valid;
}
- (NSString *)cellIPAddress {
    NSString *valid = [NENetworkInfo cellIPAddress];
    if (valid == nil || valid.length <= 0) {
        // Invalid value
        valid = @"Unknown";
    }
    return valid;
}

- (NSString *)cellNetmaskAddress {
    NSString *valid = [NENetworkInfo cellNetmaskAddress];
    if (valid == nil || valid.length <= 0) {
        // Invalid value
        valid = @"Unknown";
    }
    return valid;
}
- (NSString *)cellBroadcastAddress {
    NSString *valid = [NENetworkInfo cellBroadcastAddress];
    if (valid == nil || valid.length <= 0) {
        // Invalid value
        valid = @"Unknown";
    }
    return valid;
}
- (NSString *)wiFiIPAddress {
    NSString *valid = [NENetworkInfo wiFiIPAddress];
    if (valid == nil || valid.length <= 0) {
        // Invalid value
        valid = @"Unknown";
    }
    return valid;
}
- (NSString *)wiFiNetmaskAddress {
    NSString *valid = [NENetworkInfo wiFiNetmaskAddress];
    if (valid == nil || valid.length <= 0) {
        // Invalid value
        valid = @"Unknown";
    }
    return valid;
}
-(NSString *)wiFiBroadcastAddress {
    NSString *valid = [NENetworkInfo wiFiBroadcastAddress];
    if (valid == nil || valid.length <= 0) {
        // Invalid value
        valid = @"Unknown";
    }
    return valid;
}
- (NSString *)wiFiRouterAddress {
    NSString *valid = [NENetworkInfo wiFiRouterAddress];
    if (valid == nil || valid.length <= 0) {
        // Invalid value
        valid = @"Unknown";
    }
    return valid;
}

- (BOOL)connectedToWiFi {
    return [NENetworkInfo connectedToWiFi];
}
- (BOOL)connectedToCellNetwork {
    return [NENetworkInfo connectedToCellNetwork];
}

- (NSString *)diskSpace {
    NSString *valid = [NEDiskInfo diskSpace];
    if (valid == nil || valid.length <= 0) {
        // Invalid value
        valid = @"Unknown";
    }
    return valid;
}
- (NSString *)freeDiskSpaceinRaw {
    NSString *valid = [NEDiskInfo freeDiskSpace:NO];
    if (valid == nil || valid.length <= 0) {
        // Invalid value
        valid = @"Unknown";
    }
    return valid;
}
- (NSString *)freeDiskSpaceinPercent {
    NSString *valid = [NEDiskInfo freeDiskSpace:YES];
    if (valid == nil || valid.length <= 0) {
        // Invalid value
        valid = @"Unknown";
    }
    return valid;
}
- (NSString *)usedDiskSpaceinRaw {
    NSString *valid = [NEDiskInfo usedDiskSpace:NO];
    if (valid == nil || valid.length <= 0) {
        // Invalid value
        valid = @"Unknown";
    }
    return valid;
}
- (NSString *)usedDiskSpaceinPercent {
    NSString *valid = [NEDiskInfo usedDiskSpace:YES];
    if (valid == nil || valid.length <= 0) {
        // Invalid value
        valid = @"Unknown";
    }
    return valid;
}
- (long long)longDiskSpace {
    return [NEDiskInfo longDiskSpace];
}
- (long long)longFreeDiskSpace {
    return [NEDiskInfo longFreeDiskSpace];
}
- (double)totalMemory {
    return [NEMemoryInfo totalMemory];
}

- (double)freeMemoryinRaw {
    return [NEMemoryInfo freeMemory:NO];
}

- (double)freeMemoryinPercent {
    return [NEMemoryInfo freeMemory:YES];
}

- (double)usedMemoryinRaw {
    return [NEMemoryInfo usedMemory:NO];
}

- (double)usedMemoryinPercent {
    return [NEMemoryInfo usedMemory:YES];
}

- (double)activeMemoryinRaw {
    return [NEMemoryInfo activeMemory:NO];
}

- (double)activeMemoryinPercent {
    return [NEMemoryInfo activeMemory:YES];
}

- (double)inactiveMemoryinRaw {
    return [NEMemoryInfo inactiveMemory:NO];
}

- (double)inactiveMemoryinPercent {
    return [NEMemoryInfo inactiveMemory:YES];
}

- (double)wiredMemoryinRaw {
    return [NEMemoryInfo wiredMemory:NO];
}

- (double)wiredMemoryinPercent {
    return [NEMemoryInfo wiredMemory:YES];
}

- (double)purgableMemoryinRaw {
    return [NEMemoryInfo purgableMemory:NO];
}

- (double)purgableMemoryinPercent {
    return [NEMemoryInfo purgableMemory:YES];
}


- (NSString *)country {
    NSString *valid = [NELocalizationInfo country];
    if (valid == nil || valid.length <= 0) {
        // Invalid value
        valid = @"Unknown";
    }
    return valid;
}

- (NSString *)language {
    NSString *valid = [NELocalizationInfo language];
    if (valid == nil || valid.length <= 0) {
        // Invalid value
        valid = @"Unknown";
    }
    return valid;
}

- (NSString *)timeZoneSS {
    NSString *valid = [NELocalizationInfo timeZone];
    if (valid == nil || valid.length <= 0) {
        // Invalid value
        valid = @"Unknown";
    }
    return valid;
}

- (NSString *)currency {
    NSString *valid = [NELocalizationInfo currency];
    if (valid == nil || valid.length <= 0) {
        // Invalid value
        valid = @"Unknown";
    }
    return valid;
}

- (NSString *)applicationVersion {
    // Get the Application Version Number
    @try {
        
        // Query the plist for the version
        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        
        // Validate the Version
        if (version == nil || version.length <= 0) {
            // Invalid Version number
            return nil;
        }
        // Successful
        return version;
    }
    @catch (NSException *exception) {
        // Error
        return nil;
    }
}

- (float)applicationCPUUsage {
    return [NECPUInfo appCpuUsage];
}

- (float)applicationUsedMemory {
    return [NEMemoryInfo getAppUsedMemory];
}

- (NSArray<NESystemInfoModel *> *)getAllSystemInformation {
    NSMutableArray *systemInformationArray = [NSMutableArray array];
    
    // Set up all System Values
    
    /* Application Information */
    NSString *applicationVersion = [self applicationVersion];
    NSString *cPUUsage = [NSString stringWithFormat:@"%.f%%", [self applicationCPUUsage]];
    NSString *appUsageMemory = [NSString stringWithFormat:@"%.1fM", [self applicationUsedMemory]];
    NSString *batteryLevel = [NSString stringWithFormat:@"%f", [self batteryLevel]];
    
    NSArray *values = @[applicationVersion,cPUUsage,appUsageMemory,batteryLevel];
    NSArray *keys = @[@"applicationVersion",@"cPUUsage",@"appUsageMemory", @"batteryLevel"];
    NESystemInfoModel *applicationModel = [[NESystemInfoModel alloc] initWithObjects:values keys:keys groupName:@"Application Information"];
    [systemInformationArray addObject:applicationModel];
    
    /* Hardware Information */
    NSString *systemUptime = [self systemsUptime];
    NSArray *uptimeFormat = [systemUptime componentsSeparatedByString:@" "];
    if (uptimeFormat.count > 0) {
        systemUptime = [NSString stringWithFormat:@"System Uptime: %@ Days %@ Hours %@ Minutes", [uptimeFormat objectAtIndex:0], [uptimeFormat objectAtIndex:1], [uptimeFormat objectAtIndex:2]];
    }
    
    NSString *deviceName = [self deviceName];
   NSString *systemName = [NSString stringWithFormat:@"%@ %@",[self systemName], [self systemsVersion]];
    NSString *systemDeviceType = [self systemDeviceType];
    NSString *screenWidth = [NSString stringWithFormat:@"%ld", (long)[self screenWidth]];
    NSString *screenHeight = [NSString stringWithFormat:@"%ld", (long)[self screenHeight]];
    NSString *screenBrightness = [NSString stringWithFormat:@"%.f%%", [self screenBrightness]];
    NSString *debuggerAttached = ([self debuggerAttached]) ? @"Yes" : @"No";
    NSString *jailbroken = ([self jailbroken]) ? @"Yes" : @"No";
    
    values = @[systemUptime,deviceName,systemName,systemDeviceType,screenWidth,screenHeight,screenBrightness,debuggerAttached,jailbroken];
    keys = @[@"systemUptime",@"deviceName",@"systemName",@"systemDeviceType",@"screenWidth",@"screenHeight",@"screenBrightness",@"debuggerAttached",@"jailbroken"];;
    NESystemInfoModel *hardwareModel = [[NESystemInfoModel alloc] initWithObjects:values keys:keys groupName:@"Hardware Information"];
    [systemInformationArray addObject:hardwareModel];
    
    /* Processor Information */
    NSString *numberProcessors = [NSString stringWithFormat:@"%ld", (long)[self numberProcessors]];
    NSString *numberActiveProcessors = [NSString stringWithFormat:@"%ld", (long)[self numberActiveProcessors]];
    NSMutableString *formateUsageStr = [NSMutableString string];
    NSArray *processorsUsage = [self processorsUsage];
    for (NSNumber *usage in processorsUsage) {
        [formateUsageStr appendString:[NSString stringWithFormat:@"%.1f%% ,",[usage floatValue] * 100]];
    }
    
    values = @[numberProcessors,numberActiveProcessors,formateUsageStr];
    keys = @[@"numberProcessors",@"numberActiveProcessors",@"processorsUsage"];
    
    NESystemInfoModel *processorsModel = [[NESystemInfoModel alloc] initWithObjects:values keys:keys groupName:@"Processor Information"];
    [systemInformationArray addObject:processorsModel];
    
    /* Carrier Information */
    NSString *carrierName = [self carrierName];
    NSString *carrierCountry = [self carrierCountry];
    NSString *carrierMobileCountryCode = [self carrierMobileCountryCode];
    NSString *carrierISOCountryCode = [self carrierISOCountryCode];
    NSString *carrierMobileNetworkCode = [self carrierMobileNetworkCode];
    NSString *carrierAllowsVOIP = ([self carrierAllowsVOIP]) ? @"Yes" : @"No";
    
    
    values = @[carrierName,carrierCountry,carrierMobileCountryCode,carrierISOCountryCode,carrierMobileNetworkCode,carrierAllowsVOIP];
    keys = @[@"carrierName",@"carrierCountry",@"carrierMobileCountryCode",@"carrierISOCountryCode",@"carrierMobileNetworkCode",@"carrierAllowsVOIP"];
    NESystemInfoModel *carrierModel = [[NESystemInfoModel alloc] initWithObjects:values keys:keys groupName:@"Carrier Information"];
    [systemInformationArray addObject:carrierModel];
    
    /* Battery Information */
    
    NSString *charging = ([self charging]) ? @"Yes" : @"No";
    NSString *fullyCharged = ([self fullyCharged]) ? @"Yes" : @"No";
    
    values = @[batteryLevel,charging,fullyCharged];
    keys = @[@"batteryLevel",@"charging",@"fullyCharged"];
    NESystemInfoModel *batteryModel = [[NESystemInfoModel alloc] initWithObjects:values keys:keys groupName:@"Battery Information"];
    [systemInformationArray addObject:batteryModel];
    
    /* Network Information */
    NSString *currentIPAddress = [self currentIPAddress];
    NSString *externalIPAddress = [self externalIPAddress];
    NSString *cellIPAddress = [self cellIPAddress];
    NSString *cellNetmaskAddress = [self cellNetmaskAddress];
    NSString *cellBroadcastAddress = [self cellBroadcastAddress];
    NSString *wiFiIPAddress = [self wiFiIPAddress];
    NSString *wiFiNetmaskAddress = [self wiFiNetmaskAddress];
    NSString *wiFiBroadcastAddress = [self wiFiBroadcastAddress];
    NSString *wiFiRouterAddress = [self wiFiRouterAddress];
    NSString *connectedToWiFi = ([self connectedToWiFi]) ? @"Yes" : @"No";
    NSString *connectedToCellNetwork = ([self connectedToCellNetwork]) ? @"Yes" : @"No";
    
    
    values = @[currentIPAddress,externalIPAddress,cellIPAddress,cellNetmaskAddress, cellBroadcastAddress, wiFiIPAddress, wiFiNetmaskAddress, wiFiBroadcastAddress, wiFiRouterAddress, connectedToWiFi, connectedToCellNetwork];
    keys = @[@"currentIPAddress",@"externalIPAddress",@"cellIPAddress",@"cellNetmaskAddress", @"cellBroadcastAddress", @"wiFiIPAddress", @"wiFiNetmaskAddress", @"wiFiBroadcastAddress", @"wiFiRouterAddress", @"connectedToWiFi", @"connectedToCellNetwork"];

    NESystemInfoModel *networkModel = [[NESystemInfoModel alloc] initWithObjects:values keys:keys groupName:@"Network Information"];
    [systemInformationArray addObject:networkModel];
    
    /* Disk Information */
    NSString *diskSpace = [self diskSpace];
    NSString *freeDiskSpace = [NSString stringWithFormat:@"%@ %@",[self freeDiskSpaceinRaw], [self freeDiskSpaceinPercent]];
    NSString *usedDiskSpace = [NSString stringWithFormat:@"%@ %@",[self usedDiskSpaceinRaw], [self usedDiskSpaceinPercent]];
    
    
    values = @[diskSpace,freeDiskSpace, usedDiskSpace];
    keys = @[@"diskSpace",@"freeDiskSpace",@"usedDiskSpace"];
    NESystemInfoModel *diskModel = [[NESystemInfoModel alloc] initWithObjects:values keys:keys groupName:@"Disk Information"];
    [systemInformationArray addObject:diskModel];
    
    /* Memory Information */
    NSString *totalMemory = [NSString stringWithFormat:@"%.fM", [self totalMemory]];
    NSString *freeMemory = [NSString stringWithFormat:@"%.fM %.f%%",[self freeMemoryinRaw],[self freeMemoryinPercent]];
    NSString *usedMemory = [NSString stringWithFormat:@"%.fM %.f%%",[self usedMemoryinRaw],[self usedMemoryinPercent]];
    NSString *activeMemory = [NSString stringWithFormat:@"%.fM %.f%%",[self activeMemoryinRaw],[self activeMemoryinPercent]];
    NSString *inactiveMemory = [NSString stringWithFormat:@"%.fM %.f%%",[self inactiveMemoryinRaw],[self inactiveMemoryinPercent]];
    NSString *wiredMemory = [NSString stringWithFormat:@"%.fM %.f%%",[self wiredMemoryinRaw],[self wiredMemoryinPercent]];
    NSString *purgableMemory = [NSString stringWithFormat:@"%.fM %.f%%",[self purgableMemoryinRaw],[self purgableMemoryinPercent]];
    
    values = @[totalMemory,freeMemory,usedMemory,activeMemory, inactiveMemory,wiredMemory, purgableMemory];
    keys = @[@"totalMemory",@"freeMemory",@"usedMemory",@"activeMemory", @"inactiveMemory",@"wiredMemory", @"purgableMemory"];
    NESystemInfoModel *memoryModel = [[NESystemInfoModel alloc] initWithObjects:values keys:keys groupName:@"Memory Information"];
    [systemInformationArray addObject:memoryModel];
    
    /* Localization Information */
    NSString *country = [self country];
    NSString *language = [self language];
    NSString *timeZone = [self timeZoneSS];
    NSString *currency = [self currency];
    
    values = @[country,language,timeZone,currency];
    keys = @[@"country",@"language",@"timeZone",@"currency"];

    NESystemInfoModel *locationModel = [[NESystemInfoModel alloc] initWithObjects:values keys:keys groupName:@"Localization Information"];
    [systemInformationArray addObject:locationModel];
    
    
    if (systemInformationArray.count <= 0) {
        // Error, is empty
        return nil;
    }
    return systemInformationArray;
}



@end
