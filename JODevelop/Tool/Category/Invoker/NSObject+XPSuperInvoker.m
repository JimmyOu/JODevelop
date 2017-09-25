//
// Created by 徐鹏 on 16/3/25.
// Copyright (c) 2016 徐鹏. All rights reserved.
//

#import "NSObject+XPSuperInvoker.h"
#if TARGET_OS_IPHONE
#import <UIKit/UIApplication.h>
#import "NSArray+Extension.h"
#endif

@interface xps_pointer : NSObject

@property (nonatomic) void *pointer;

@end

@implementation xps_pointer

@end

@interface xps_nilObject : NSObject

@end

@implementation xps_nilObject

@end


static NSLock              *_xpsMethodSignatureLock;
static NSMutableDictionary *_xpsMethodSignatureCache;
static xps_nilObject       *_xpsNilPointer = nil;

static NSString *xps_extractStructName(NSString *typeEncodeString)
{
    NSArray *array = [typeEncodeString componentsSeparatedByString:@"="];
    NSString *typeString = array[0];

    __block int firstVaildIndex = 0;
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        char c = (char)[typeEncodeString characterAtIndex:idx];
        if (c=='{' || c=='_') {
            firstVaildIndex++;
        }
        else {
            *stop = YES;
        }
    }];

    return [typeString substringFromIndex:(NSUInteger)firstVaildIndex];
}

static NSString *xps_selectorName(SEL selector)
{
    const char *selNameCstr = sel_getName(selector);
    NSString *selName = [[NSString alloc]initWithUTF8String:selNameCstr];
    return selName;
}

static NSMethodSignature *xps_getMethodSignature(Class cls, SEL selector)
{
    [_xpsMethodSignatureLock lock];

    if (!_xpsMethodSignatureCache) {
        _xpsMethodSignatureCache = [[NSMutableDictionary alloc]init];
    }

    if (!_xpsMethodSignatureCache[cls]) {
        _xpsMethodSignatureCache[(id<NSCopying>)cls] =[[NSMutableDictionary alloc] init];
    }

    NSString *selName = xps_selectorName(selector);
    NSMethodSignature *methodSignature = _xpsMethodSignatureCache[cls][selName];

    if (!methodSignature) {
        methodSignature = [cls instanceMethodSignatureForSelector:selector];
        if (methodSignature) {
            _xpsMethodSignatureCache[cls][selName] = methodSignature;
        }
        else {
            methodSignature = [cls methodSignatureForSelector:selector];
            if (methodSignature) {
                _xpsMethodSignatureCache[cls][selName] = methodSignature;
            }
        }
    }

    [_xpsMethodSignatureLock unlock];

    return methodSignature;
}

static void xps_generateError(NSString *errorInfo, NSError **error)
{
    if (error) {
        *error = [NSError errorWithDomain:@"message send reciver is nil" code:0 userInfo:nil];
    }
}

