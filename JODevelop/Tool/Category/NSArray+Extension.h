//
//  NSArray+Extension.h
//  JOFoundation
//
//  Created by JimmyOu on 16/11/9.
//  Copyright © 2016年 JimmyOu. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@interface NSArray (Extension)

- (nullable id)safeObjectAtIndex:(NSUInteger)index;
- (NSString *)toJson;

@end

@interface NSMutableArray (Extension)

- (void)safeAddObject:(id)obj;

@end
NS_ASSUME_NONNULL_END
