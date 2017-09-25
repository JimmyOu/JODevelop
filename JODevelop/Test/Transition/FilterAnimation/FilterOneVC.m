//
//  FilterOneVC.m
//  JODevelop
//
//  Created by JimmyOu on 17/4/24.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "FilterOneVC.h"
#import "AXDFilterAnimator.h"
#import "FilterTwoVC.h"

@interface FilterOneVC ()

@end

@implementation FilterOneVC

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *directionNames = @[@"下",@"右", @"右", @"下", @"下", @"下", @"右", @"右", @"右"];
    [self.button setTitle:[NSString stringWithFormat:@"点我或向%@滑动", directionNames[_type]] forState:UIControlStateNormal];
    [self.button addTarget:self action:@selector(xw_transition) forControlEvents:UIControlEventTouchUpInside];
    __weak __typeof(self)weakSelf = self;
    [self axd_registerToInteractiveTransitionWithDirection:[self xw_getDirectionWithName:directionNames[_type]] transitonBlock:^(CGPoint startPoint){
        [weakSelf xw_transition];
    } edgeSpacing:0];
}

- (void)xw_transition{
    AXDFilterAnimator *animator = [AXDFilterAnimator animatorWithType:_type];
    FilterTwoVC *toVC = [FilterTwoVC new];
    toVC.type = _type;
    if (self.pushOrPresntSwitch.on) {
        [self.navigationController axd_pushViewController:toVC withAnimator:animator];
    }else{
        [self axd_presentViewController:toVC withAnimator:animator];
    }
}

- (NSInteger)xw_getDirectionWithName:(NSString *)name{
    NSArray *temp = @[@"左", @"右", @"上", @"下"];
    return [temp indexOfObject:name];
}

@end
