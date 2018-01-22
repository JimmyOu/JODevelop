//
//  JOPromise_impl_all.m
//  JODevelop
//
//  Created by JimmyOu on 2018/1/18.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "JOPromise_impl.h"

@interface allPromise:JOPromise

@property (nonatomic, strong) NSMutableSet <JOPromise *> *promises;
- (instancetype)initWithPromises:(NSArray<JOPromise *> *)promises;

@end

@implementation allPromise {
    NSMutableArray *_values;
}
- (instancetype)initWithPromises:(NSArray<JOPromise *> *)promises {
    self = [super init];
    _values = @[].mutableCopy;
    self.promises = [NSMutableSet set];
    self.state = PromiseStatePending;
    
    [self holdReference];
    [promises enumerateObjectsUsingBlock:^(JOPromise * promise, NSUInteger idx, BOOL * _Nonnull stop) {
        [promise addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
        if (promise.state == PromiseStatePending) {
            [self.promises addObject:promise];
        }
    }];
    __weak typeof(self) weakSelf = self;
    self.resolveBlock = ^(id value) {
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf.state != PromiseStatePending) return ;
        
        if ([value isKindOfClass:[JOPromise class]]) {
            
            if (((JOPromise *)value).state == PromiseStatePending) {
                strongSelf.promiseInstance = value;
                [(JOPromise *)value addObserver:strongSelf forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
            }
            else {
                [(JOPromise *)value addObserver:strongSelf forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
            }
        }
        else {
            strongSelf.value = value;
            strongSelf.state = PromiseStateResolved;
            [strongSelf releaseReference];
        }
    };
    
    self.rejectBlock = ^(NSError *error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if (strongSelf.state != PromiseStatePending) return;
        
        [strongSelf releaseReference];
        strongSelf.error = error;
        
        NSLog(@"%@-%@", strongSelf, [error description]);
        
        strongSelf.state = PromiseStateRejected;
    };
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"state"]) {
        JOPromiseState newState = (JOPromiseState)[change[NSKeyValueChangeNewKey] unsignedIntegerValue];
        [object removeObserver:self forKeyPath:@"state"];
        [self.promises removeObject:object];
        
        if (newState == PromiseStateRejected) {
            [self.promises enumerateObjectsUsingBlock:^(JOPromise *promise, BOOL *stop) {
                [promise removeObserver:self forKeyPath:@"state"];
            }];
            
            self.rejectBlock([(JOPromise *) object error]);
        }
        else if (newState == PromiseStateResolved) {
            [_values addObject:[(JOPromise *)object value]];
        }
        
        if (self.promises.count == 0) {
            self.resolveBlock(_values);
        }
    }
}
@end

@implementation JOPromise (all)
+ (instancetype)all:(NSArray<JOPromise *> *)promises {
    return [[allPromise alloc] initWithPromises:promises];
}
@end
