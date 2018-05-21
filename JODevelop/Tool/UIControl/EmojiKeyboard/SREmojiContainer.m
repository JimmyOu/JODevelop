//
//  SREmojiContainer.m
//  JODevelop
//
//  Created by JimmyOu on 2018/2/5.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import "SREmojiContainer.h"
#import "NEPageControl.h"
#import "SREmojiCell.h"
#import "Masonry.h"
@interface SREmojiContainer()<UICollectionViewDelegate, UICollectionViewDataSource,EmojiCellDelegate>
@property (strong, nonatomic) NEPageControl *pageControl;
@property (strong, nonatomic) UICollectionView *collectionV;
@property (nonatomic, strong) NSArray *emojis;
@property (assign, nonatomic) NSInteger emojiIndex;
//@property (assign, nonatomic) <#type#> <#name#>;

- (void)EmojiBtnPressed:(id)sender;

@end
@implementation SREmojiContainer

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupEnvi];
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setupEnvi];
        [self setupUI];
    }
    return self;
}
- (void)setupEnvi {
    NSString *path = nil;
    NSString *str = nil;
    NSArray *list = nil;
    
    // emoji
    path = [[NSBundle mainBundle] pathForResource:@"emoji" ofType:@"txt"];
    str = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    list = [str componentsSeparatedByString:@","];
    _emojis = list;
    [self setBackgroundColor:colorWithIntegerRGB(0xf5, 0xf5, 0xf5)];
    
    [self addSubview:self.collectionV];
    [self.collectionV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self);
        make.right.mas_equalTo(self);
        make.top.mas_equalTo(self);
        make.height.mas_equalTo(160);
    }];
    [self.collectionV reloadData];
    
    [self setupPageControl:([_emojis count] + kEmojiPageBtnCount - 1) / kEmojiPageBtnCount];
    
}

- (UICollectionView *)collectionV {
    if (!_collectionV) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        _collectionV.showsHorizontalScrollIndicator = NO;
        _collectionV.showsVerticalScrollIndicator = NO;
        _collectionV = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionV.delegate = self;
        _collectionV.dataSource = self;
        [_collectionV registerClass:[SREmojiCell class] forCellWithReuseIdentifier:NSStringFromClass([SREmojiCell class])];
        [_collectionV setPagingEnabled:YES];
        _collectionV.backgroundColor = [UIColor clearColor];
    }
    return _collectionV;
}


- (void)setupUI {
    
}


- (void)setupPageControl:(NSUInteger)page {
    if (_pageControl.superview != nil) {
        [_pageControl removeFromSuperview];
    }
    if (page < 2)
        return;
    float width = (page - 1) * 10 + page * 6; // 10是间距，6是小圆点diameter
    
    CGFloat top = 167.5;
    self.pageControl = [[NEPageControl alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - width) / 2, top , width, 6.f)];
    [self.pageControl setBackgroundColor:[UIColor clearColor]];
    [self.pageControl setOnImage:[UIImage imageNamed:@"emoji_dot_on"]];
    [self.pageControl setOffImage:[UIImage imageNamed:@"emoji_dot_off"]];
    [self.pageControl setOffset:10.f];
    [self.pageControl setNumberOfPages:page];
    [self.pageControl setCurrentPage:0];
    [self addSubview:_pageControl];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return ([_emojis count] + kEmojiPageBtnCount - 1) / kEmojiPageBtnCount;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *pageTexts = [self getEmojisByPage:(int)indexPath.section emojis:_emojis];
    SREmojiCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([SREmojiCell class]) forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor clearColor];
    [cell setDelegate:self];
    [cell SetupButtons:pageTexts];
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView != _collectionV) {
        return;
    }
    CGFloat Width_Screen = [UIScreen mainScreen].bounds.size.width;
    int currentIndex = 0;
    NSInteger offset = floor(scrollView.contentOffset.x);
    if (offset > 0) {
        currentIndex = offset/floor(Width_Screen);
        if (scrollView.contentOffset.x - currentIndex * Width_Screen > 0.5 * Width_Screen) {
            currentIndex++;
        }
    }
    _emojiIndex = currentIndex;
    [self.pageControl setCurrentPage:currentIndex];
}

#pragma mark - UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake([UIScreen mainScreen].bounds.size.width, 143.0);
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark - EmojiCellDelegate
- (void)EmojiInputDel:(SREmojiCell *)cell {
    if ([_delegate respondsToSelector:@selector(delBtnPressedInView:)]) {
        [_delegate performSelector:@selector(delBtnPressedInView:) withObject:self];
    }
}

- (void)EmojiInputAtCell:(SREmojiCell *)cell text:(NSString *)text {

    if ([_delegate respondsToSelector:@selector(inputStringInView: text:)]) {
        [_delegate performSelector:@selector(inputStringInView: text:) withObject:self withObject:text];
    }
}


- (NSArray *)getEmojisByPage:(int)pageIndex emojis:(NSArray *)emojiArr {
    NSMutableArray *page = [[NSMutableArray alloc] init];
    NSInteger count = [emojiArr count];
    for (int i = 0; i < kEmojiPageBtnCount; i++) {
        if ((i + pageIndex * kEmojiPageBtnCount) >= count) {
            break;
        }
        NSString *str = [emojiArr objectAtIndex:(i + pageIndex * kEmojiPageBtnCount)];
        [page addObject:str];
    }
    return page;
}

- (void)EmojiBtnPressed:(id)sender {
//    if (_type == InputTypeEmoji)
//        return;
//    _type = InputTypeEmoji;
//
//    if (_isBlackStyle) {
//        [_emojiBtn setBackgroundColor:colorWithIntegerRGB(0x1A, 0x20, 0x23)];
//        [_yanTextBtn setBackgroundColor:colorWithIntegerRGB(0x24, 0x29, 0x2B)];
//        [_deerGirlBtn setBackgroundColor:colorWithIntegerRGB(0x24, 0x29, 0x2B)];
//    } else {
//        [_emojiBtn setBackgroundColor:colorWithIntegerRGB(0xf5, 0xf5, 0xf5)];
//        [_yanTextBtn setBackgroundColor:colorWithIntegerRGB(0xff, 0xff, 0xff)];
//        [_deerGirlBtn setBackgroundColor:colorWithIntegerRGB(0xff, 0xff, 0xff)];
//    }
//    [_emojiBtn setBackgroundColor:colorWithIntegerRGB(0xf5, 0xf5, 0xf5)];
    [self setupPageControl:([_emojis count] + kEmojiPageBtnCount - 1) / kEmojiPageBtnCount];
    [_collectionV reloadData];
    _emojiIndex = 0;
    [_collectionV setContentOffset:CGPointMake(_emojiIndex * [UIScreen mainScreen].bounds.size.width, 0.0)];
//    self.collectionVHeightLayoutConstraint.constant = 143.0;
    [self.collectionV layoutIfNeeded];
}
@end
