//
//  MainViewController.m
//  JODevelop
//
//  Created by JimmyOu on 2017/5/9.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "MainViewController.h"
#import "ReusableViewController.h"
#import "MainViewNavigator.h"

#define TOTAL_PAGES     100
@interface MainViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (strong, nonatomic) NSNumber *currentPage;

@property (strong, nonatomic) NSMutableArray *reusableViewControllers;
@property (strong, nonatomic) NSMutableArray *visibleViewControllers;

@property (nonatomic, assign) NSInteger numberOfInstance;

@property (nonatomic, weak) MainViewNavigator *navigator;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupPages];
    [self loadPage:0];
}


- (void)setupPages
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.scrollView = [UIScrollView new];
    self.scrollView.delegate = self;
    self.scrollView.frame = CGRectMake(0, 60, kScreenWidth, kScreenHeight - 60);
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.bounces = NO;
    self.scrollView.pagingEnabled = YES;
    [self.view addSubview:self.scrollView];
    
    self.scrollView.contentSize = CGSizeMake(kScreenWidth * TOTAL_PAGES, kScreenHeight - 60);
    
    MainViewNavigator *navigator = [[MainViewNavigator alloc] initWithFrame:CGRectMake(0, 60, kScreenWidth, 40)];
    __weak __typeof(self)weakSelf = self;
    navigator.selectedBlock = ^(NSInteger type) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (!strongSelf) return;
        
        [strongSelf loadPage:type];
//        if ([self.currentPage integerValue] > type) { //往前滚动
//          
//            [strongSelf.scrollView setContentOffset:CGPointMake(MIN(MAX((type - 1), 0), TOTAL_PAGES) * strongSelf.scrollView.frame.size.width , 0) animated:NO];
//        } else { //往后滚动
//        
//        }
        [strongSelf.scrollView setContentOffset:CGPointMake(type * strongSelf.scrollView.frame.size.width , 0) animated:NO];
    };
    NSMutableArray *items = [NSMutableArray array];
    for (int i = 0; i < TOTAL_PAGES; i++) {
        [items addObject:@(i)];
    }
    navigator.items = items;
    [self.view addSubview:navigator];
    _navigator = navigator;
    
    

}

- (NSMutableArray *)reusableViewControllers
{
    if (!_reusableViewControllers) {
        _reusableViewControllers = [NSMutableArray array];
    }
    return _reusableViewControllers;
}

- (NSMutableArray *)visibleViewControllers
{
    if (!_visibleViewControllers) {
        _visibleViewControllers = [NSMutableArray array];
    }
    return _visibleViewControllers;
}

- (void)setCurrentPage:(NSNumber *)currentPage
{
    if (_currentPage != currentPage) {
        _currentPage = currentPage;
        //do some work
    }
}

- (void)loadPage:(NSInteger)page
{
    if (self.currentPage && page == [self.currentPage integerValue]) {
        return;
    }
    self.currentPage = @(page);
    NSMutableArray *pagesToLoad = [@[@(page), @(page - 1), @(page + 1)] mutableCopy];
    NSMutableArray *vcsToEnqueue = [NSMutableArray array];
    for (ReusableViewController *vc in self.visibleViewControllers) {
        if (!vc.page || ![pagesToLoad containsObject:vc.page]) {
            [vcsToEnqueue addObject:vc];
        } else if (vc.page) {
            [pagesToLoad removeObject:vc.page];
        }
    }
    for (ReusableViewController *vc in vcsToEnqueue) {
        [vc.view removeFromSuperview];
        [self.visibleViewControllers removeObject:vc];
        [self enqueueReusableViewController:vc];
    }
    for (NSNumber *page in pagesToLoad) {
        [self addViewControllerForPage:[page integerValue]];
    }
}

- (void)enqueueReusableViewController:(ReusableViewController *)viewController
{
    [self.reusableViewControllers addObject:viewController];
}

- (ReusableViewController *)dequeueReusableViewController
{
    ReusableViewController *vc = [self.reusableViewControllers firstObject];
    if (vc) {
        [self.reusableViewControllers removeObject:vc];
    } else {
        vc = [[ReusableViewController alloc] init];
        vc.numberOfInstance = self.numberOfInstance;
        self.numberOfInstance++;
        [vc willMoveToParentViewController:self];
        [self addChildViewController:vc];
        [vc didMoveToParentViewController:self];
    }
    return vc;
}

- (void)addViewControllerForPage:(NSInteger)page
{
    if (page < 0 || page >= TOTAL_PAGES) {
        return;
    }
    ReusableViewController *vc = [self dequeueReusableViewController];
    vc.page = @(page);
    vc.view.frame = CGRectMake(self.scrollView.frame.size.width * page, 0.0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    [self.scrollView addSubview:vc.view];
    [self.visibleViewControllers addObject:vc];
}




- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.scrollView) {
        
        CGFloat navX = scrollView.contentOffset.x / scrollView.frame.size.width * (Home_Seleted_Item_W + 0.5 * DefaultMargin);
        CGPoint center = self.navigator.underLine.center;
        CGPoint newCenter = CGPointMake(navX + 0.5 * Home_Seleted_Item_W, center.y);
        self.navigator.underLine.center = newCenter;
        
        NSInteger page = roundf(scrollView.contentOffset.x / scrollView.frame.size.width);
        page = MAX(page, 0);
        page = MIN(page, TOTAL_PAGES - 1);
        [self loadPage:page];
        
        /*************/
        CGRect frame =  [[self.navigator btnAtIndex:page] frame];
        CGFloat itemX = frame.origin.x;
        CGFloat width = self.navigator.scrollV.frame.size.width;
        CGSize contentSize = self.navigator.scrollV.contentSize;
        if (itemX > width/2) {
            CGFloat targetX;
            if ((contentSize.width-itemX) <= width/2) {
                targetX = contentSize.width - width;
            } else {
                targetX = frame.origin.x - width/2 + frame.size.width/2;
            }
            // 应该有更好的解决方法
            if (targetX + width > contentSize.width) {
                targetX = contentSize.width - width;
            }
            [self.navigator.scrollV setContentOffset:CGPointMake(targetX, 0) animated:YES];
        } else {
            [self.navigator.scrollV setContentOffset:CGPointMake(0, 0) animated:YES];
        }
        
        
        /*************/
    }
}


- (void)dealloc {
    NSLog(@"%@ dealloc",[self class]);
}

@end
