//
//  AXDScrollSegmentView.m
//  JODevelop
//
//  Created by JimmyOu on 2017/5/11.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "AXDScrollSegmentView.h"
#import "AXDTitleView.h"
#import "AXDScrollPageConst.h"

@interface AXDScrollSegmentView ()<UIScrollViewDelegate> {
    CGFloat _currentWidth;
    NSUInteger _currentIndex;
    NSUInteger _oldIndex;
    UIColor *_segmentNormalTitleColor;
    UIColor *_segmentSelectedTitleColor;
    UIColor *_scrollLineColor;
    
}


// 滚动条
@property (strong, nonatomic) UIView *scrollLine;
// 滚动scrollView
@property (strong, nonatomic) UIScrollView *scrollView;

// 附加的按钮
@property (strong, nonatomic) UIButton *extraBtn;

// 用于懒加载计算文字的rgba差值, 用于颜色渐变的时候设置
@property (strong, nonatomic) NSArray *deltaRGBA;
@property (strong, nonatomic) NSArray *selectedColorRGBA;
@property (strong, nonatomic) NSArray *normalColorRGBA;
/** 缓存所有标题label */
@property (nonatomic, strong) NSMutableArray *titleViews;
// 缓存计算出来的每个标题的宽度
@property (nonatomic, strong) NSMutableArray *titleWidths;
// 响应标题点击
@property (copy, nonatomic) TitleBtnOnClickBlock titleBtnOnClick;

@end

@implementation AXDScrollSegmentView
static CGFloat const contentSizeXOff = 20.0;

- (instancetype)initWithFrame:(CGRect)frame delegate:(id<AXDScrollPageViewDelegate>)delegate titles:(NSArray *)titles titleDidClick:(TitleBtnOnClickBlock)titleDidClick {
    if (self = [super initWithFrame:frame]) {
        self.titles = titles;
        self.titleBtnOnClick = titleDidClick;
        self.delegate = delegate;
        _currentIndex = 0;
        _oldIndex = 0;
        _currentWidth = frame.size.width;
        _segmentNormalTitleColor = [UIColor colorWithRed:51.0/255.0 green:53.0/255.0 blue:75/255.0 alpha:1.0];
        _segmentSelectedTitleColor = [UIColor colorWithRed:255.0/255.0 green:0.0/255.0 blue:121/255.0 alpha:1.0];
        _scrollLineColor = [UIColor brownColor];
        // 设置了frame之后可以直接设置其他的控件的frame了, 不需要在layoutsubView()里面设置
        [self setupSubviews];
        [self setupUI];
        
    }
    return self;
}

- (void)setupSubviews {
    
    [self addSubview:self.scrollView];
    [self addScrollLineOrExtraBtn];
    [self setupTitles];
}

- (void)addScrollLineOrExtraBtn {
    [self.scrollView addSubview:self.scrollLine];
    [self addSubview:self.extraBtn];
}

- (void)dealloc {
    NSLog(@"%@ dealloc",[self class]);
}


#pragma mark - button action

- (void)titleLabelOnClick:(UITapGestureRecognizer *)tapGes {
    
    AXDTitleView *currentLabel = (AXDTitleView *)tapGes.view;
    
    if (!currentLabel) {
        return;
    }
    
    _currentIndex = currentLabel.tag;
    
    [self adjustUIWhenBtnOnClickWithAnimate:true taped:YES];
}

- (void)extraBtnOnClick:(UIButton *)extraBtn {
    
    if (self.extraBtnOnClick) {
        self.extraBtnOnClick(extraBtn);
    }
}

- (void)setupTitles {
    if (self.titles.count == 0) return;
    
    NSInteger index = 0;
    for (NSString *title in self.titles) {
        
        AXDTitleView *titleView = [[AXDTitleView alloc] initWithFrame:CGRectZero];
        titleView.tag = index;
        
        titleView.font = [UIFont systemFontOfSize:kAXDSegmentTitleFontSize];
        titleView.text = title;
        titleView.textColor = _segmentNormalTitleColor;
        
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(setUpTitleView:forIndex:)]) {
            [self.delegate setUpTitleView:titleView forIndex:index];
        }
        
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleLabelOnClick:)];
        [titleView addGestureRecognizer:tapGes];
        
        CGFloat titleViewWidth = [titleView titleViewWidth];
        [self.titleWidths addObject:@(titleViewWidth)];
        
        [self.titleViews addObject:titleView];
        [self.scrollView addSubview:titleView];
        
        index++;
        
    }
    

}

