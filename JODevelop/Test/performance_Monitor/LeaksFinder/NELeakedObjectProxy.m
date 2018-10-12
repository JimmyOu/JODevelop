//
//  NELeakedObjectProxy.m
//  TestApp
//
//  Created by JimmyOu on 2018/10/9.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "NELeakedObjectProxy.h"
#import "NELeaksFinder.h"
#import "NELeaksMessenger.h"
#import "NSObject+NEMemoryLeak.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import <FBRetainCycleDetector/FBRetainCycleDetector.h>
#import "NEMonitorFileManager.h"
#import "NEMonitorToast.h"

static NSMutableSet *leakedObjectPtrs;
@interface NELeakedObjectProxy()<UIAlertViewDelegate>

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
    
//    if (_INTERNAL_MLF_Alert) {
//        [NELeaksMessenger alertWithTitle:@"Memory Leak"
//                                message:[NSString stringWithFormat:@"%@", proxy.viewStack]
//                               delegate:proxy
//                  additionalButtonTitle:@"Retain Cycle"];
//    } else {
//
//
//    }
    [proxy alertView:nil clickedButtonAtIndex:1];
}

- (void)dealloc {
    NSNumber *objectPtr = _objectPtr;
//    NSArray *viewStack = _viewStack;
    dispatch_async(dispatch_get_main_queue(), ^{
        [leakedObjectPtrs removeObject:objectPtr];
//        [NELeaksMessenger alertWithTitle:@"Object Deallocated"
//                                message:[NSString stringWithFormat:@"%@", viewStack]];
    });
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (!buttonIndex) {
        return;
    }
    
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
//                        if (_INTERNAL_MLF_Alert) {
//                        [NELeaksMessenger alertWithTitle:@"Retain Cycle"
//                                                message:[NSString stringWithFormat:@"%@", shiftedRetainCycle]];
//                        } else {
//                            //**//
//
//                        }
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
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if (_INTERNAL_MLF_Alert) {
//                    [NELeaksMessenger alertWithTitle:@"Retain Cycle"
//                                            message:@"Fail to find a retain cycle"];
//                }
//            });
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
