//
//  UINavigationController+NEMemoryLeak.h
//  TestApp
//
//  Created by JimmyOu on 2018/10/9.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NELeaksFinder.h"
#if _INTERNAL_MLF_ENABLED
NS_ASSUME_NONNULL_BEGIN

@interface UINavigationController (NEMemoryLeak)

@end

NS_ASSUME_NONNULL_END
#endif
