//
//  AXDScrollPageView.h
//  JODevelop
//
//  Created by JimmyOu on 2017/5/11.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Extension.h"
#import "AXDContentView.h"
#import "AXDScrollSegmentView.h"
#import "AXDScrollPageViewDelegate.h"

typedef void(^ExtraBtnOnClick)(UIButton *extraBtn);

@interface AXDScrollPageView : UIView

/** 必须设置代理并且实现相应的方法*/
@property(weak, nonatomic)id<AXDScrollPageViewDelegate> delegate;
@property (copy, nonatomic) ExtraBtnOnClick extraBtnOnClick;
@property (weak, nonatomic, readonly) AXDContentView *contentView;
@property (weak, nonatomic, readonly) AXDScrollSegmentView *segmentView;
/** 预加载机制，在停止滑动的时候预加载 n 页 */
@property (nonatomic, assign) AXDPagePreloadPolicy preloadPolicy;
/* 缓存策略 */
@property (nonatomic, assign) AXDPageCachePolicy cachePolicy;
- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray<NSString *> *)titles childVC:(NSArray<Class> *)childVcs parentViewController:(UIViewController *)parentViewController delegate:(id<AXDScrollPageViewDelegate>)delegate ;

/** 给外界设置选中的下标的方法 */
- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated;

/**  给外界重新设置的标题的方法(同时会重新加载页面的内容) */
- (void)reloadWithNewTitles:(NSArray<NSString *> *)newTitles;

@end
