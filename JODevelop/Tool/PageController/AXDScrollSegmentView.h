//
//  AXDScrollSegmentView.h
//  JODevelop
//
//  Created by JimmyOu on 2017/5/11.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AXDScrollPageViewDelegate.h"
@class AXDTitleView;

typedef void(^TitleBtnOnClickBlock)(AXDTitleView *titleView, NSInteger index);
typedef void(^ExtraBtnOnClick)(UIButton *extraBtn);
@interface AXDScrollSegmentView : UIView

// 所有的标题
@property (strong, nonatomic) NSArray *titles;
@property (copy, nonatomic) ExtraBtnOnClick extraBtnOnClick;

@property (weak, nonatomic) id<AXDScrollPageViewDelegate> delegate;

// init  方法
- (instancetype)initWithFrame:(CGRect )frame delegate:(id<AXDScrollPageViewDelegate>)delegate titles:(NSArray *)titles titleDidClick:(TitleBtnOnClickBlock)titleDidClick;

/** 切换下标的时候根据progress同步设置UI*/
- (void)adjustUIWithProgress:(CGFloat)progress oldIndex:(NSInteger)oldIndex currentIndex:(NSInteger)currentIndex;
/** 让选中的标题居中*/
- (void)adjustTitleOffSetToCurrentIndex:(NSInteger)currentIndex;

/** 设置选中的下标*/
- (void)setSelectedIndex:(NSInteger)index animated:(BOOL)animated;
/** 重新刷新标题的内容*/
- (void)reloadTitlesWithNewTitles:(NSArray *)titles;

@end
