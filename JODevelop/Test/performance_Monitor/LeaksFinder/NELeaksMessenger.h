//
//  NELeaksMessenger.h
//  TestApp
//
//  Created by JimmyOu on 2018/10/9.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NELeaksMessenger : NSObject

+ (void)alertWithTitle:(NSString *)title message:(NSString *)message;
+ (void)alertWithTitle:(NSString *)title
               message:(NSString *)message
              delegate:(id<UIAlertViewDelegate>)delegate
 additionalButtonTitle:(NSString *)additionalButtonTitle;

@end

NS_ASSUME_NONNULL_END
