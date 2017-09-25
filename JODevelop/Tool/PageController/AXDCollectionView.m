//
//  AXDCollectionView.m
//  JODevelop
//
//  Created by JimmyOu on 2017/5/11.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "AXDCollectionView.h"

@interface AXDCollectionView ()

@property (copy, nonatomic) AXDScrollViewShouldBeginPanGestureHandler gestureBeginHandler;

@end

@implementation AXDCollectionView

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (_gestureBeginHandler && gestureRecognizer == self.panGestureRecognizer) {
        return _gestureBeginHandler(self, (UIPanGestureRecognizer *)gestureRecognizer);
    }
    else {
        return [super gestureRecognizerShouldBegin:gestureRecognizer];
    }
}

- (void)setupScrollViewShouldBeginPanGestureHandler:(AXDScrollViewShouldBeginPanGestureHandler)gestureBeginHandler {
    _gestureBeginHandler = [gestureBeginHandler copy];
}

@end
