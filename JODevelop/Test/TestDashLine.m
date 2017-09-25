//
//  TestDashLine.m
//  JODevelop
//
//  Created by JimmyOu on 17/4/13.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "TestDashLine.h"
#import "LineDashView.h"

@interface TestDashLine ()

@end

@implementation TestDashLine

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    /*******       5.LineDashViewTest       *******/
    [self testLineDashViewTest];

}

- (void)testLineDashViewTest {
    self.view.backgroundColor = [UIColor blackColor];
    
    // 线条宽度
    CGFloat lineHeight = 1;
    
    // 线条1
    LineDashView *line1 = [[LineDashView alloc] initWithFrame:CGRectMake(0, 100, 320, lineHeight)
                                              lineDashPattern:@[@10, @10]
                                                    endOffset:0.495];
    line1.backgroundColor = [UIColor redColor];
    [self.view addSubview:line1];
    
    // 线条2
    LineDashView *line2 = [[LineDashView alloc] initWithFrame:CGRectMake(0, 110, 320, lineHeight)
                                              lineDashPattern:@[@5, @5]
                                                    endOffset:0.495];
    line2.backgroundColor = [UIColor redColor];
    [self.view addSubview:line2];
    
    // 线条3
    LineDashView *line3 = [[LineDashView alloc] initWithFrame:CGRectMake(0, 120, 320, lineHeight)
                                              lineDashPattern:@[@10, @5, @20, @10]
                                                    endOffset:0.495];
    line3.backgroundColor = [UIColor redColor];
    [self.view addSubview:line3];
    
    // 线条4
    LineDashView *line4 = [[LineDashView alloc] initWithFrame:CGRectMake(0, 130, 320, lineHeight)
                                              lineDashPattern:@[@10, @5, @20, @10, @30, @20]
                                                    endOffset:0.495];
    line4.backgroundColor = [UIColor redColor];
    [self.view addSubview:line4];
}
@end
