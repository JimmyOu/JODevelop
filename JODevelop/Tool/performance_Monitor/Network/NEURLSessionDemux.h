//
//  NEURLSessionDemux.h
//  SnailReader
//
//  Created by JimmyOu on 2018/12/21.
//  Copyright © 2018 com.netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NEURLSessionDemux : NSObject

@property (atomic, copy,   readonly ) NSURLSessionConfiguration *configuration;
@property (atomic, strong, readonly ) NSURLSession *session;

- (instancetype)initWithConfiguration:(nullable NSURLSessionConfiguration *)configuration;

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request delegate:(id<NSURLSessionDataDelegate>)delegate modes:(NSArray *)modes;


@end

NS_ASSUME_NONNULL_END
