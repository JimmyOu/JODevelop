//
//  AXDContentView.h
//  JODevelop
//
//  Created by JimmyOu on 2017/5/11.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AXDScrollSegmentView.h"
#import "AXDScrollPageViewDelegate.h"
#import "AXDCollectionView.h"


@interface AXDContentView : UIView

/** 必须设置代理和实现相关的方法*/
@property(weak, nonatomic)id<AXDScrollPageViewDelegate> delegate;
@property (strong, nonatomic, readonly) AXDCollectionView *collectionView;
// 当前控制器
@property (strong, nonatomic, readonly) UIViewController<AXDScrollPageViewChildVcDelegate> *currentChildVc;

/*
 *初始化方法
 */
- (instancetype)initWithFrame:(CGRect)frame segmentView:(AXDScrollSegmentView *)segmentView parentViewController:(UIViewController *)parentViewController delegate:(id<AXDScrollPageViewDelegate>) delegate;

/** 给外界可以设置ContentOffSet的方法 */
- (void)setContentOffSet:(CGPoint)offset animated:(BOOL)animated;

/** 给外界 重新加载内容的方法 */
- (void)reload;


@end
