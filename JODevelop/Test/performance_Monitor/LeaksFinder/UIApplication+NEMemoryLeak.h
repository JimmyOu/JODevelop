//
//  UIApplication+NEMemoryLeak.h
//  TestApp
//
//  Created by JimmyOu on 2018/10/9.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NELeaksFinder.h"
NS_ASSUME_NONNULL_BEGIN

#if _INTERNAL_MLF_ENABLED
@interface UIApplication (NEMemoryLeak)

@end
#endif

NS_ASSUME_NONNULL_END
