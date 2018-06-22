//
//  UITableViewCell+JOVideoPlay.m
//  JODevelop
//
//  Created by JimmyOu on 2018/6/21.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "UITableViewCell+JOVideoPlay.h"
#import <objc/runtime.h>

@implementation UITableViewCell (JOVideoPlay)
- (void)setJo_videoURL:(NSURL *)jo_videoURL {
    objc_setAssociatedObject(self, @selector(jo_videoURL), jo_videoURL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSURL *)jo_videoURL {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setJo_videoPlayView:(UIView *)jo_videoPlayView {
    jo_videoPlayView.userInteractionEnabled = YES;
    objc_setAssociatedObject(self, @selector(jo_videoPlayView), jo_videoPlayView, OBJC_ASSOCIATION_ASSIGN);
}
- (UIView *)jo_videoPlayView {
    return objc_getAssociatedObject(self, _cmd);
}
- (JOVideoPlayerUnreachableCellType)jo_unreachableCellType {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}
- (void)setJo_unreachableCellType:(JOVideoPlayerUnreachableCellType)jo_unreachableCellType {
    objc_setAssociatedObject(self, @selector(jo_unreachableCellType), @(jo_unreachableCellType), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end
