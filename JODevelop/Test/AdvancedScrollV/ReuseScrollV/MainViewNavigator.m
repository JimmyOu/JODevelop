//
//  MainViewNavigator.m
//  JODevelop
//
//  Created by JimmyOu on 2017/5/9.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "MainViewNavigator.h"
#import "UIColor+Extension.h"



@interface MainViewNavigator ()

@property (nonatomic, weak) UIScrollView *scrollV;
@property (nonatomic, weak)UIView *underLine;
@property (nonatomic, strong)UIButton *selectedBtn;
@property (nonatomic, weak)UIButton *firstBtn;



@end
@implementation MainViewNavigator

- (UIView *)underLine {
    if (!_underLine) {
        UIView *underLine = [[UIView alloc] initWithFrame:CGRectMake(DefaultMargin * 0.5, self.bounds.size.height - 4, Home_Seleted_Item_W - DefaultMargin, 2)];
        underLine.backgroundColor = [UIColor redColor];
        [self.scrollV addSubview:underLine];
        _underLine = underLine;
    }
    return _underLine;
}

- (UIScrollView *)scrollV {
    if (!_scrollV) {
        UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:self.bounds];
        scroll.showsVerticalScrollIndicator = NO;
        scroll.showsHorizontalScrollIndicator = NO;
        scroll.backgroundColor = [UIColor whiteColor];
        [self addSubview:scroll];
        _scrollV = scroll;
    }
    return _scrollV;
}

- (void)setItems:(NSArray *)items {
    if (_items != items) {
        _items = items;
        [self setup];
    }
}

- (void)setup {
    
    self.scrollV.contentSize = CGSizeMake((Home_Seleted_Item_W + 0.5 * DefaultMargin) * _items.count - 0.5 * DefaultMargin, self.bounds.size.height);
    CGFloat x = 0;
    for (int i = 0; i < _items.count; i++) {
        NSNumber *number = _items[i];
        CGRect frame = CGRectMake(x, 0.5 * DefaultMargin, Home_Seleted_Item_W, self.frame.size.height - DefaultMargin);
        x += Home_Seleted_Item_W +  0.5 * DefaultMargin;
        UIButton *btn = [self createBtn:[NSString stringWithFormat:@"%@",number] tag:[number integerValue]];
        btn.backgroundColor = [UIColor randomColor];
        btn.frame = frame;
        if (i == 0) {
            _firstBtn = btn;
        }
        [self.scrollV addSubview:btn];
    }
    // 默认选中第一个
    [self click:_firstBtn];

}

- (UIButton *)createBtn:(NSString *)title tag:(NSInteger)tag
{
    UIButton *btn = [[UIButton alloc] init];
    btn.titleLabel.font = [UIFont systemFontOfSize:17];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[[UIColor blackColor] colorWithAlphaComponent:0.6] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    btn.tag = tag;
    [btn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}
- (void)setIndex:(int)index {
    _index = index;
    self.selectedBtn.selected = NO;
    for (UIView *view in self.scrollV.subviews) {
        if ([view isKindOfClass:[UIButton class]
             ] && view.tag == index) {
            self.selectedBtn = (UIButton *)view;
            self.selectedBtn.selected = YES;
        }
    }
}

//点击事件
- (void)click:(UIButton *)btn {
    self.selectedBtn.selected = NO;
    btn.selected = YES;
    self.selectedBtn = btn;
    
    [UIView animateWithDuration:0.5 animations:^{
        CGPoint center = self.underLine.center;
       CGPoint newCenter = CGPointMake(btn.center.x, center.y);
        self.underLine.center = newCenter;
    }];
    
    if (self.selectedBlock) {
        self.selectedBlock(btn.tag);
    }
}

- (UIButton *)btnAtIndex:(NSInteger)index {
    UIButton *btnAtIndex ;
    for (UIView *view in self.scrollV.subviews) {
        if ([view isKindOfClass:[UIButton class]
             ] && view.tag == index) {
            btnAtIndex = (UIButton *)view;
            break;
        }
    }
    return btnAtIndex ;
}

@end
