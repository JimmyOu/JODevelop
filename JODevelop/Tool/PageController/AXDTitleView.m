//
//  AXDTitleView.m
//  JODevelop
//
//  Created by JimmyOu on 2017/5/11.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "AXDTitleView.h"

@interface AXDTitleView ()

@property (strong, nonatomic) UILabel *label;

@end
@implementation AXDTitleView {
    CGSize _titleSize;
}

- (instancetype)init {
    self = [self initWithFrame:CGRectZero];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.label];
        
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
   self.label.frame = self.bounds;
}

- (CGFloat)titleViewWidth {
    return  _titleSize.width;
}

- (void)setFont:(UIFont *)font {
    _font = font;
    self.label.font = font;
}

- (void)setText:(NSString *)text {
    _text = text;
    self.label.text = text;
    CGRect bounds = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, 0.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.label.font} context:nil];
    _titleSize = bounds.size;
    
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    self.label.textColor = textColor;
    
}

- (UILabel *)label {
    if (_label == nil) {
        _label = [[UILabel alloc] init];
        _label.textAlignment = NSTextAlignmentCenter;
    }
    return _label;
}


@end
