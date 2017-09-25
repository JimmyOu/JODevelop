//
//  MainViewNavigator.h
//  JODevelop
//
//  Created by JimmyOu on 2017/5/9.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import <UIKit/UIKit.h>

// 首页的选择器的宽度
#define Home_Seleted_Item_W 60

#define DefaultMargin       10

@interface MainViewNavigator : UIView

@property (nonatomic, weak, readonly) UIScrollView *scrollV;



/** 选中了 */
@property (nonatomic, copy) void (^selectedBlock)(NSInteger type);
/** 下划线 */
@property (nonatomic, weak, readonly)UIView *underLine;
/** 设置滑动选中的按钮 */
@property(nonatomic, assign) int index;

@property (nonatomic, strong) NSArray *items;

- (UIButton *)btnAtIndex:(NSInteger)index;


@end
