//
//  NSArray+NECrashVoid.m
//  SnailReader
//
//  Created by JimmyOu on 2018/8/31.
//  Copyright © 2018年 com.netease. All rights reserved.
//

#import "NSArray+NECrashVoid.h"
#import "NEMonitorUtils.h"

@implementation NSArray (NECrashVoid)

+ (void)swizzle {
    /***   class method      **/
    [NEMonitorUtils ne_swizzleClassSEL:@selector(arrayWithObjects:count:) withSEL:@selector(ne_avoidCrashArrayWithObjects:count:) forClass:[NSArray class]];
    
    Class __NSArray = NSClassFromString(@"NSArray");
    Class __NSArrayI = NSClassFromString(@"__NSArrayI");
    Class __NSSingleObjectArrayI = NSClassFromString(@"__NSSingleObjectArrayI");
    Class __NSArray0 = NSClassFromString(@"__NSArray0");
    
    
    
    /***   instance method     **/
    
    //objectsAtIndexes:
    [NEMonitorUtils ne_swizzleSEL:@selector(objectsAtIndexes:) withSEL:@selector(ne_avoidCrashObjectsAtIndexes:) forClass:__NSArray];
    
    
    
    //objectAtIndex:
    [NEMonitorUtils ne_swizzleSEL:@selector(objectAtIndex:) withSEL:@selector(__NSArrayIAvoidCrashObjectAtIndex:) forClass:__NSArrayI];
    
    [NEMonitorUtils ne_swizzleSEL:@selector(objectAtIndex:) withSEL:@selector(__NSSingleObjectArrayIAvoidCrashObjectAtIndex:) forClass:__NSSingleObjectArrayI];
    
    [NEMonitorUtils ne_swizzleSEL:@selector(objectAtIndex:) withSEL:@selector(__NSArray0AvoidCrashObjectAtIndex:) forClass:__NSArray0];
    
    
    //objectAtIndexedSubscript:
    BOOL ios11 = [[UIDevice currentDevice].systemVersion floatValue] >= 11.0;
    if (ios11) {
        [NEMonitorUtils ne_swizzleSEL:@selector(objectAtIndexedSubscript:) withSEL:@selector(__NSArrayIAvoidCrashObjectAtIndexedSubscript:) forClass:__NSArrayI];
    }
    
    
    
    //getObjects:range:
    [NEMonitorUtils ne_swizzleSEL:@selector(getObjects:range:) withSEL:@selector(NSArrayAvoidCrashGetObjects:range:) forClass:__NSArray];
    
    [NEMonitorUtils ne_swizzleSEL:@selector(getObjects:range:) withSEL:@selector(__NSSingleObjectArrayIAvoidCrashGetObjects:range:) forClass:__NSSingleObjectArrayI];
    
    [NEMonitorUtils ne_swizzleSEL:@selector(getObjects:range:) withSEL:@selector(__NSArrayIAvoidCrashGetObjects:range:) forClass:__NSArrayI];
    
    
}

+ (instancetype)ne_avoidCrashArrayWithObjects:(id  _Nonnull const [])objects count:(NSUInteger)cnt {
    id instance = nil;
    
    @try {
        instance = [self ne_avoidCrashArrayWithObjects:objects count:cnt];
    }
    @catch (NSException *exception) {
        
        [NEMonitorUtils notifyWithException:exception];
        
        //以下是对错误数据的处理，把为nil的数据去掉,然后初始化数组
        NSInteger newObjsIndex = 0;
        id  _Nonnull __unsafe_unretained newObjects[cnt];
        
        for (int i = 0; i < cnt; i++) {
            if (objects[i] != nil) {
                newObjects[newObjsIndex] = objects[i];
                newObjsIndex++;
            }
        }
        instance = [self ne_avoidCrashArrayWithObjects:newObjects count:newObjsIndex];
    }
    @finally {
        return instance;
    }
}


//objectAtIndexedSubscript:
- (id)__NSArrayIAvoidCrashObjectAtIndexedSubscript:(NSUInteger)idx {
    id object = nil;
    
    @try {
        object = [self __NSArrayIAvoidCrashObjectAtIndexedSubscript:idx];
    }
    @catch (NSException *exception) {
        [NEMonitorUtils notifyWithException:exception];
    }
    @finally {
        return object;
    }
}

//objectsAtIndexes:
- (NSArray *)ne_avoidCrashObjectsAtIndexes:(NSIndexSet *)indexes {
    NSArray *returnArray = nil;
    @try {
        returnArray = [self ne_avoidCrashObjectsAtIndexes:indexes];
    } @catch (NSException *exception) {
        [NEMonitorUtils notifyWithException:exception];
    } @finally {
        return returnArray;
    }
}


//objectAtIndex:
- (id)__NSArrayIAvoidCrashObjectAtIndex:(NSUInteger)index {
    id object = nil;
    @try {
        object = [self __NSArrayIAvoidCrashObjectAtIndex:index];
    }
    @catch (NSException *exception) {
        [NEMonitorUtils notifyWithException:exception];
    }
    @finally {
        return object;
    }
}

- (id)__NSSingleObjectArrayIAvoidCrashObjectAtIndex:(NSUInteger)index {
    id object = nil;
    
    @try {
        object = [self __NSSingleObjectArrayIAvoidCrashObjectAtIndex:index];
    }
    @catch (NSException *exception) {
        [NEMonitorUtils notifyWithException:exception];
    }
    @finally {
        return object;
    }
}

