//
//  AXDScrollPageViewDelegate.h
//  JODevelop
//
//  Created by JimmyOu on 2017/5/11.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AXDContentView;
@class AXDTitleView;
@class AXDCollectionView;


@protocol AXDScrollPageViewChildVcDelegate <NSObject>

@property (nonatomic, weak, readonly) UIViewController *scrollViewController;
@property (nonatomic, assign) NSInteger currentIndex;

@optional

/**
 * 请注意: 如果你希望所有的子控制器的view的系统生命周期方法被正确的调用
 * 请重写父控制器的'shouldAutomaticallyForwardAppearanceMethods'方法 并且返回NO
 * 当然如果你不做这个操作, 子控制器的生命周期方法将不会被正确的调用
 * 如果你仍然想利用子控制器的生命周期方法, 请使用'AXDScrollPageViewChildVcDelegate'提供的代理方法
 * 或者'AXDScrollPageViewDelegate'提供的代理方法
 */
- (void)viewWillAppearForIndex:(NSInteger)index;
- (void)viewDidAppearForIndex:(NSInteger)index;
- (void)viewWillDisappearForIndex:(NSInteger)index;
- (void)viewDidDisappearForIndex:(NSInteger)index;

- (void)viewDidLoadForIndex:(NSInteger)index;

@end


@protocol AXDScrollPageViewDelegate <NSObject>
/** 将要显示的子页面的总数 */
- (NSInteger)numberOfChildViewControllers;

/** 获取到将要显示的页面的控制器
 * -reuseViewController : 这个是返回给你的controller, 你应该首先判断这个是否为nil, 如果为nil 创建对应的控制器并返回, 如果不为nil直接使用并返回
 * -index : 对应的下标
 */
- (UIViewController<AXDScrollPageViewChildVcDelegate> *)childViewController:(UIViewController<AXDScrollPageViewChildVcDelegate> *)reuseViewController forIndex:(NSInteger)index;

@optional


- (BOOL)scrollPageController:(UIViewController *)scrollPageController contentScrollView:(AXDCollectionView *)scrollView shouldBeginPanGesture:(UIPanGestureRecognizer *)panGesture;

- (void)setUpTitleView:(AXDTitleView *)titleView forIndex:(NSInteger)index;

/**
 *  页面将要出现
 */
- (void)scrollPageController:(UIViewController *)scrollPageController childViewControllWillAppear:(UIViewController *)childViewController forIndex:(NSInteger)index;
/**
 *  页面已经出现
 */
- (void)scrollPageController:(UIViewController *)scrollPageController childViewControllDidAppear:(UIViewController *)childViewController forIndex:(NSInteger)index;

- (void)scrollPageController:(UIViewController *)scrollPageController childViewControllWillDisappear:(UIViewController *)childViewController forIndex:(NSInteger)index;
- (void)scrollPageController:(UIViewController *)scrollPageController childViewControllDidDisappear:(UIViewController *)childViewController forIndex:(NSInteger)index;
/**
 *  页面添加到父视图时，在父视图中显示的位置
 *  @param  containerView   childController 的 self.view 父视图
 *  @return 返回最终显示的位置
 */
- (CGRect)frameOfChildControllerForContainer:(UIView *)containerView;
@end


