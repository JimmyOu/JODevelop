//
//  AXDTitleView.h
//  JODevelop
//
//  Created by JimmyOu on 2017/5/11.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AXDTitleView : UIView

@property (assign, nonatomic, getter=isSelected) BOOL selected;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) UIColor *textColor;
@property (strong, nonatomic) UIFont *font;

- (CGFloat)titleViewWidth;

@end
