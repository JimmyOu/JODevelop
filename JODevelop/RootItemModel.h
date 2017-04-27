//
//  RootItemModel.h
//  JODevelop
//
//  Created by JimmyOu on 17/4/13.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RootItemModel : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *vc;

- (instancetype)initWithDict:(NSDictionary *)dic;
+ (instancetype)itemWithDict:(NSDictionary *)dic;

@end
