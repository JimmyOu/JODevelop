//
//  _interface_login.h
//  JOFoundation
//
//  Created by JimmyOu on 17/2/23.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface _interface_login : NSObject

/*       动态调用     */

//1.无返回值有参数
- (void)dologin:(nullable void(^)(NSInteger result))callBack;

//2.有返回值有参数
- (nonnull id)dobussiness:(nullable void(^)(NSInteger result))callBack;

//3.无返回值无参数
- (void)dobussiness;

- (void)dosomething:(nonnull NSString *)other;



/*       URL调用     */

- (void)_remote_dologin;
- (void)_remote_dologin:(nonnull NSString *)str;
- (nonnull id)_remote_dologin_protocol:(nonnull NSString *)str;

@end
