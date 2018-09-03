//
//  NSDictionary+NECrashVoid.m
//  SnailReader
//
//  Created by JimmyOu on 2018/8/31.
//  Copyright © 2018年 com.netease. All rights reserved.
//

#import "NSDictionary+NECrashVoid.h"
#import "NEMonitorUtils.h"

@implementation NSDictionary (NECrashVoid)

+ (void)swizzle {
    [NEMonitorUtils ne_swizzleSEL:@selector(dictionaryWithObjects:forKeys:count:) withSEL:@selector(avoidCrashDictionaryWithObjects:forKeys:count:) forClass:[NSDictionary class]];
}

+ (instancetype)avoidCrashDictionaryWithObjects:(const id  _Nonnull __unsafe_unretained *)objects forKeys:(const id<NSCopying>  _Nonnull __unsafe_unretained *)keys count:(NSUInteger)cnt {
    
    id instance = nil;
    
    @try {
        instance = [self avoidCrashDictionaryWithObjects:objects forKeys:keys count:cnt];
    }
    @catch (NSException *exception) {
        [NEMonitorUtils notifyWithException:exception];
        
        //处理错误的数据，然后重新初始化一个字典
        NSUInteger index = 0;
        id  _Nonnull __unsafe_unretained newObjects[cnt];
        id  _Nonnull __unsafe_unretained newkeys[cnt];
        
        for (int i = 0; i < cnt; i++) {
            if (objects[i] && keys[i]) {
                newObjects[index] = objects[i];
                newkeys[index] = keys[i];
                index++;
            }
        }
        instance = [self avoidCrashDictionaryWithObjects:newObjects forKeys:newkeys count:index];
    }
    @finally {
        return instance;
    }
}

@end

@implementation NSMutableDictionary (NECrashVoid)

+ (void)swizzle {
    Class dictionaryM = NSClassFromString(@"__NSDictionaryM");
    
    //setObject:forKey:
    [NEMonitorUtils ne_swizzleSEL:@selector(setObject:forKey:) withSEL:@selector(avoidCrashSetObject:forKey:) forClass:dictionaryM];
    
    //setObject:forKeyedSubscript:
    BOOL ios11 = [[UIDevice currentDevice].systemVersion floatValue] >= 11.0;
    if (ios11) {
        [NEMonitorUtils ne_swizzleSEL:@selector(setObject:forKeyedSubscript:) withSEL:@selector(avoidCrashSetObject:forKeyedSubscript:) forClass:dictionaryM];
    }

    
    //removeObjectForKey:
    [NEMonitorUtils ne_swizzleSEL:@selector(removeObjectForKey:) withSEL:@selector(avoidCrashRemoveObjectForKey:) forClass:dictionaryM];

}

- (void)avoidCrashSetObject:(id)anObject forKey:(id<NSCopying>)aKey {
    
    @try {
        [self avoidCrashSetObject:anObject forKey:aKey];
    }
    @catch (NSException *exception) {
        [NEMonitorUtils notifyWithException:exception];
    }
    @finally {
        
    }
}
- (void)avoidCrashSetObject:(id)obj forKeyedSubscript:(id<NSCopying>)key {
    @try {
        [self avoidCrashSetObject:obj forKeyedSubscript:key];
    }
    @catch (NSException *exception) {
        [NEMonitorUtils notifyWithException:exception];
    }
    @finally {
        
    }
}

- (void)avoidCrashRemoveObjectForKey:(id)aKey {
    
    @try {
        [self avoidCrashRemoveObjectForKey:aKey];
    }
    @catch (NSException *exception) {
        [NEMonitorUtils notifyWithException:exception];
    }
    @finally {
    }
}


@end
