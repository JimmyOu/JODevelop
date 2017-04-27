//
//  LineDashView.h
//  模块化Demo
//
//  Created by JimmyOu on 17/4/1.
//  Copyright © 2017年 JimmyOu. All rights reserved.
// 画线段

#import <UIKit/UIKit.h>

@interface LineDashView : UIView

@property (nonatomic, strong) NSArray   *lineDashPattern;  // 线段分割模式
@property (nonatomic, assign) CGFloat    endOffset;        // 取值在 0.001 --> 0.499 之间

- (instancetype)initWithFrame:(CGRect)frame
              lineDashPattern:(NSArray *)lineDashPattern
                    endOffset:(CGFloat)endOffset;

@end
