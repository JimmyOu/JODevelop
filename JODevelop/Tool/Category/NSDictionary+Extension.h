//
//  NSDictionary+Extension.h
//  模块化Demo
//
//  Created by JimmyOu on 17/3/14.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Extension)

- (nonnull NSString *)toJson;

- (BOOL)contains:(nonnull id)key;

@end