- (void)setupUI {
    if (self.titles.count == 0) return;
    
    [self setupScrollViewAndExtraBtn];
    [self setUpTitleViewsPosition];
    [self setupScrollLineAndCover];
    
    // 设置滚动区域
    AXDTitleView *lastTitleView = (AXDTitleView *)self.titleViews.lastObject;
    
    if (lastTitleView) {
        self.scrollView.contentSize = CGSizeMake(CGRectGetMaxX(lastTitleView.frame) + contentSizeXOff, 0.0);
    }
}

- (void)setupScrollViewAndExtraBtn {
    CGFloat extraBtnW = 44.0;
    CGFloat extraBtnY = 5.0;
    
    CGFloat scrollW = self.extraBtn ? _currentWidth - extraBtnW : _currentWidth;

    self.scrollView.frame = CGRectMake(0.0, 0.0, scrollW, self.height);
    
    if (self.extraBtn) {
        self.extraBtn.frame = CGRectMake(scrollW , extraBtnY, extraBtnW, self.height - 2*extraBtnY);
    }
}

- (void)setUpTitleViewsPosition {
    CGFloat titleX = 0.0;
    CGFloat titleY = 0.0;
    CGFloat titleW = 0.0;
    CGFloat titleH = self.height - kAXDSegmentScrollLineHeight;
    
    NSInteger index = 0;
    float lastLableMaxX = kAXDSegmentTitleFontMargin;
    float addedMargin = 0.0f;
    
    for (AXDTitleView *titleView in self.titleViews) {
        titleW = [self.titleWidths[index] floatValue];
        titleX = lastLableMaxX + addedMargin/2;
        
        lastLableMaxX += (titleW + addedMargin + kAXDSegmentTitleFontMargin);
        
        titleView.frame = CGRectMake(titleX, titleY, titleW, titleH);
        index++;
        
    }
    
    AXDTitleView *currentTitleView = (AXDTitleView *)self.titleViews[_currentIndex];
    if (currentTitleView) {
        // 设置初始状态文字的颜色
        currentTitleView.textColor = _segmentSelectedTitleColor;
    }
    
}

- (void)setupScrollLineAndCover {
    
    AXDTitleView *firstLabel = (AXDTitleView *)self.titleViews[0];
    CGFloat coverX = firstLabel.x;
    CGFloat coverW = firstLabel.width;
    if (self.scrollLine) {
        self.scrollLine.frame = CGRectMake(coverX , self.height - kAXDSegmentScrollLineHeight, coverW , kAXDSegmentScrollLineHeight);
    }
    
}

- (void)adjustUIWhenBtnOnClickWithAnimate:(BOOL)animated taped:(BOOL)taped {
    if (_currentIndex == _oldIndex && taped) { return; }
    
    AXDTitleView *oldTitleView = (AXDTitleView *)self.titleViews[_oldIndex];
    AXDTitleView *currentTitleView = (AXDTitleView *)self.titleViews[_currentIndex];
    
    CGFloat animatedTime = animated ? 0.30 : 0.0;
    
    __weak typeof(self) weakSelf = self;
    
    [UIView animateWithDuration:animatedTime animations:^{
        oldTitleView.textColor = _segmentNormalTitleColor;
        currentTitleView.textColor = _segmentSelectedTitleColor;
        oldTitleView.selected = NO;
        currentTitleView.selected = YES;
        
        if (weakSelf.scrollLine) {
            weakSelf.scrollLine.x = currentTitleView.x;
            weakSelf.scrollLine.width = currentTitleView.width;
        }
        
    } completion:^(BOOL finished) {
        [weakSelf adjustTitleOffSetToCurrentIndex:_currentIndex];
        
    }];
    
    _oldIndex = _currentIndex;
    if (self.titleBtnOnClick) {
        self.titleBtnOnClick(currentTitleView, _currentIndex);
    }
}

