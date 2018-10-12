//
//  NEAccessoryInfo.h
//  SnailReader
//
//  Created by JimmyOu on 2018/9/11.
//  Copyright © 2018年 com.netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NEAccessoryInfo : NSObject
// Are any accessories attached?
+ (BOOL)accessoriesAttached;

// Are headphone attached?
+ (BOOL)headphonesAttached;

// Number of attached accessories
+ (NSInteger)numberAttachedAccessories;

// Name of attached accessory/accessories (seperated by , comma's)
+ (nullable NSString *)nameAttachedAccessories;
@end
