//
//  NEHTTPModelManager.h
//  SnailReader
//
//  Created by JimmyOu on 2018/8/20.
//  Copyright © 2018年 com.netease. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NEHTTPModel;

@interface NEHTTPModelManager : NSObject
@property (readonly) NSMutableArray *netModels;

- (void)addModel:(NEHTTPModel *)model;
+ (instancetype)sharedInstance;

@end
