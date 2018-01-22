//
//  JOPromise.m
//  JODevelop
//
//  Created by JimmyOu on 2018/1/16.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "JOPromise.h"
#import "JOPromise_impl.h"

@implementation JOPromise

+ (instancetype)promise:(handlerPromise)handler {
    return [[JOPromise alloc] init:handler];
}

+ (instancetype)resolve:(id)value {
    if ([value isKindOfClass:[JOPromise class]]) {
        return value;
    }
    else if ([value conformsToProtocol:@protocol(promiseThen)]) {
        return [JOPromise promise:^(handlerResolve resolve, handlerReject reject) {
            id<promiseThen> thenObj = (id<promiseThen>)value;
            thenObj.then(resolve, reject);
        }];
    }
    else {
        return [JOPromise promise:^(handlerResolve resolve, handlerReject reject) {
            resolve(value);
        }];
    }
}
+ (instancetype)reject:(id)value {
    if ([value isKindOfClass:[JOPromise class]]) {
        return value;
    }
    else {
        return [JOPromise promise:^(handlerResolve resolve, handlerReject reject) {
            reject([NSError errorWithValue:value]);
        }];
    }
}
+ (instancetype)timer:(NSTimeInterval)secounds {
    return [JOPromise promise:^(handlerResolve resolve, handlerReject reject) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(secounds * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            resolve(@{@"Timeout":@(secounds)});
        });
    }];
}
- (void)resolve:(id)value {
    self.resolveBlock(value);
}
- (void)reject:(NSError *)error {
    self.rejectBlock(error);
}

#pragma mark - 内部实现
- (instancetype)init:(handlerPromise)handler {
    self = [super init];
    if (self) {
        [self promiseInitialize];
        self.promiseBlock = handler;
    }
    [self excute];
    return self;
}

- (void)promiseInitialize {
    self.state = PromiseStatePending;
    [self holdReference];
    
    /*  初始化 resolveBlock*/
    __weak typeof(self) weakSelf = self;
    self.resolveBlock = ^(id value) {
        __strong typeof(self) strongSelf = weakSelf;
        
        if (strongSelf.state != PromiseStatePending) return;
        
        if ([value isKindOfClass:[JOPromise class]]) {
            if (((JOPromise *)value).state == PromiseStatePending) {
                strongSelf.promiseInstance = value;
            }
            
            [(JOPromise *)value addObserver:strongSelf forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
        }
        else {
            strongSelf.value = value;
            strongSelf.state = PromiseStateResolved;
            [strongSelf releaseReference];
        }
    };
    
    /*  初始化 rejectBlock*/
    self.rejectBlock = ^(NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf.state != PromiseStatePending) return;
        
        [strongSelf releaseReference];
        strongSelf.error = error;
        strongSelf.state = PromiseStateRejected;
    };
}
- (void)holdReference {
    self.strongSelf = self;
}
- (void)releaseReference {
    self.strongSelf = nil;
}
- (void)dealloc {
    self.promiseInstance = nil;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"state"]) {
        JOPromiseState newState = (JOPromiseState)[change[NSKeyValueChangeNewKey] unsignedIntegerValue];
        if (newState == PromiseStateRejected) {
            [object removeObserver:self forKeyPath:@"state"];
            if (self.catchBlock) {
                self.catchBlock([(JOPromise *)object error]);
                self.resolveBlock(nil);
            } else {
                self.rejectBlock([(JOPromise *)object error]);
            }
        } else if (newState == PromiseStateResolved) {
            [object removeObserver:self forKeyPath:@"state"];
            @try {
                id value = nil;
                self.valueForRetry = [(JOPromise *)object value];
                if (self.thenBlock) {
                    value = self.thenBlock([(JOPromise *)object value]);
                } else {
                    value = [(JOPromise *)object value];
                }
                self.thenBlock = nil;
                self.resolveBlock(value);
            } @catch (NSException *exception) {
                self.rejectBlock([NSError errorWithException:exception]);
            }
            
        }
    }
}

- (void)excute {
    if (self.promiseBlock) {
        @try {
            self.promiseBlock(self.resolveBlock, self.rejectBlock);
        } @catch (NSException *exception) {
            self.rejectBlock([NSError errorWithException:exception]);
        }
    }
}
@end
