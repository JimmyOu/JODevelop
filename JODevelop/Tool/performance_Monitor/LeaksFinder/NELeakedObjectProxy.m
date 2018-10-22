//
//  NELeakedObjectProxy.m
//  TestApp
//
//  Created by JimmyOu on 2018/10/9.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "NELeakedObjectProxy.h"
#import "NELeaksFinder.h"
#import "NSObject+NEMemoryLeak.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import <FBRetainCycleDetector/FBRetainCycleDetector.h>
#import "NEMonitorFileManager.h"
#import "NEMonitorToast.h"

static NSMutableSet *leakedObjectPtrs;
@interface NELeakedObjectProxy()

@property (nonatomic, weak) id object;
@property (nonatomic, strong) NSNumber *objectPtr;
@property (nonatomic, strong) NSArray *viewStack;

@end
@implementation NELeakedObjectProxy


+ (BOOL)isAnyObjectLeakedAtPtrs:(NSSet *)ptrs {
    NSAssert([NSThread isMainThread], @"Must be in main thread.");
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        leakedObjectPtrs = [[NSMutableSet alloc] init];
    });
    
    if (!ptrs.count) {
        return NO;
    }
    if ([leakedObjectPtrs intersectsSet:ptrs]) {
        return YES;
    } else {
        return NO;
    }
}

+ (void)addLeakedObject:(id)object {
    NSAssert([NSThread isMainThread], @"Must be in main thread.");
    
    NELeakedObjectProxy *proxy = [[NELeakedObjectProxy alloc] init];
    proxy.object = object;
    proxy.objectPtr = @((uintptr_t)object);
    proxy.viewStack = [object viewStack];
    static const void *const kLeakedObjectProxyKey = &kLeakedObjectProxyKey;
    objc_setAssociatedObject(object, kLeakedObjectProxyKey, proxy, OBJC_ASSOCIATION_RETAIN);
    
    [leakedObjectPtrs addObject:proxy.objectPtr];
    
    [proxy tryToFindRetainCycle];
}

- (void)dealloc {
    NSNumber *objectPtr = _objectPtr;
    dispatch_async(dispatch_get_main_queue(), ^{
        [leakedObjectPtrs removeObject:objectPtr];
    });
}

- (void)tryToFindRetainCycle {
    id object = self.object;
    if (!object) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        FBRetainCycleDetector *detector = [FBRetainCycleDetector new];
        [detector addCandidate:self.object];
        NSSet *retainCycles = [detector findRetainCyclesWithMaxCycleLength:20];
        
        BOOL hasFound = NO;
        for (NSArray *retainCycle in retainCycles) {
            NSInteger index = 0;
            for (FBObjectiveCGraphElement *element in retainCycle) {
                if (element.object == object) {
                    NSArray *shiftedRetainCycle = [self shiftArray:retainCycle toIndex:index];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSString *viewStack = [NSString stringWithFormat:@"viewStack=%@", self.viewStack];
                        NSString *retainCycle = [NSString stringWithFormat:@"retainCycle=%@", shiftedRetainCycle];
                        [[NEMonitorFileManager shareInstance] addNewRetainCycle:[NSString stringWithFormat:@"%@\n%@",viewStack,retainCycle]];
                        [NEMonitorToast showToast:@"发现新的♻️引用"];
                    });
                    hasFound = YES;
                    break;
                }
                
                ++index;
            }
            if (hasFound) {
                break;
            }
        }
        if (!hasFound) {
        }
    });
}


- (NSArray *)shiftArray:(NSArray *)array toIndex:(NSInteger)index {
    if (index == 0) {
        return array;
    }
    
    NSRange range = NSMakeRange(index, array.count - index);
    NSMutableArray *result = [[array subarrayWithRange:range] mutableCopy];
    [result addObjectsFromArray:[array subarrayWithRange:NSMakeRange(0, index)]];
    return result;
}


@end
