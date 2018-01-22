//
//  JOPromise_impl_after.m
//  JODevelop
//
//  Created by JimmyOu on 2018/1/16.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "JOPromise_impl.h"

@interface afterPromise: JOPromise
@end

@implementation afterPromise
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"state"]) {
        JOPromiseState newState = (JOPromiseState)[change[NSKeyValueChangeNewKey] unsignedIntegerValue];
        if (newState == PromiseStateRejected) {
            [object removeObserver:self forKeyPath:@"state"];
            self.rejectBlock([(JOPromise *)object error]);
        }
        else if (newState == PromiseStateResolved) {
            [object removeObserver:self forKeyPath:@"state"];
            self.value = [(JOPromise *)object value];
            
            @try {
                if (self.thenBlock) {
                    self.thenBlock([(JOPromise *) object value]);
                }
            } @catch (NSException *e) {
                self.rejectBlock([NSError errorWithException:e]);
            }
        }
        
    }
}
@end

@implementation JOPromise (after)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-unsafe-retained-assign"
- (JOPromise *(^)(NSTimeInterval))after {
    __weak typeof(self) weakSelf = self;
    
    return ^JOPromise *(NSTimeInterval seconds) {
        __weak JOPromise *newPromise = nil;
        newPromise = [[afterPromise alloc] init:^(handlerResolve resolve, handlerReject reject) {
            resolve(weakSelf);
        }];
        newPromise.thenBlock = ^id(id value) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                newPromise.resolveBlock(newPromise.value);
            });
            return @{@"Timeup" : @(seconds)};
        };
        
        return newPromise;
    };
}
#pragma clang diagnostic pop
@end

