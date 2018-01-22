//
//  JOPromise_impl_race.m
//  JODevelop
//
//  Created by JimmyOu on 2018/1/18.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "JOPromise_impl.h"
@interface racePromise : JOPromise

@property (nonatomic, strong) NSMutableSet<JOPromise *> *promises;

- (instancetype)initWithPromises:(NSArray<JOPromise *> *)promises;

@end

@implementation racePromise {
    NSMutableArray *_values;
}

- (instancetype)initWithPromises:(NSArray<JOPromise *> *)promises
{
    self = [super init];
    
    self.promises = [NSMutableSet set];
    _values       = @[].mutableCopy;
    
    self.state = PromiseStatePending;
    [self holdReference];
    
    [promises enumerateObjectsUsingBlock:^(JOPromise *promise, NSUInteger idx, BOOL *stop) {
        [promise addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
        
        if (promise.state == PromiseStatePending) {
            [self.promises addObject:promise];
        }
        else {
            
        }
    }];
    
    __weak __typeof(self)weakSelf = self;
    self.resolveBlock = ^(id value) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (strongSelf.state != PromiseStatePending) return;
        
        if ([value isKindOfClass:[JOPromise class]]) {
            
            if (((JOPromise *) value).state == PromiseStatePending) {
                strongSelf.promiseInstance = value;
                [(JOPromise *)value addObserver:strongSelf forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
            }
            else {
                [(JOPromise *)value addObserver:strongSelf forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
            }
        } else {
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
        
        if (newState == PromiseStateResolved) {
            [self.promises enumerateObjectsUsingBlock:^(JOPromise *promise, BOOL *stop) {
                [promise removeObserver:self forKeyPath:@"state"];
            }];
            
            self.resolveBlock([(JOPromise *) object value]);
        }
        else if (newState == PromiseStateRejected) {
            [_values addObject:[(JOPromise *) object error]];
            
            if (self.promises.count == 0) {
                self.rejectBlock([NSError errorWithUserInfo:@{@"reason": @"No promise wins the race",@"errors":_values}]);
            }
        }
    }
}

@end

@implementation JOPromise (race)

+ (instancetype)race:(NSArray<JOPromise *> *)promises
{
    return [[racePromise alloc] initWithPromises:promises];
}

@end

