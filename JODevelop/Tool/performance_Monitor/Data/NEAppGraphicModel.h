//
//  NEAppGraphicModel.h
//  SnailReader
//
//  Created by JimmyOu on 2018/10/9.
//  Copyright © 2018年 com.netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NEAppGraphicModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (readonly) NSArray *times;
@property (readonly) NSArray *values;

- (void)addTime:(NSString *)time value:(NSNumber *)value;
- (void)clearAllData;

@end

NS_ASSUME_NONNULL_END
