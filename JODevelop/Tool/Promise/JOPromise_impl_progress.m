//
//  JOPromise_impl_progress.m
//  JODevelop
//
//  Created by JimmyOu on 2018/1/18.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//


#import "JOPromise_impl.h"

@implementation JOProgressPromise

+ (instancetype)promise:(handlerProgressPromise)block
{
    JOProgressPromise *progressPromise = [[JOProgressPromise alloc] init];
    
    __weak JOProgressPromise *weakPromise = progressPromise;
    
    [progressPromise promiseInitialize];
    
    [progressPromise setProgressHandler:^(double progress, id value) {
        weakPromise.progressBlock(progress, value);
    }];
    
    progressPromise.promiseBlock = ^(handlerResolve resolve, handlerReject reject) {
        block(resolve, reject, weakPromise.progressHandler);
    };
    
    [progressPromise excute];
    
    return progressPromise;
}

- (JOPromise *(^)(handlerProgress))progress
{
    __weak __typeof(self)weakSelf = self;
    
    return ^JOPromise *(handlerProgress progressBlock) {
        weakSelf.progressBlock = progressBlock;
        return weakSelf;
    };
}

- (void)setProgressHandler:(handlerProgress)progressHandler
{
    _progressHandler = progressHandler;
}

- (void)progress:(double)progress value:(id)value
{
    self.progressHandler(progress, value);
}

@end

