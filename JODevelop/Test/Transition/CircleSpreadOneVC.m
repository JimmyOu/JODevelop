//
//  CircleSpreadOneVC.m
//  JODevelop
//
//  Created by JimmyOu on 17/4/19.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "CircleSpreadOneVC.h"
#import "CircleSpreadTwoVC.h"

@interface CircleSpreadOneVC ()


@end

@implementation CircleSpreadOneVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.button addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(xw_drag:)]];
    [self.button setTitle:@"点我\n拖我" forState:UIControlStateNormal];
    self.button.backgroundColor = [UIColor lightGrayColor];
    self.button.titleLabel.numberOfLines = 0;
    self.button.titleLabel.font = [UIFont systemFontOfSize:12];
    self.button.bounds = CGRectMake(0, 0, 40, 40);
    self.button.center = CGPointMake(self.view.center.x, self.view.center.y - 100);
    self.button.layer.cornerRadius = 20;

}

- (void)xw_transition{
    AXDCircleSpreadAnimator *animator = [AXDCircleSpreadAnimator animatorWithStartCenter:self.button.center radius:20];
    animator.toDuration = 0.5f;
    animator.backDuration = 0.5f;
    CircleSpreadTwoVC *toVC = [CircleSpreadTwoVC new];
    if (self.pushOrPresntSwitch.on) {
        [self.navigationController axd_pushViewController:toVC withAnimator:animator];
    }else{
        [self axd_presentViewController:toVC withAnimator:animator];
    }
}
- (void)xw_drag:(UIPanGestureRecognizer *)panGesture{
    CGPoint transitionP = [panGesture translationInView:panGesture.view];
    CGFloat transitionX = fmax(20, fmin(self.button.center.x + transitionP.x, self.view.bounds.size.width - 20));
    CGFloat transitionY = fmax(64 + 20, fmin(self.button.center.y + transitionP.y, self.view.bounds.size.height - 20));
    self.button.center = CGPointMake(transitionX, transitionY);
    [panGesture setTranslation:CGPointZero inView:panGesture.view];
}


@end
