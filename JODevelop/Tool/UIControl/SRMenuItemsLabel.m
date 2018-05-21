//
//  SRMenuItemsLabel.m
//  SnailReader
//
//  Created by JimmyOu on 2018/2/2.
//  Copyright © 2018年 com.netease. All rights reserved.
//

#import "SRMenuItemsLabel.h"
#import <objc/runtime.h>

#define force_inline __inline__ __attribute__((always_inline))

static force_inline Class NSBlockClass() {
    static Class cls;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        void (^block)(void) = ^{};
        cls = ((NSObject *)block).class;
        while (class_getSuperclass(cls) != [NSObject class]) {
            cls = class_getSuperclass(cls);
        }
    });
    return cls;
}


@interface SRMenuItemsLabel()
@property (strong, nonatomic) NSMutableArray <UIMenuItem *> *mul_items;
@property (strong, nonatomic) NSMutableDictionary *handlerBlocks;
@end
@implementation SRMenuItemsLabel

void handlderProxy(SRMenuItemsLabel *label, SEL _cmd, id params) {
    id handler = [label.handlerBlocks objectForKey:NSStringFromSelector(_cmd)];
    if ([handler isKindOfClass:NSBlockClass()]) {
        void (^_handler)(NSString *) = (void (^)(NSString *))handler;
        _handler(label.text);
    }
}

- (NSArray<UIMenuItem *> *)items {
    return [self.mul_items copy];
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _handlerBlocks = [NSMutableDictionary dictionary];
        [self pressAction];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _handlerBlocks = [NSMutableDictionary dictionary];
        [self pressAction];
    }
    return self;
}

- (void)dealloc {
    [_handlerBlocks removeAllObjects];
}
- (void)addMenuItemWithTitle:(NSString *)title clickBlock:(void(^)(NSString *text))block {
    NSAssert(title != nil, @"title cant be nil");
    NSString *newSelecotor = [NSString stringWithFormat:@"%d_handlderProxy",(int)(self.mul_items.count + 1)];
    
    UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:title action:NSSelectorFromString(newSelecotor)];
    [self.mul_items addObject:item];
    [_handlerBlocks setObject:[block copy] forKey:newSelecotor];
    
}

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    BOOL needHandler = NO;
    NSString *selStr = NSStringFromSelector(sel);
    if ([selStr hasSuffix:@"handlderProxy"]) {
        needHandler = YES;
    }
    if (needHandler) {
        class_addMethod([self class], sel, (IMP)handlderProxy, "v@:@");
    }
    return [super resolveInstanceMethod:sel];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}
// 控制响应的方法
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    for (UIMenuItem *item in self.mul_items) {
        if (item.action == action) {
            return YES;
            break;
        }
    }
    return NO;
}

// 初始化设置
- (void)pressAction {
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(tapAction:)];
    [self addGestureRecognizer:gesture];
}
- (void)tapAction:(UIGestureRecognizer *)recognizer {
    [self becomeFirstResponder];
    [[UIMenuController sharedMenuController] setMenuItems:self.mul_items];
    [[UIMenuController sharedMenuController] setTargetRect:self.frame inView:self.superview];
    [[UIMenuController sharedMenuController] setMenuVisible:YES animated:YES];
}
- (NSMutableArray<UIMenuItem *> *)mul_items {
    if (!_mul_items) {
        _mul_items = [NSMutableArray array];
    }
    return _mul_items;
}


@end

