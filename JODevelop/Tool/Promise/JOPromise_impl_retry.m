//
//  JOPromise_impl_retry.m
//  JODevelop
//
//  Created by JimmyOu on 2018/1/18.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "JOPromise_impl.h"

@interface retryPromise : JOPromise

@end

@implementation retryPromise

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"state"]) {
        JOPromiseState newState = (JOPromiseState)[change[NSKeyValueChangeNewKey] unsignedIntegerValue];
        
        if (newState == PromiseStateRejected) {
            [object removeObserver:self forKeyPath:@"state"];
            if (self.catchBlock) {
                self.catchBlock([(JOPromise *)object error]);
            }
            else {
                self.rejectBlock([(JOPromise *)object error]);
            }
        }
        else if (newState == PromiseStateResolved) {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
}

@end

@implementation JOPromise (retry)

- (JOPromise *(^)(NSUInteger))retry
{
    __weak __typeof(self)weakSelf = self;
    
    return ^JOPromise *(NSUInteger retryCount) {
        JOPromise *newPromise = nil;
        
        newPromise = [[retryPromise alloc] init:^(handlerResolve resolve, handlerReject reject) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            resolve(strongSelf);
        }];
        
        BOOL thenBlock = NO;
        id block = self.promiseBlock;
        
        if (self.thenBlock != nil) {
            block     = self.thenBlock;
            thenBlock = YES;
        }
        
        __weak JOPromise *weakPromise = newPromise;
        
        newPromise.catchBlock = ^(NSError *e){
            static NSUInteger retried = 0;
            if (retried++ < retryCount){
                if (thenBlock) {
                    @autoreleasepool {
                        __weak JOPromise *retryPromise = nil;
                        
                        retryPromise = [JOPromise promise:^(handlerResolve resolve, handlerReject reject) {
                            @try {
                                id v = ((handlerRun)block)(weakSelf.valueForRetry);
                                resolve(v);
                            } @catch (NSException *exception) {
                                reject([NSError errorWithException:exception]);
                            }
                        }];
                        weakPromise.resolveBlock(retryPromise);
                    }
                }
                else {
                    JOPromise *retryPromise = nil;
                    retryPromise = [JOPromise promise:block];
                    weakPromise.resolveBlock(retryPromise);
                }
            }
            else {
                weakPromise.rejectBlock(e);
            }
        };
        
        return newPromise;
    };
}

@end

