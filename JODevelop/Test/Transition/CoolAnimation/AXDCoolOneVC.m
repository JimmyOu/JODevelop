//
//  AXDCoolOneVC.m
//  JODevelop
//
//  Created by JimmyOu on 17/4/24.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "AXDCoolOneVC.h"
#import "AXDCoolTwoVC.h"
#import "AXDTransition.h"

@interface AXDCoolOneVC ()

@end

@implementation AXDCoolOneVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSArray *directionNames = @[@"左",@"右", @"左", @"下", @"上", @"下",@"右",@"左",@"下",@"左",@"下",@"右",@"左",@"下",@"上"];
    [self.button setTitle:[NSString stringWithFormat:@"点我或向%@滑动", directionNames[_type]] forState:UIControlStateNormal];
    [self.button addTarget:self action:@selector(xw_transition) forControlEvents:UIControlEventTouchUpInside];
    __weak __typeof(self)weakSelf = self;
    [self axd_registerToInteractiveTransitionWithDirection:[self xw_getDirectionWithName:directionNames[_type]] transitonBlock:^(CGPoint startPoint){
        [weakSelf xw_transition];
    } edgeSpacing:0];
}

- (void)xw_transition{
    AXDCoolAnimator *animator = [AXDCoolAnimator animatorWithType:_type];
    animator.toDuration = 1.0f;
    animator.backDuration = 1.0f;
    AXDCoolTwoVC *toVC = [AXDCoolTwoVC new];
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
