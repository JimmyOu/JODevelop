//
//  AXDRouter.h
//  JOFoundation
//
//  Created by JimmyOu on 17/2/23.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AXDRouter : NSObject

+ (nonnull instancetype)sharedInstance;

- (BOOL)handel_application_openurl:(nonnull UIApplication *)application
                           openurl:(nonnull NSURL *)url
                 sourceapplication:(nullable NSString *)sourceapplication
                        annotation:(nonnull id)annotation;

- (BOOL)handel_application_openurl:(nonnull UIApplication *)application
                           openurl:(nonnull NSURL *)url
                           options:(nonnull NSDictionary<NSString *,id> *)options;

//通过runtime动态调用方法
+ (nullable id)dispatchInvokes:(nonnull NSString *)target action:(nullable NSString *)action error:(NSError * _Nullable __autoreleasing * _Nullable)error, ...;

//通过URL协议打开一个业务
+ (nullable id)dispatchInvokesWithUrl:(nonnull NSString *)url;

@end