- (id)__NSArray0AvoidCrashObjectAtIndex:(NSUInteger)index {
    id object = nil;
    
    @try {
        object = [self __NSArray0AvoidCrashObjectAtIndex:index];
    }
    @catch (NSException *exception) {
        [NEMonitorUtils notifyWithException:exception];
    }
    @finally {
        return object;
    }
}


//getObjects:range:
- (void)NSArrayAvoidCrashGetObjects:(__unsafe_unretained id  _Nonnull [])objects range:(NSRange)range {
    @try {
        [self NSArrayAvoidCrashGetObjects:objects range:range];
    } @catch (NSException *exception) {
        
        [NEMonitorUtils notifyWithException:exception];
        
    } @finally {
        
    }
}

- (void)__NSSingleObjectArrayIAvoidCrashGetObjects:(__unsafe_unretained id  _Nonnull [])objects range:(NSRange)range {
    @try {
        [self __NSSingleObjectArrayIAvoidCrashGetObjects:objects range:range];
    } @catch (NSException *exception) {
        
        [NEMonitorUtils notifyWithException:exception];
        
    } @finally {
        
    }
}

- (void)__NSArrayIAvoidCrashGetObjects:(__unsafe_unretained id  _Nonnull [])objects range:(NSRange)range {
    @try {
        [self __NSArrayIAvoidCrashGetObjects:objects range:range];
    } @catch (NSException *exception) {
        
        [NEMonitorUtils notifyWithException:exception];
        
    } @finally {
        
    }
}

@end

@implementation NSMutableArray(NECrashVoid)
+ (void)swizzle {
    Class arrayMClass = NSClassFromString(@"__NSArrayM");
    
    //objectAtIndex:
    [NEMonitorUtils ne_swizzleSEL:@selector(objectAtIndex:) withSEL:@selector(avoidCrashObjectAtIndex:) forClass:arrayMClass];
    
    //objectAtIndexedSubscript
    BOOL ios11 = [[UIDevice currentDevice].systemVersion floatValue] >= 11.0;
    if (ios11) {
        [NEMonitorUtils ne_swizzleSEL:@selector(objectAtIndexedSubscript:) withSEL:@selector(avoidCrashObjectAtIndexedSubscript:) forClass:arrayMClass];
    }
    
    
    //setObject:atIndexedSubscript:
    [NEMonitorUtils ne_swizzleSEL:@selector(setObject:atIndexedSubscript:) withSEL:@selector(avoidCrashSetObject:atIndexedSubscript:) forClass:arrayMClass];
    
    
    //removeObjectAtIndex:
    [NEMonitorUtils ne_swizzleSEL:@selector(removeObjectAtIndex:) withSEL:@selector(avoidCrashRemoveObjectAtIndex:) forClass:arrayMClass];
    
    
    //insertObject:atIndex:
    [NEMonitorUtils ne_swizzleSEL:@selector(insertObject:atIndex:) withSEL:@selector(avoidCrashInsertObject:atIndex:) forClass:arrayMClass];
    
    
    //getObjects:range:
    [NEMonitorUtils ne_swizzleSEL:@selector(getObjects:range:) withSEL:@selector(avoidCrashGetObjects:range:) forClass:arrayMClass];
    
}

//objectAtIndex:
- (id)avoidCrashObjectAtIndex:(NSUInteger)index {
    id object = nil;
    
    @try {
        object = [self avoidCrashObjectAtIndex:index];
    }
    @catch (NSException *exception) {
        [NEMonitorUtils notifyWithException:exception];
    }
    @finally {
        return object;
    }
}

//objectAtIndexedSubscript
- (id)avoidCrashObjectAtIndexedSubscript:(NSUInteger)idx {
    id object = nil;
    
    @try {
        object = [self avoidCrashObjectAtIndexedSubscript:idx];
    }
    @catch (NSException *exception) {
        [NEMonitorUtils notifyWithException:exception];
    }
    @finally {
        return object;
    }
    
}

//setObject:atIndexedSubscript:
- (void)avoidCrashSetObject:(id)obj atIndexedSubscript:(NSUInteger)idx {
    
    @try {
        [self avoidCrashSetObject:obj atIndexedSubscript:idx];
    }
    @catch (NSException *exception) {
        [NEMonitorUtils notifyWithException:exception];
    }
    @finally {
        
    }
}

- (void)avoidCrashRemoveObjectAtIndex:(NSUInteger)index {
    @try {
        [self avoidCrashRemoveObjectAtIndex:index];
    }
    @catch (NSException *exception) {
        [NEMonitorUtils notifyWithException:exception];
    }
    @finally {
        
    }
}


//insertObject:atIndex:
- (void)avoidCrashInsertObject:(id)anObject atIndex:(NSUInteger)index {
    @try {
        [self avoidCrashInsertObject:anObject atIndex:index];
    }
    @catch (NSException *exception) {
        [NEMonitorUtils notifyWithException:exception];
    }
    @finally {
        
    }
}

//getObjects:range:

- (void)avoidCrashGetObjects:(__unsafe_unretained id  _Nonnull [])objects range:(NSRange)range {
    @try {
        [self avoidCrashGetObjects:objects range:range];
    } @catch (NSException *exception) {
        [NEMonitorUtils notifyWithException:exception];
        
    } @finally {
        
    }
}

@end
