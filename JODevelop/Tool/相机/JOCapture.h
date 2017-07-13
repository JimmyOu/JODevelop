//
//  JOCapture.h
//  JODevelop
//
//  Created by JimmyOu on 2017/7/4.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JOCaptureConst.h"
@class JOCapturePreview;
@interface JOCapture : UIView

//captureMode,photo or video ,default photo
@property (nonatomic, assign) CaptureMode mode;

@property (nonatomic, weak) id <CaptureDelegate> delegate;
//预览图
@property (nonatomic, strong, readonly) JOCapturePreview *preview;
//timer when recording enable
@property (nonatomic, strong) NSTimer *timer;
//indicating if the session is running.
@property (nonatomic, assign) BOOL isRunning; //default false
//indicating if the session is recording.
@property (nonatomic, assign) BOOL isRecording; //default false
//recorded time duration.
@property (nonatomic, assign, readonly) CMTime recordedDuration;
//reference to the active camera if one exists.
@property (nonatomic, strong, readonly) AVCaptureDevice *activeCamera;
//reference to the inactive camera if one exists.
@property (nonatomic, strong, readonly) AVCaptureDevice *inactiveCamera;
// Available number of cameras.
@property (nonatomic, assign, readonly) NSInteger cameraCount;
//A boolean indicating whether the camera can change to another.
@property (nonatomic, assign, readonly) BOOL canChangeCamera;
// A booealn indicating whether the camrea supports focus.
@property (nonatomic, assign, readonly) BOOL isFocusPointOfInterestSupported;
// A booealn indicating whether the camrea supports exposure.
@property (nonatomic, assign, readonly) BOOL isExposurePointOfInterestSupported;
// A boolean indicating if the active camera has flash.
@property (nonatomic, assign, readonly) BOOL isFlashAvailable;
// A boolean indicating if the active camera has a torch.
@property (nonatomic, assign, readonly) BOOL isTorchAvailable;
// A reference to the active camera position if the active camera exists.
@property (nonatomic, assign, readonly) AVCaptureDevicePosition devicePosition;
// A reference to the focusMode.
@property (nonatomic, assign) AVCaptureFocusMode focusMode;
/// A reference to the flashMode.
@property (nonatomic, assign) AVCaptureFlashMode flashMode;
// A reference to the torchMode.
@property (nonatomic, assign) AVCaptureTorchMode torchMode;
// The session quality preset.
@property (nonatomic, assign) CapturePreset capturePreset; //default presetHigh
// A reference to the previous AVCaptureVideoOrientation.
@property (nonatomic, assign) AVCaptureVideoOrientation previousVideoOrientation;
// The capture video orientation.
@property (nonatomic, assign) AVCaptureVideoOrientation videoOrientation;
// A reference to the captureButton.
@property (nonatomic, strong) UIButton *captureButton;
/// A reference to the changeModeButton.
@property (nonatomic, strong) UIButton *changeModeButton;
/// A reference to the changeCameraButton.
@property (nonatomic, strong) UIButton *changeCameraButton;
/// A reference to the flashButton.
@property (nonatomic, strong) UIButton *flashButton;
/// A boolean indicating whether to enable tap to focus. default YES
@property (nonatomic, assign) BOOL isTapToFocusEnabled;
/// A boolean indicating whether to enable tap to expose. default YES
@property (nonatomic, assign) BOOL isTapToExposeEnabled;
/// A boolean indicating whether to enable tap to reset. default NO
@property (nonatomic, assign) BOOL isTapToResetEnabled;

/// Starts the session.
- (void)startSession;
/// Stops the session.
- (void)stopSession;
/// Changees the camera if possible.
- (void)changeCamera;
/// Changees the mode.
- (void)changeMode;
//Checks if a given exposure mode is supported.
- (BOOL)isExposureModeSupported:(AVCaptureExposureMode)exposureMode;
//Checks if a given focus mode is supported.
- (BOOL)isFocusModeSupported:(AVCaptureFocusMode)focusMode;
//Checks if a given flash mode is supported.
- (BOOL)isFlashModeSupported:(AVCaptureFlashMode)flashMode;
//Checks if a given torch mode is supported.
- (BOOL)isTorchModeSupported:(AVCaptureTorchMode)torchMode;
//Focus the camera at a given point
- (void)focusAtPoint:(CGPoint)point;
//Exposes the camera at a given point.
- (void)exposeAtPoint:(CGPoint)point;
//Resets the camera focus and exposure.
- (void)reset;
//Resets the camera focus and exposure.
- (void)resetWithFocus:(BOOL)focus exposure:(BOOL)exposure;
//captureStillImage
- (void)captureStillImage;
/// Starts recording.
- (void)startRecording;
/// Stops recording.
- (void)stopRecording;




@end
