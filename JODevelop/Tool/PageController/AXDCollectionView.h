//
//  AXDCollectionView.h
//  JODevelop
//
//  Created by JimmyOu on 2017/5/11.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AXDCollectionView : UICollectionView

typedef BOOL(^AXDScrollViewShouldBeginPanGestureHandler)(AXDCollectionView *collectionView, UIPanGestureRecognizer *panGesture);

- (void)setupScrollViewShouldBeginPanGestureHandler:(AXDScrollViewShouldBeginPanGestureHandler)gestureBeginHandler;

@end
