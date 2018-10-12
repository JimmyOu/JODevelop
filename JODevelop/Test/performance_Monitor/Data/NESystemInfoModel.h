//
//  NESystemInfo.h
//  SnailReader
//
//  Created by JimmyOu on 2018/9/17.
//  Copyright © 2018年 com.netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NESystemInfoItem: NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *value;
+ (instancetype)itemWithTitle:(NSString *)title value:(NSString *)value;
@end

@interface NESystemInfoModel : NSObject

@property (nonatomic, copy) NSString *groupName;
@property (strong, nonatomic) NSArray<NESystemInfoItem *> *items;

- (instancetype)initWithObjects:(NSArray< NSString *> *)objects keys:(NSArray<NSString *> *)keys groupName:(NSString *)groupName;

@end
