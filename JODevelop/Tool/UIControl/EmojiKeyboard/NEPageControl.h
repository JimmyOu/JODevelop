//
//  SREmojiContainer.h
//  JODevelop
//
//  Created by JimmyOu on 2018/2/5.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NEPageControl : UIView
@property (nonatomic, assign) CGFloat offset;        // 圆点间的宽度,默认为10
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) NSInteger numberOfPages;
@property (nonatomic, strong) UIImage *onImage;
@property (nonatomic, strong) UIImage *offImage;
@end