#pragma mark - public helper

- (void)adjustUIWithProgress:(CGFloat)progress oldIndex:(NSInteger)oldIndex currentIndex:(NSInteger)currentIndex {
    if (oldIndex < 0 ||
        oldIndex >= self.titles.count ||
        currentIndex < 0 ||
        currentIndex >= self.titles.count
        ) {
        return;
    }
    _oldIndex = currentIndex;
    
    AXDTitleView *oldTitleView = (AXDTitleView *)self.titleViews[oldIndex];
    AXDTitleView *currentTitleView = (AXDTitleView *)self.titleViews[currentIndex];
    
    
    CGFloat xDistance = currentTitleView.x - oldTitleView.x;
    CGFloat wDistance = currentTitleView.width - oldTitleView.width;
    
    if (self.scrollLine) {
        self.scrollLine.x = oldTitleView.x + xDistance * progress;
        self.scrollLine.width = oldTitleView.width + wDistance * progress;
    }
    
    // 渐变
    oldTitleView.textColor = [UIColor
                              colorWithRed:[self.selectedColorRGBA[0] floatValue] + [self.deltaRGBA[0] floatValue] * progress
                              green:[self.selectedColorRGBA[1] floatValue] + [self.deltaRGBA[1] floatValue] * progress
                              blue:[self.selectedColorRGBA[2] floatValue] + [self.deltaRGBA[2] floatValue] * progress
                              alpha:[self.selectedColorRGBA[3] floatValue] + [self.deltaRGBA[3] floatValue] * progress];
    
    currentTitleView.textColor = [UIColor
                                  colorWithRed:[self.normalColorRGBA[0] floatValue] - [self.deltaRGBA[0] floatValue] * progress
                                  green:[self.normalColorRGBA[1] floatValue] - [self.deltaRGBA[1] floatValue] * progress
                                  blue:[self.normalColorRGBA[2] floatValue] - [self.deltaRGBA[2] floatValue] * progress
                                  alpha:[self.normalColorRGBA[3] floatValue] - [self.deltaRGBA[3] floatValue] * progress];
    
}

- (void)adjustTitleOffSetToCurrentIndex:(NSInteger)currentIndex {
    _oldIndex = currentIndex;
    // 重置渐变/缩放效果附近其他item的缩放和颜色
    int index = 0;
    for (AXDTitleView *titleView in _titleViews) {
        if (index != currentIndex) {
            titleView.textColor = _segmentNormalTitleColor;
            titleView.selected = NO;
            
        }
        else {
            titleView.textColor = _segmentSelectedTitleColor;
            titleView.selected = YES;
        }
        index++;
    }
    
    if (self.scrollView.contentSize.width != self.scrollView.bounds.size.width + contentSizeXOff) {// 需要滚动
        AXDTitleView *currentTitleView = (AXDTitleView *)_titleViews[currentIndex];
        
        CGFloat offSetx = currentTitleView.center.x - _currentWidth * 0.5;
        if (offSetx < 0) {
            offSetx = 0;
            
        }
        CGFloat extraBtnW = self.extraBtn ? self.extraBtn.width : 0.0;
        CGFloat maxOffSetX = self.scrollView.contentSize.width - (_currentWidth - extraBtnW);
        
        if (maxOffSetX < 0) {
            maxOffSetX = 0;
        }
        
        if (offSetx > maxOffSetX) {
            offSetx = maxOffSetX;
        }

        [self.scrollView setContentOffset:CGPointMake(offSetx, 0.0) animated:YES];
    }
}

- (void)setSelectedIndex:(NSInteger)index animated:(BOOL)animated {
    NSAssert(index >= 0 && index < self.titles.count, @"设置的下标不合法!!");
    
    if (index < 0 || index >= self.titles.count) {
        return;
    }
    
    _currentIndex = index;
    [self adjustUIWhenBtnOnClickWithAnimate:animated taped:NO];
}

