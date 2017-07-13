//
//  UIImage+Extension.m
//  JODevelop
//
//  Created by JimmyOu on 2017/7/6.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "UIImage+Extension.h"

@implementation UIImage (Extension)

- (UIImage *)adjustOrientation
{
    // 如果 Orientation 已经正确则不做操作
    if (self.imageOrientation == UIImageOrientationUp) {
        return self;
    }
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:          //向下
        case UIImageOrientationDownMirrored:  //向下并且被翻转
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height); //移至右下角
            transform = CGAffineTransformRotate(transform, M_PI); //以右下角为原点旋转180度
            break;
            
        case UIImageOrientationLeft:         //向左
        case UIImageOrientationLeftMirrored: //向左并且被翻转
            transform = CGAffineTransformTranslate(transform, self.size.width, 0); //移至最右边
            transform = CGAffineTransformRotate(transform, M_PI_2); //逆时针旋转90度
            break;
            
        case UIImageOrientationRight:         //向右
        case UIImageOrientationRightMirrored: //向右并且被翻转
            transform = CGAffineTransformTranslate(transform, 0, self.size.height); //移至最下面
            transform = CGAffineTransformRotate(transform, -M_PI_2); //顺时针旋转-90度
            break;
            
        default:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:   //向上并且被翻转
        case UIImageOrientationDownMirrored: //向下并且被翻转
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1); //纵向翻转
            break;
            
        case UIImageOrientationLeftMirrored:  //向左并且被翻转
        case UIImageOrientationRightMirrored: //向右并且被翻转
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1); //横向翻转
            break;
            
        default:
            break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    
    return img;
}



@end
