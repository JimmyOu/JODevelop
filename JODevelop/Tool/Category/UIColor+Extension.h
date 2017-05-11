//
//  UIColor+Extension.h
//  模块化Demo
//
//  Created by JimmyOu on 17/3/21.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Extension)

+ (nonnull instancetype)colorWithHexString:(nonnull NSString *)hexString;
+ (nonnull instancetype)colorWithHexString:(nonnull NSString *)hexString alpha:(CGFloat)alpha;

+ (nonnull instancetype)randomColor;

@end
