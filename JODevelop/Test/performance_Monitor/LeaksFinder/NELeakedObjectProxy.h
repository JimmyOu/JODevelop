//
//  NELeakedObjectProxy.h
//  TestApp
//
//  Created by JimmyOu on 2018/10/9.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NELeakedObjectProxy : NSObject

+ (BOOL)isAnyObjectLeakedAtPtrs:(NSSet *)ptrs;
+ (void)addLeakedObject:(id)object;

@end

NS_ASSUME_NONNULL_END
