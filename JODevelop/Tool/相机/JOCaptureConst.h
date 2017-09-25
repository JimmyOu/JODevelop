//
//  JOCaptureConst.h
//  JODevelop
//
//  Created by JimmyOu on 2017/7/4.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@class JOCapture;

typedef NS_ENUM(NSUInteger, CaptureMode) {
    CaptureModePhoto,
    CaptureModeVideo
};

typedef NS_ENUM(NSUInteger, CapturePreset) {
    CapturePresetPhoto,
    CapturePresetHigh,
    CapturePresetMedium,
    CapturePresetLow,
    CapturePreset352x288,
    CapturePreset640x480,
    CapturePreset1280x720,
    CapturePreset1920x1080,
    CapturePreset3840x2160,
    CapturePresetiFrame960x540,
    CapturePresetiFrame1280x720,
    CapturePresetiInputPriority
};

NSString * CapturePresetToString(CapturePreset preset) {
    switch (preset) {
        case CapturePresetPhoto:
            return AVCaptureSessionPresetPhoto;
        case CapturePresetHigh:
            return AVCaptureSessionPresetHigh;
        case CapturePresetMedium:
            return AVCaptureSessionPresetMedium;
        case CapturePresetLow:
            return AVCaptureSessionPresetLow;
        case CapturePreset352x288:
            return AVCaptureSessionPreset352x288;
        case CapturePreset640x480:
            return AVCaptureSessionPreset640x480;
        case CapturePreset1280x720:
            return AVCaptureSessionPreset1280x720;
        case CapturePreset1920x1080:
            return AVCaptureSessionPreset1920x1080;
        case CapturePreset3840x2160: {
            if ([[UIDevice currentDevice].systemVersion integerValue] >= 9.0) {
                return AVCaptureSessionPreset3840x2160;
            } else {
                return AVCaptureSessionPresetHigh;
            }
            break;
        }
        case CapturePresetiFrame960x540:
            return AVCaptureSessionPresetiFrame960x540;
        case CapturePresetiFrame1280x720:
            return AVCaptureSessionPresetiFrame1280x720;
        case CapturePresetiInputPriority:
            return AVCaptureSessionPresetInputPriority;
            
        default:
            break;
    }
}

@protocol CaptureDelegate <NSObject>

@optional
// called when captureSesstion failes with an error
- (void)capture:(JOCapture *)capture failureWithError:(NSError *)error;

// called when record timer has started.
- (void)capture:(JOCapture *)capture didStartRecord:(NSTimer *)timer;

// called when record timer when the record timer was updated.
- (void)capture:(JOCapture *)capture didUpdateRecord:(NSTimer *)timer hours:(NSUInteger)hours minutes:(NSUInteger)minutes seconds:(NSUInteger)seconds;

// called when record timer when the record timer has stopped.
- (void)capture:(JOCapture *)capture didStopRecord:(NSTimer *)timer hours:(NSUInteger)hours minutes:(NSUInteger)minutes seconds:(NSUInteger)seconds;

//called when the user tapped to adjust the focus.
- (void)capture:(JOCapture *)capture didTapToFocusAt:(CGPoint)point;

//called when the user tapped to adjust the Expose.
- (void)capture:(JOCapture *)capture didTapToExposeAt:(CGPoint)point;

//called when the user tapped to reset.
- (void)capture:(JOCapture *)capture didTapToResetAt:(CGPoint)point;

//called when the user pressed the change mode button.
- (void)capture:(JOCapture *)capture didPressChangeMode:(UIButton *)button;

//called when the user pressed the change camera
- (void)capture:(JOCapture *)capture didPressChangeCamera:(UIButton *)button;

//called when the user pressed capture button.
- (void)capture:(JOCapture *)capture didPressCapture:(UIButton *)button;

//called when the user pressed the flash button.
- (void)capture:(JOCapture *)capture didPressFlash:(UIButton *)button;

//called before the camera will change to another
- (void)capture:(JOCapture *)capture willChangeCaptureMode:(CaptureMode)mode;

//called after the camera has been changed to another
- (void)capture:(JOCapture *)capture didChangeCaptureMode:(CaptureMode)mode;

//called the camera will change to front or background.
- (void)capture:(JOCapture *)capture willChangeCamera:(AVCaptureDevicePosition )devicePosition;

//called the camera has been changed to front or background.
- (void)capture:(JOCapture *)capture didChangeCamera:(AVCaptureDevicePosition )devicePosition;

//called the camera has been changed to front or background.
- (void)capture:(JOCapture *)capture didChangeCameraFrom:(AVCaptureVideoOrientation)previousVideoOrientation to:(AVCaptureVideoOrientation)videoOrientation;

//called when an image has been captured
- (void)capture:(JOCapture *)capture asynchronouslyStill:(UIImage *)image;

//called  when capturing an image asynchronously has failed.
- (void)capture:(JOCapture *)capture asynchronouslyStillImageFailedWith:(NSError *)error;

//called  when creating a movie file has failed.
- (void)capture:(JOCapture *)capture createMovieFileFailedWith:(NSError *)error;

//called when a session started recording and writing to a file.
- (void)capture:(JOCapture *)capture captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAt:(NSURL *)fileURL fromConnections:(NSArray *)connections;

//called when a session finished recording and writing to a file.
- (void)capture:(JOCapture *)capture captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAt:(NSURL *)fileURL fromConnections:(NSArray *)connections error:(NSError *)error;

@end

