//
//  JOMonitorUtils.h
//  JODevelop
//
//  Created by JimmyOu on 2018/8/7.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NEMonitorUtils : NSObject

+ (void)ne_swizzleSEL:(SEL)originalSEL withSEL:(SEL)swizzledSEL forClass:(Class)clz;
+ (NSString *)genCallStackReport;

@end