id xps_targetCallSelectorWithArgumentError(id target, SEL selector, NSArray *argsArr, NSError *__autoreleasing *error)
{
    Class cls = [target class];
    NSMethodSignature *methodSignature = xps_getMethodSignature(cls, selector);
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    [invocation setTarget:target];
    [invocation setSelector:selector];

    NSMutableArray *_markArray;

    for (int i = 2; i< [methodSignature numberOfArguments]; i++) {
        const char *argumentType = [methodSignature getArgumentTypeAtIndex:i];
        id valObj = argsArr[i-2];
        switch (argumentType[0]=='r'?argumentType[1]:argumentType[0]) {
#define xps_CALL_ARG_CASE(_typeString, _type, _selector) \
            case _typeString: {                          \
            _type value = [valObj _selector];            \
            [invocation setArgument:&value atIndex:i];   \
            break;                                       \
            }
            xps_CALL_ARG_CASE('c', char, charValue)
            xps_CALL_ARG_CASE('C', unsigned char, unsignedCharValue)
            xps_CALL_ARG_CASE('s', short, shortValue)
            xps_CALL_ARG_CASE('S', unsigned short, unsignedShortValue)
            xps_CALL_ARG_CASE('i', int, intValue)
            xps_CALL_ARG_CASE('I', unsigned int, unsignedIntValue)
            xps_CALL_ARG_CASE('l', long, longValue)
            xps_CALL_ARG_CASE('L', unsigned long, unsignedLongValue)
            xps_CALL_ARG_CASE('q', long long, longLongValue)
            xps_CALL_ARG_CASE('Q', unsigned long long, unsignedLongLongValue)
            xps_CALL_ARG_CASE('f', float, floatValue)
            xps_CALL_ARG_CASE('d', double, doubleValue)
            xps_CALL_ARG_CASE('B', BOOL, boolValue)

            case ':':{
                NSString *selName = valObj;
                SEL selValue = NSSelectorFromString(selName);
                [invocation setArgument:&selValue atIndex:i];

                break;
            }
            case '{':{
                NSString *typeString = xps_extractStructName([NSString stringWithUTF8String:argumentType]);
                NSValue *val = (NSValue *)valObj;
#define xps_CALL_ARG_STRUCT(_type, _methodName)                                 \
            if ([typeString rangeOfString:@#_type].location != NSNotFound) {    \
            _type value = [val _methodName];                                    \
            [invocation setArgument:&value atIndex:i];                          \
            break;                                                              \
            }
                xps_CALL_ARG_STRUCT(CGRect, CGRectValue)
                xps_CALL_ARG_STRUCT(CGPoint, CGPointValue)
                xps_CALL_ARG_STRUCT(CGSize, CGSizeValue)
                xps_CALL_ARG_STRUCT(NSRange, rangeValue)
                xps_CALL_ARG_STRUCT(CGAffineTransform, CGAffineTransformValue)
                xps_CALL_ARG_STRUCT(UIEdgeInsets, UIEdgeInsetsValue)
                xps_CALL_ARG_STRUCT(UIOffset, UIOffsetValue)
                xps_CALL_ARG_STRUCT(CGVector, CGVectorValue)

                break;
            }
            case '*':{
                NSCAssert(NO, @"argument boxing wrong,char* is not supported");

                break;
            }
            case '^':{
                xps_pointer *value = valObj;
                void *pointer = value.pointer;
                id obj = *((__unsafe_unretained id *)pointer);
                if (!obj) {
                    if (argumentType[1] == '@') {
                        if (!_markArray) {
                            _markArray = [[NSMutableArray alloc] init];
                        }
                        [_markArray addObject:valObj];
                    }
                }
                [invocation setArgument:&pointer atIndex:i];

                break;
            }
            case '#':{
                [invocation setArgument:&valObj atIndex:i];

                break;
            }
            default:{
                if ([valObj isKindOfClass:[xps_nilObject class]]) {
                    [invocation setArgument:&_xpsNilPointer atIndex:i];
                }
                else {
                    [invocation setArgument:&valObj atIndex:i];
                }
            }
        }
    }

    [invocation invoke];

    if ([_markArray count] > 0) {
        for (xps_pointer *pointerObj in _markArray) {
            void *pointer = pointerObj.pointer;
            id obj = *((__unsafe_unretained id *)pointer);
            if (obj) {
                CFRetain((__bridge CFTypeRef)(obj));
            }
        }
    }

    const char *returnType = [methodSignature methodReturnType];
    NSString *selName = xps_selectorName(selector);
    if (strncmp(returnType, "v", 1) != 0 ) {
        if (strncmp(returnType, "@", 1) == 0) {
            void *result;
            [invocation getReturnValue:&result];

            if (result == NULL) {
                return nil;
            }

            id returnValue;
            if ([selName isEqualToString:@"alloc"] || [selName isEqualToString:@"new"] || [selName isEqualToString:@"copy"] || [selName isEqualToString:@"mutableCopy"]) {
                returnValue = (__bridge_transfer id)result;
            }
            else {
                returnValue = (__bridge id)result;
            }

            return returnValue;

        }
        else {
            switch (returnType[0] == 'r' ? returnType[1] : returnType[0]) {

#define xps_CALL_RET_CASE(_typeString, _type)         \
            case _typeString: {                       \
            _type returnValue;                        \
            [invocation getReturnValue:&returnValue]; \
            return @(returnValue);                    \
            break;                                    \
            }
                xps_CALL_RET_CASE('c', char)
                xps_CALL_RET_CASE('C', unsigned char)
                xps_CALL_RET_CASE('s', short)
                xps_CALL_RET_CASE('S', unsigned short)
                xps_CALL_RET_CASE('i', int)
                xps_CALL_RET_CASE('I', unsigned int)
                xps_CALL_RET_CASE('l', long)
                xps_CALL_RET_CASE('L', unsigned long)
                xps_CALL_RET_CASE('q', long long)
                xps_CALL_RET_CASE('Q', unsigned long long)
                xps_CALL_RET_CASE('f', float)
                xps_CALL_RET_CASE('d', double)
                xps_CALL_RET_CASE('B', BOOL)

                case '{': {
                    NSString *typeString = xps_extractStructName([NSString stringWithUTF8String:returnType]);
#define xps_CALL_RET_STRUCT(_type)                                                                 \
                if ([typeString rangeOfString:@#_type].location != NSNotFound) {                   \
                _type result;                                                                      \
                [invocation getReturnValue:&result];                                               \
                NSValue * returnValue = [NSValue valueWithBytes:&(result) objCType:@encode(_type)];\
                return returnValue;                                                                \
                }
                    xps_CALL_RET_STRUCT(CGRect)
                    xps_CALL_RET_STRUCT(CGPoint)
                    xps_CALL_RET_STRUCT(CGSize)
                    xps_CALL_RET_STRUCT(NSRange)
                    xps_CALL_RET_STRUCT(CGAffineTransform)
                    xps_CALL_RET_STRUCT(UIEdgeInsets)
                    xps_CALL_RET_STRUCT(UIOffset)
                    xps_CALL_RET_STRUCT(CGVector)

                    break;
                }
                case '*':{
                    break;
                }
                case '^': {
                    break;
                }
                case '#': {
                    break;
                }
            }
            return nil;
        }
    }
    return nil;
};

NSArray *xps_targetBoxingArgumentsWithVaList(va_list argList, Class cls, SEL selector, NSError *__autoreleasing *error)
{

    NSMethodSignature *methodSignature = xps_getMethodSignature(cls, selector);
    NSString *selName = xps_selectorName(selector);

    if (!methodSignature) {
        NSString* errorStr = [NSString stringWithFormat:@"unrecognized selector (%@)", selName];
        xps_generateError(errorStr,error);
        return nil;
    }
    NSMutableArray *argumentsBoxingArray = [[NSMutableArray alloc]init];

    for (int i = 2; i < [methodSignature numberOfArguments]; i++) {
        const char *argumentType = [methodSignature getArgumentTypeAtIndex:i];
        switch (argumentType[0] == 'r' ? argumentType[1] : argumentType[0]) {

#define xps_BOXING_ARG_CASE(_typeString, _type)    \
        case _typeString: {                        \
        _type value = va_arg(argList, _type);      \
        [argumentsBoxingArray addObject:@(value)]; \
        break;                                     \
        }                                          \

            xps_BOXING_ARG_CASE('c', int)
            xps_BOXING_ARG_CASE('C', int)
            xps_BOXING_ARG_CASE('s', int)
            xps_BOXING_ARG_CASE('S', int)
            xps_BOXING_ARG_CASE('i', int)
            xps_BOXING_ARG_CASE('I', unsigned int)
            xps_BOXING_ARG_CASE('l', long)
            xps_BOXING_ARG_CASE('L', unsigned long)
            xps_BOXING_ARG_CASE('q', long long)
            xps_BOXING_ARG_CASE('Q', unsigned long long)
            xps_BOXING_ARG_CASE('f', double)
            xps_BOXING_ARG_CASE('d', double)
            xps_BOXING_ARG_CASE('B', int)

            case ':': {
                SEL value = va_arg(argList, SEL);
                NSString *selValueName = NSStringFromSelector(value);
                [argumentsBoxingArray addObject:selValueName];

                break;
            }
            case '{': {
                NSString *typeString = xps_extractStructName([NSString stringWithUTF8String:argumentType]);

#define xps_FWD_ARG_STRUCT(_type, _methodName)                                \
            if ([typeString rangeOfString:@#_type].location != NSNotFound) {  \
            _type val = va_arg(argList, _type);                               \
            NSValue* value = [NSValue _methodName:val];                       \
            [argumentsBoxingArray addObject:value];                           \
            break;                                                            \
            }
                xps_FWD_ARG_STRUCT(CGRect, valueWithCGRect)
                xps_FWD_ARG_STRUCT(CGPoint, valueWithCGPoint)
                xps_FWD_ARG_STRUCT(CGSize, valueWithCGSize)
                xps_FWD_ARG_STRUCT(NSRange, valueWithRange)
                xps_FWD_ARG_STRUCT(CGAffineTransform, valueWithCGAffineTransform)
                xps_FWD_ARG_STRUCT(UIEdgeInsets, valueWithUIEdgeInsets)
                xps_FWD_ARG_STRUCT(UIOffset, valueWithUIOffset)
                xps_FWD_ARG_STRUCT(CGVector, valueWithCGVector)

                break;
            }
            case '*':{
                xps_generateError(@"unsupported char* argumenst",error);
                return nil;
            }
            case '^': {
                void *value = va_arg(argList, void**);
                xps_pointer *pointerObj = [[xps_pointer alloc]init];
                pointerObj.pointer = value;
                [argumentsBoxingArray addObject:pointerObj];

                break;
            }
            case '#': {
                Class value = va_arg(argList, Class);
                [argumentsBoxingArray addObject:(id)value];
                //xps_generateError(@"unsupported class argumenst",error);
                //return nil;

                break;
            }
            case '@':{
                id value = va_arg(argList, id);
                if (value) {
                    [argumentsBoxingArray addObject:value];
                }
                else {
                    [argumentsBoxingArray addObject:[xps_nilObject new]];
                }

                break;
            }
            default: {
                xps_generateError(@"unsupported argumenst",error);
                return nil;
            }
        }
    }

    return [argumentsBoxingArray copy];
}

NSArray *xps_targetBoxingArgumentsWithArray(NSArray *argList, Class cls, SEL selector, NSError *__autoreleasing *error)
{

    NSMethodSignature *methodSignature = xps_getMethodSignature(cls, selector);
    NSString *selName = xps_selectorName(selector);

    if (!methodSignature) {
        NSString* errorStr = [NSString stringWithFormat:@"unrecognized selector (%@)", selName];
        xps_generateError(errorStr,error);
        return nil;
    }
    NSMutableArray *argumentsBoxingArray = [[NSMutableArray alloc]init];

    for (int i = 2; i < [methodSignature numberOfArguments]; i++) {
        id value = [argList safeObjectAtIndex:i-2];
        if (value) {
            [argumentsBoxingArray addObject:value];
        }
        else {
            [argumentsBoxingArray addObject:[xps_nilObject new]];
        }
    }

    return [argumentsBoxingArray copy];
}

@implementation NSObject (XPSuperInvoker)

+ (id)invokeWithName:(NSString *)selName error:(NSError *__autoreleasing *)error,...
{
    va_list argList;
    va_start(argList, error);
    SEL selector = NSSelectorFromString(selName);
    NSArray *boxingAruments = xps_targetBoxingArgumentsWithVaList(argList, [self class], selector, error);
    va_end(argList);

    if (!boxingAruments) {
        return nil;
    }

    return xps_targetCallSelectorWithArgumentError(self, selector, boxingAruments, error);
}

+ (id)invoke:(SEL)selector error:(NSError *__autoreleasing *)error,...
{
    va_list argList;
    va_start(argList, error);
    NSArray* boxingArguments = xps_targetBoxingArgumentsWithVaList(argList, [self class], selector, error);
    va_end(argList);

    if (!boxingArguments) {
        return nil;
    }

    return xps_targetCallSelectorWithArgumentError(self, selector, boxingArguments, error);
}

- (id)invokeWithName:(NSString *)selName error:(NSError *__autoreleasing *)error,...
{
    va_list argList;
    va_start(argList, error);
    SEL selector = NSSelectorFromString(selName);
    NSArray* boxingArguments = xps_targetBoxingArgumentsWithVaList(argList, [self class], selector, error);
    va_end(argList);

    if (!boxingArguments) {
        return nil;
    }

    return xps_targetCallSelectorWithArgumentError(self, selector, boxingArguments, error);
}

- (id)invoke:(SEL)selector error:(NSError *__autoreleasing *)error,...
{
    va_list argList;
    va_start(argList, error);
    NSArray* boxingArguments = xps_targetBoxingArgumentsWithVaList(argList, [self class], selector, error);
    va_end(argList);

    if (!boxingArguments) {
        return nil;
    }

    return xps_targetCallSelectorWithArgumentError(self, selector, boxingArguments, error);
}

@end
