//
//  SRMenuItemsLabel.h
//  SnailReader
//
//  Created by JimmyOu on 2018/2/2.
//  Copyright © 2018年 com.netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#pragma clang assume_nonnull begin

@interface SRMenuItemsLabel : UILabel

@property (readonly,nullable) NSArray <UIMenuItem *>*items;

- (void)addMenuItemWithTitle:(nonnull NSString *)title clickBlock:(void (^_Nullable)(NSString * _Nullable text))block;

@end
#pragma clang assume_nonnull end


