//
//  LineDashView.m
//  模块化Demo
//
//  Created by JimmyOu on 17/4/1.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "LineDashView.h"

@implementation LineDashView
{
    CAShapeLayer  *_shapeLayer;
}
@synthesize lineDashPattern = _lineDashPattern;
@synthesize endOffset = _endOffset;



+ (Class)layerClass
{
    return [CAShapeLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        UIBezierPath *path      = [UIBezierPath bezierPathWithRect:self.bounds];
        _shapeLayer             = (CAShapeLayer *)self.layer;
        _shapeLayer.fillColor   = [UIColor clearColor].CGColor;
        _shapeLayer.strokeStart = 0.001;
        _shapeLayer.strokeEnd   = 0.499;
        _shapeLayer.lineWidth   = frame.size.height;
        _shapeLayer.path        = path.CGPath;
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
              lineDashPattern:(NSArray *)lineDashPattern
                    endOffset:(CGFloat)endOffset
{
    LineDashView *lineDashView   = [[LineDashView alloc] initWithFrame:frame];
    lineDashView.lineDashPattern = lineDashPattern;
    lineDashView.endOffset       = endOffset;
    
    return lineDashView;
}

#pragma mark - 改写属性的getter,setter方法
- (void)setLineDashPattern:(NSArray *)lineDashPattern
{
    _lineDashPattern            = lineDashPattern;
    _shapeLayer.lineDashPattern = lineDashPattern;
}
- (NSArray *)lineDashPattern
{
    return _lineDashPattern;
}

- (void)setEndOffset:(CGFloat)endOffset
{
    _endOffset = endOffset;
    if (endOffset < 0.499 && endOffset > 0.001)
    {
        _shapeLayer.strokeEnd = _endOffset;
    }
}
- (CGFloat)endOffset
{
    return _endOffset;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    _shapeLayer.strokeColor = backgroundColor.CGColor;
}
- (UIColor *)backgroundColor
{
    return [UIColor colorWithCGColor:_shapeLayer.strokeColor];
}

@end