- (void)reloadTitlesWithNewTitles:(NSArray *)titles {
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    _currentIndex = 0;
    _oldIndex = 0;
    self.titleWidths = nil;
    self.titleViews = nil;
    self.titles = nil;
    self.titles = [titles copy];
    if (self.titles.count == 0) return;
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    [self setupSubviews];
    [self setupUI];
    [self setSelectedIndex:0 animated:YES];
    
}

#pragma mark - getter --- setter

- (UIView *)scrollLine {

    if (!_scrollLine) {
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = _scrollLineColor;
        
        _scrollLine = lineView;
        
    }
    
    return _scrollLine;
}


- (UIButton *)extraBtn {

    if (!_extraBtn) {
        UIButton *btn = [UIButton new];
        [btn addTarget:self action:@selector(extraBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
        NSString *imageName = @"..... to fix ........";
        [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor whiteColor];
        // 设置边缘的阴影效果
        btn.layer.shadowColor = [UIColor whiteColor].CGColor;
        btn.layer.shadowOffset = CGSizeMake(-5, 0);
        btn.layer.shadowOpacity = 1;
        
        _extraBtn = btn;
    }
    return _extraBtn;
}

- (UIScrollView *)scrollView {
    
    if (!_scrollView) {
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.scrollsToTop = NO;
        scrollView.bounces = YES;
        scrollView.pagingEnabled = NO;
        scrollView.delegate = self;
        _scrollView = scrollView;
    }
    return _scrollView;
}


- (NSMutableArray *)titleViews
{
    if (_titleViews == nil) {
        _titleViews = [NSMutableArray array];
    }
    return _titleViews;
}

- (NSMutableArray *)titleWidths
{
    if (_titleWidths == nil) {
        _titleWidths = [NSMutableArray array];
    }
    return _titleWidths;
}

- (NSArray *)deltaRGBA {
    if (_deltaRGBA == nil) {
        NSArray *normalColorRgb = self.normalColorRGBA;
        NSArray *selectedColorRgb = self.selectedColorRGBA;
        
        NSArray *delta;
        if (normalColorRgb && selectedColorRgb) {
            CGFloat deltaR = [normalColorRgb[0] floatValue] - [selectedColorRgb[0] floatValue];
            CGFloat deltaG = [normalColorRgb[1] floatValue] - [selectedColorRgb[1] floatValue];
            CGFloat deltaB = [normalColorRgb[2] floatValue] - [selectedColorRgb[2] floatValue];
            CGFloat deltaA = [normalColorRgb[3] floatValue] - [selectedColorRgb[3] floatValue];
            delta = [NSArray arrayWithObjects:@(deltaR), @(deltaG), @(deltaB), @(deltaA), nil];
            _deltaRGBA = delta;
            
        }
    }
    return _deltaRGBA;
}

- (NSArray *)normalColorRGBA {
    if (!_normalColorRGBA) {
        
        NSArray *normalColorRGBA = [self getColorRGBA:_segmentNormalTitleColor];
        NSAssert(normalColorRGBA, @"设置普通状态的文字颜色时 请使用RGBA空间的颜色值");
        _normalColorRGBA = normalColorRGBA;
        
    }
    return  _normalColorRGBA;
}

- (NSArray *)selectedColorRGBA {
    if (!_selectedColorRGBA) {
        NSArray *selectedColorRGBA = [self getColorRGBA:_segmentSelectedTitleColor];
        NSAssert(selectedColorRGBA, @"设置选中状态的文字颜色时 请使用RGBA空间的颜色值");
        _selectedColorRGBA = selectedColorRGBA;
        
    }
    return  _selectedColorRGBA;
}

- (NSArray *)getColorRGBA:(UIColor *)color {
    CGFloat numOfcomponents = CGColorGetNumberOfComponents(color.CGColor);
    NSArray *rgbaComponents;
    if (numOfcomponents == 4) {
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        rgbaComponents = [NSArray arrayWithObjects:@(components[0]), @(components[1]), @(components[2]), @(components[3]), nil];
    }
    return rgbaComponents;
    
}




@end
