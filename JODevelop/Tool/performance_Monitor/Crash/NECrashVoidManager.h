//
//  NECrashVoid.h
//  SnailReader
//
//  Created by JimmyOu on 2018/8/31.
//  Copyright © 2018年 com.netease. All rights reserved.
//

#import <Foundation/Foundation.h>

/* 可预防的崩溃有。
 
 */

@interface NECrashVoidManager : NSObject

+ (void)swizzle;

@end
