//
//  JOPromise_impl.h
//  JODevelop
//
//  Created by JimmyOu on 2018/1/16.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "JOPromise.h"
#import "NSError+JOPromise.h"

typedef NS_ENUM(NSUInteger, JOPromiseState) {
    PromiseStatePending = 0,
    PromiseStateResolved,
    PromiseStateRejected,
};

@protocol promiseThen<NSObject>
@property (nonatomic) handlerPromise then;
@end

@interface JOPromise()
@property (nonatomic, strong) id value;
@property (nonatomic, strong) NSError *error;
@property (atomic, assign) JOPromiseState state;
@property (nonatomic, strong) id strongSelf;
@property (nonatomic, strong) JOPromise *promiseInstance;
@property (nonatomic, copy) handlerResolve resolveBlock;
@property (nonatomic, copy) handlerReject rejectBlock;
@property (nonatomic, copy) handlerPromise promiseBlock;
@property (nonatomic, copy) handlerReject catchBlock;
@property (nonatomic, copy) handlerRun thenBlock;
@property (nonatomic, strong) id valueForRetry;

+ (instancetype)timer:(NSTimeInterval)secounds;
- (instancetype)init:(handlerPromise)handler;
- (void)promiseInitialize;
- (void)holdReference;
- (void)releaseReference;
- (void)excute;

@end

@interface JOProgressPromise()

@property (nonatomic, copy) handlerProgress progressBlock;

- (void)setProgressHandler:(handlerProgress)progressHandler;
@end
