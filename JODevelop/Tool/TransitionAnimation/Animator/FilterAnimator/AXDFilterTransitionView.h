//
//  AXDFilterTransitionView.h
//  JODevelop
//
//  Created by JimmyOu on 17/4/27.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AXDFilterTransitionView : GLKView

@property (nonatomic, assign) BOOL blurType;
@property (nonatomic, strong) CIFilter *filter;

- (instancetype)initWithFrame:(CGRect)frame
                    fromImage:(UIImage *)fromImage
                      toImage:(UIImage *)toImage;

- (CAAnimation *)xw_getInnerAnimation;

- (CIVector *)xw_getInnerVector;

+ (void)animationWith:(AXDFilterTransitionView *)filterView duration:(NSTimeInterval)duration completion:(void (^ __nullable)(BOOL finished))completion;

@end
NS_ASSUME_NONNULL_END
