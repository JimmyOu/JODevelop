//
//  DebugSlider.h
//  JODevelop
//
//  Created by JimmyOu on 2018/3/5.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DebugSlider : UIView

@property (strong, nonatomic) UISlider *slider;
@property (strong, nonatomic) UILabel *value;

+ (instancetype)debugSlider;

@end
