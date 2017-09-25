//
//  JOCapturePreview.m
//  JODevelop
//
//  Created by JimmyOu on 2017/7/4.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "JOCapturePreview.h"
#import <AVFoundation/AVFoundation.h>

@implementation JOCapturePreview

+ (Class)layerClass {
    return [AVCaptureVideoPreviewLayer class];
}

- (CGPoint)captureDevicePointOfInterestForPoint:(CGPoint)point {
    AVCaptureVideoPreviewLayer *captureLayer = (AVCaptureVideoPreviewLayer *)self.layer;
    return [captureLayer captureDevicePointOfInterestForPoint:point];
}

- (CGPoint)pointForCaptureDevicePointOfInterest:(CGPoint)point {
    AVCaptureVideoPreviewLayer *captureLayer = (AVCaptureVideoPreviewLayer *)self.layer;
    return [captureLayer pointForCaptureDevicePointOfInterest:point];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self prepare];
    }
    return self;
}

- (void)prepare {
    self.layer.backgroundColor = [UIColor blackColor].CGColor;
    self.layer.masksToBounds = true;
    AVCaptureVideoPreviewLayer *captureLayer = (AVCaptureVideoPreviewLayer *)self.layer;
    captureLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
}

@end
