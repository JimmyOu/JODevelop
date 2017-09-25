//
//  JOCapturePreview.h
//  JODevelop
//
//  Created by JimmyOu on 2017/7/4.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JOCapturePreview : UIView

//将屏幕坐标系的点转换为previewLayer坐标系的点
- (CGPoint)captureDevicePointOfInterestForPoint:(CGPoint)point;
//将previewLayer的点转换为屏幕坐标系的点
- (CGPoint)pointForCaptureDevicePointOfInterest:(CGPoint)point;

@end
