//
//  AXDCoolTwoVC.m
//  JODevelop
//
//  Created by JimmyOu on 17/4/24.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "AXDCoolTwoVC.h"

@interface AXDCoolTwoVC ()

@end

@implementation AXDCoolTwoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *directionNames = @[@"右",@"左",@"右",@"上",@"下",@"上",@"左",@"右",@"上",@"右", @"上", @"左", @"右", @"上", @"下"];
    [self.button setTitle:[NSString stringWithFormat:@"点我或向%@滑动", directionNames[_type]] forState:UIControlStateNormal];
    [self.button addTarget:self action:@selector(xw_transiton) forControlEvents:UIControlEventTouchUpInside];
    __weak __typeof(self)weakSelf = self;
    [self axd_registerBackInteractiveTransitionWithDirection:[self xw_getDirectionWithName:directionNames[_type]] transitonBlock:^(CGPoint startPoint){
        [weakSelf xw_transiton];
    } edgeSpacing:0];
}

- (NSInteger)xw_getDirectionWithName:(NSString *)name{
    NSArray *temp = @[@"左", @"右", @"上", @"下"];
    return [temp indexOfObject:name];
}



@end
