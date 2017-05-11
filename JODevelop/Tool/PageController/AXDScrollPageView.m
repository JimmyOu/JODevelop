//
//  AXDScrollPageView.m
//  JODevelop
//
//  Created by JimmyOu on 2017/5/11.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "AXDScrollPageView.h"
#import "AXDScrollPageConst.h"
@interface AXDScrollPageView ()

@property (weak, nonatomic) AXDScrollSegmentView *segmentView;
@property (weak, nonatomic) AXDContentView *contentView;

@property (weak, nonatomic) UIViewController *parentViewController;
@property (strong, nonatomic) NSArray *childVcs;
@property (strong, nonatomic) NSArray *titlesArray;

@end
@implementation AXDScrollPageView

- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray<NSString *> *)titles parentViewController:(UIViewController *)parentViewController delegate:(id<AXDScrollPageViewDelegate>)delegate {
    if (self = [super initWithFrame:frame]) {
        self.delegate = delegate;
        self.parentViewController = parentViewController;
        self.titlesArray = titles.copy;
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    
    // 触发懒加载
    self.segmentView.backgroundColor = [UIColor whiteColor];
    self.contentView.backgroundColor = [UIColor whiteColor];
}

- (void)dealloc {
    NSLog(@"%@ dealloc",[self class]);
}


#pragma mark - public helper

/** 给外界设置选中的下标的方法 */
- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated {
    [self.segmentView setSelectedIndex:selectedIndex animated:animated];
}

/**  给外界重新设置视图内容的标题的方法 */
- (void)reloadWithNewTitles:(NSArray<NSString *> *)newTitles {
    
    self.titlesArray = nil;
    self.titlesArray = newTitles.copy;
    
    [self.segmentView reloadTitlesWithNewTitles:self.titlesArray];
    [self.contentView reload];
}


#pragma mark - getter ---- setter

- (AXDContentView *)contentView {
    if (!_contentView) {
        AXDContentView *content = [[AXDContentView alloc] initWithFrame:CGRectMake(0.0, CGRectGetMaxY(self.segmentView.frame), self.bounds.size.width, self.bounds.size.height - CGRectGetMaxY(self.segmentView.frame)) segmentView:self.segmentView parentViewController:self.parentViewController delegate:self.delegate];
        [self addSubview:content];
        _contentView = content;
    }
    
    return  _contentView;
}


- (AXDScrollSegmentView *)segmentView {
    if (!_segmentView) {
        __weak typeof(self) weakSelf = self;
        AXDScrollSegmentView *segment = [[AXDScrollSegmentView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, kAXDSegmentHeight) delegate:self.delegate titles:self.titlesArray titleDidClick:^(AXDTitleView *titleView, NSInteger index) {
            
            [weakSelf.contentView setContentOffSet:CGPointMake(weakSelf.contentView.bounds.size.width * index, 0.0) animated:YES];
            
        }];
        [self addSubview:segment];
        _segmentView = segment;
    }
    return _segmentView;
}


- (NSArray *)childVcs {
    if (!_childVcs) {
        _childVcs = [NSArray array];
    }
    return _childVcs;
}

- (NSArray *)titlesArray {
    if (!_titlesArray) {
        _titlesArray = [NSArray array];
    }
    return _titlesArray;
}

- (void)setExtraBtnOnClick:(ExtraBtnOnClick)extraBtnOnClick {
    _extraBtnOnClick = extraBtnOnClick;
    self.segmentView.extraBtnOnClick = extraBtnOnClick;
}




@end
