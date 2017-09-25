//
//  JOCapture.m
//  JODevelop
//
//  Created by JimmyOu on 2017/7/4.
//  Copyright © 2017年 JimmyOu. All rights reserved.
//

#import "JOCapture.h"
#import "JOCapturePreview.h"
#import "UIImage+Extension.h"
#import "Masonry.h"
UInt8 CaptureAdjustingExposureContext = 0;
@interface JOCapture ()<AVCaptureFileOutputRecordingDelegate>

@property (nonatomic, strong) JOCapturePreview *preview;
//gesture for focus
@property (nonatomic, strong) UITapGestureRecognizer *tapToFocusGesture;
//gesture for expose
@property (nonatomic, strong) UITapGestureRecognizer *tapToExposeGesture;
//gesture for reset events
@property (nonatomic, strong) UITapGestureRecognizer *tapToResetGesture;
//session DispatchQueue.
@property (nonatomic, strong) dispatch_queue_t sessionQueue;
//the active video input
@property (nonatomic, strong) AVCaptureDeviceInput *activeVideoInput;
//the active audio input
@property (nonatomic, strong) AVCaptureDeviceInput *activeAudioInput;
//the image output
@property (nonatomic, strong) AVCaptureStillImageOutput *imageOutput;
//movie output
@property (nonatomic, strong) AVCaptureMovieFileOutput *movieOutput;
//movie output URL
@property (nonatomic, strong) NSURL *movieOutputURL;
//AVCaptureSession
@property (nonatomic, strong) AVCaptureSession *session;


@end
@implementation JOCapture

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self prepare];
    }
    return self;
}


- (void)prepare {
    _capturePreset = CapturePresetHigh;
    self.isTapToFocusEnabled = NO;
    self.isTapToResetEnabled = NO;
    self.isTapToExposeEnabled = YES;
    self.backgroundColor = [UIColor blackColor];
    [self prepareSession];
    [self prepareSessionQueue];
    [self prepareActiveVideoInput];
    [self prepareActiveAudioInput];
    [self prepareImageOutput];
    [self prepareMovieOutput];
    [self preparePreview];
    [self prepareOrientationNotifications];
    
    self.previousVideoOrientation = self.videoOrientation;
    
    
}

- (void)dealloc {
    [self removeOrientationNotifications];
}
#pragma Notification
- (void)prepareOrientationNotifications {
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOrientationNotifications:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)removeOrientationNotifications {
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)handleOrientationNotifications:(NSNotification *)notification {
    if (self.delegate && [self.delegate respondsToSelector:@selector(capture:didChangeCameraFrom:to:)]) {
        [self.delegate capture:self didChangeCameraFrom:self.previousVideoOrientation to:self.videoOrientation];
        self.previousVideoOrientation = self.videoOrientation;
    }
}
#pragma private methods
- (void)prepareSession {
    self.session = [[AVCaptureSession alloc] init];
}
- (void)prepareSessionQueue {
    self.sessionQueue = dispatch_queue_create("com.cosmicmind.jimmy.capture", DISPATCH_QUEUE_CONCURRENT);
}
- (void)prepareActiveVideoInput {
    NSError *error;
    self.activeVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] error:&error];
    if ([self.session canAddInput:self.activeVideoInput]) {
        [self.session addInput:self.activeVideoInput];
    }
    if (error && self.delegate && [self.delegate respondsToSelector:@selector(capture:failureWithError:)]) {
        [self.delegate capture:self failureWithError:error];
    }
}
- (void)prepareActiveAudioInput {
    NSError *error;
    self.activeAudioInput = [[AVCaptureDeviceInput alloc] initWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio] error:&error];
    if ([self.session canAddInput:self.activeAudioInput]) {
        [self.session addInput:self.activeAudioInput];
    }
    if (error && self.delegate && [self.delegate respondsToSelector:@selector(capture:failureWithError:)]) {
        [self.delegate capture:self failureWithError:error];
    }
}
- (void)prepareImageOutput {
    self.imageOutput = [[AVCaptureStillImageOutput alloc] init];
    if ([self.session canAddOutput:self.imageOutput]) {
        self.imageOutput.outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
        [self.session addOutput:self.imageOutput];
    }
}
- (void)prepareMovieOutput {
    self.movieOutput = [[AVCaptureMovieFileOutput alloc] init];
    if ([self.session canAddOutput:self.movieOutput]) {
        [self.session addOutput:self.movieOutput];
    }
}
- (void)preparePreview {
    _preview = [[JOCapturePreview alloc] init];
    [self addSubview:_preview];
    [_preview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    if([_preview.layer isKindOfClass:[AVCaptureVideoPreviewLayer class]]) {
        AVCaptureVideoPreviewLayer *captureLayer = (AVCaptureVideoPreviewLayer *)_preview.layer;captureLayer.session = self.session;
        [self startSession];
    }
}

- (void)prepareCaptureButton {
    if (self.captureButton) {
        [self.captureButton addTarget:self action:@selector(handleCaptureButton:) forControlEvents:UIControlEventTouchUpInside];
    }
}
- (void)prepareChangeModeButton {
    if (self.changeModeButton) {
        [self.changeModeButton addTarget:self action:@selector(handleChangeModeButton:) forControlEvents:UIControlEventTouchUpInside];
    }
}
- (void)prepareChangeCameraButton {
    if (self.changeCameraButton) {
        [self.changeCameraButton addTarget:self action:@selector(handleChangeCameraButton:) forControlEvents:UIControlEventTouchUpInside];
    }
}
- (void)prepareFlashButton {
    if (self.flashButton) {
        [self.flashButton addTarget:self action:@selector(handleFlashButton:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (AVCaptureDevice *)cameraAtPosition:(AVCaptureDevicePosition)position {
    NSArray <AVCaptureDevice *>*devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    if (devices.count > 0) {
        for (AVCaptureDevice *device in devices) {
            if (device.position == position) {
                return device;
            }
        }
    }
    return nil;
    
}

#pragma mark - public methods
- (void)startSession {
    if (!self.isRunning) {
        __weak __typeof(self)weakSelf = self;
        dispatch_async(self.sessionQueue, ^{
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if (!strongSelf) return;
            [strongSelf.session startRunning];
        });
    }
}
- (void)stopSession {
    if (self.isRunning) {
        __weak __typeof(self)weakSelf = self;
        dispatch_async(self.sessionQueue, ^{
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if (!strongSelf) return;
            [strongSelf.session stopRunning];
        });
        
    }
}
- (void)changeCamera {
    if (self.canChangeCamera) {
        if (self.devicePosition) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(capture:willChangeCamera:)]) {
                [self.delegate capture:self willChangeCamera:self.devicePosition];
            }
            NSError *error;
            AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:self.inactiveCamera error:&error];
            [self.session beginConfiguration];
            [self.session removeInput:self.activeVideoInput];
            
            if ([self.session canAddInput:videoInput]) {
                [self.session addInput:videoInput];
                self.activeVideoInput = videoInput;
            } else {
                [self.session addInput:self.activeVideoInput];
            }
            [self.session commitConfiguration];
            if (self.delegate && [self.delegate respondsToSelector:@selector(capture:didChangeCamera:)]) {
                [self.delegate capture:self didChangeCamera:self.devicePosition];
            }
            if (error && self.delegate && [self.delegate respondsToSelector:@selector(capture:failureWithError:)]) {
                [self.delegate capture:self failureWithError:error];
            }
        }
    }
}

- (void)changeMode {
    if (self.delegate && [self.delegate respondsToSelector:@selector(capture:willChangeCaptureMode:)]) {
        [self.delegate capture:self willChangeCaptureMode:self.mode];
    }
    self.mode = (self.mode == CaptureModePhoto)? CaptureModeVideo:CaptureModePhoto;
    if (self.delegate && [self.delegate respondsToSelector:@selector(capture:didChangeCaptureMode:)]) {
        [self.delegate capture:self didChangeCaptureMode:self.mode];
    }
}
- (BOOL)isExposureModeSupported:(AVCaptureExposureMode)exposureMode {
    return [self.activeCamera isExposureModeSupported:exposureMode];
}
- (BOOL)isFocusModeSupported:(AVCaptureFocusMode)focusMode {
    return [self.activeCamera isFocusModeSupported:focusMode];
}
- (BOOL)isFlashModeSupported:(AVCaptureFlashMode)flashMode {
    return [self.activeCamera isFlashModeSupported:flashMode];
}

- (BOOL)isTorchModeSupported:(AVCaptureTorchMode)torchMode {
    return [self.activeCamera isTorchModeSupported:torchMode];
}
//Focus the camera at a given point
- (void)focusAtPoint:(CGPoint)point {
    NSError *error;
    if ([self isFocusPointOfInterestSupported] && [self isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        [self.activeCamera lockForConfiguration:&error];
        self.activeCamera.focusPointOfInterest = point;
        [self.activeCamera unlockForConfiguration];
    } else {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        userInfo[NSLocalizedDescriptionKey] = @"[Material Error: Unsupported focus.]";
        userInfo[NSLocalizedFailureReasonErrorKey] = @"[Material Error: Unsupported focus.]";
        error = [[NSError alloc] initWithDomain:@"jimmyou.capture" code:0004 userInfo:userInfo];
    }
    if (error && self.delegate && [self.delegate respondsToSelector:@selector(capture:failureWithError:)]) {
        [self.delegate capture:self failureWithError:error];
    }
}
- (void)exposeAtPoint:(CGPoint)point {
    NSError *error;
    if ([self isExposurePointOfInterestSupported] && [self isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        [self.activeCamera lockForConfiguration:&error];
        self.activeCamera.exposurePointOfInterest = point;
        self.activeCamera.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
        if ([self.activeCamera isExposureModeSupported:AVCaptureExposureModeLocked]) {
            [self.activeCamera addObserver:self forKeyPath:@"adjustingExposure" options:NSKeyValueObservingOptionNew context:&CaptureAdjustingExposureContext];
        }
        [self.activeCamera unlockForConfiguration];
    } else {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        userInfo[NSLocalizedDescriptionKey] = @"[Material Error: Unsupported expose.]";
        userInfo[NSLocalizedFailureReasonErrorKey] = @"[Material Error: Unsupported expose.]";
        error = [[NSError alloc] initWithDomain:@"jimmyou.capture" code:0005 userInfo:userInfo];
    }
    if (error && self.delegate && [self.delegate respondsToSelector:@selector(capture:failureWithError:)]) {
        [self.delegate capture:self failureWithError:error];
    }

}

- (void)reset {
    [self resetWithFocus:YES exposure:YES];
}
- (void)resetWithFocus:(BOOL)focus exposure:(BOOL)exposure {
    BOOL canResetFocus = self.activeCamera.isFocusPointOfInterestSupported && [self.activeCamera isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus];
    BOOL canResetExposure = self.activeCamera.isExposurePointOfInterestSupported && [self.activeCamera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure];
    CGPoint centerPoint = CGPointMake(0.5, 0.5);
    
    NSError *error;
    [self.activeCamera lockForConfiguration:&error];
    if (canResetFocus && focus) {
        self.activeCamera.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        self.activeCamera.focusPointOfInterest = centerPoint;
    }
    if (canResetExposure && exposure) {
        self.activeCamera.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
        self.activeCamera.exposurePointOfInterest = centerPoint;
    }
    [self.activeCamera unlockForConfiguration];
    
    if (error && [self.delegate respondsToSelector:@selector(capture:failureWithError:)]) {
        [self.delegate capture:self failureWithError:error];
    }
}
- (void)captureStillImage {
    __weak __typeof(self)weakSelf = self;
    dispatch_async(self.sessionQueue, ^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (!strongSelf) return;
       AVCaptureConnection *connection = [strongSelf.imageOutput connectionWithMediaType:AVMediaTypeVideo];
        if (!connection) {
            return;
        }
        connection.videoOrientation = strongSelf.videoOrientation;
        __weak __typeof(self)weakSelf = strongSelf;
        [strongSelf.imageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if (!strongSelf) return;
            
            NSError *captureError = error;
            if (captureError == nil) {
                NSData *data = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                
                UIImage *image1 = [UIImage imageWithData:data];
                if (image1) {
                    UIImage *image2 = [image1 adjustOrientation];
                    if (image2) {
                        if (self.delegate && [self.delegate respondsToSelector:@selector(capture:asynchronouslyStill:)]) {
                            [self.delegate capture:self asynchronouslyStill:image2];
                        }
                    } else {
                        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                        userInfo[NSLocalizedDescriptionKey] = @"[Material Error: Cannot fix image orientation.]";
                        userInfo[NSLocalizedFailureReasonErrorKey] = @"[Material Error: Cannot fix image orientation.]";
                        captureError = [[NSError alloc] initWithDomain:@"jimmyou.capture" code:0006 userInfo:userInfo];
                    }
                } else {
                    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                    userInfo[NSLocalizedDescriptionKey] = @"[Material Error: capture image from data.]";
                    userInfo[NSLocalizedFailureReasonErrorKey] = @"[Material Error: Cannot capture image from data.]";
                    captureError = [[NSError alloc] initWithDomain:@"jimmyou.capture" code:0007 userInfo:userInfo];
                }
                
            }
            if (captureError) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(capture:asynchronouslyStillImageFailedWith:)]) {
                    [self.delegate capture:self asynchronouslyStillImageFailedWith:error];
                }
            }
        }];
        
    });
}
- (void)startRecording {
    if (!self.isRecording) {
        __weak __typeof(self)weakSelf = self;
        dispatch_async(self.sessionQueue, ^{
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if (!strongSelf) return;
           AVCaptureConnection *connection = [strongSelf.movieOutput connectionWithMediaType:AVMediaTypeVideo];
            if (connection) {
                connection.videoOrientation = strongSelf.videoOrientation;
                connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
            }
            
            if (!strongSelf.activeCamera) return;
            if (strongSelf.activeCamera.isSmoothAutoFocusSupported) {
                NSError *error;
                [strongSelf.activeCamera lockForConfiguration:&error];
                strongSelf.activeCamera.smoothAutoFocusEnabled = true;
                [strongSelf.activeCamera unlockForConfiguration];
                
                if (error && strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(capture:failureWithError:)]) {
                    [strongSelf.delegate capture:strongSelf failureWithError:error];
                }
                
            }
            strongSelf.movieOutputURL = [strongSelf uniqueURL];

            if (strongSelf.movieOutputURL) {
                [strongSelf.movieOutput startRecordingToOutputFileURL:strongSelf.movieOutputURL recordingDelegate:strongSelf];
            }
        
        });
    }
}
- (void)stopRecording {
    if (self.isRecording) {
        [self.movieOutput stopRecording];
    }
}


- (NSURL *)uniqueURL {
    NSError *error;
   NSURL *directory = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:true error:&error];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterFullStyle;
    dateFormatter.timeStyle = kCFDateFormatterFullStyle;
    
    if (error) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(capture:createMovieFileFailedWith:)]) {
            [self.delegate capture:self createMovieFileFailedWith:error];
        }
        return nil;
    } else {
        return [directory URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov",[dateFormatter stringFromDate:[NSDate date]]]];
    }
}

- (CMTime)recordedDuration {
    return self.movieOutput.recordedDuration;
}
- (AVCaptureDevice *)activeCamera {
    return self.activeVideoInput.device;
}
- (AVCaptureDevice *)inactiveCamera {
    AVCaptureDevice *device = nil;
    if (self.cameraCount > 1) {
        if (self.activeCamera.position == AVCaptureDevicePositionBack) {
            device = [self cameraAtPosition:AVCaptureDevicePositionFront];
        } else {
            device = [self cameraAtPosition:AVCaptureDevicePositionBack];
        }
    }
    return device;
}

- (NSInteger)cameraCount {
    return [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].count;
}
- (BOOL)canChangeCamera {
    return self.cameraCount > 1;
}
- (BOOL)isFocusPointOfInterestSupported {
    return self.activeCamera == nil ? false:self.activeCamera.isFocusPointOfInterestSupported;
}


- (BOOL)isExposurePointOfInterestSupported {
        return self.activeCamera == nil ? false:self.activeCamera.isFocusPointOfInterestSupported;
}
- (BOOL)isFlashAvailable {
        return self.activeCamera == nil ? false:self.activeCamera.hasFlash;
}

- (BOOL)isTorchAvailable {
        return self.activeCamera == nil ? false:self.activeCamera.hasTorch;
}
- (AVCaptureDevicePosition)devicePosition {
    return self.activeCamera.position;
}

- (AVCaptureFocusMode)focusMode {
    return self.activeCamera.focusMode;
}
- (void)setFocusMode:(AVCaptureFocusMode)focusMode {
    NSError *error;
    if ([self isFocusModeSupported:focusMode]) {
        [self.activeCamera lockForConfiguration:&error];
        self.activeCamera.focusMode = focusMode;
        [self.activeCamera unlockForConfiguration];
        
    } else {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        userInfo[NSLocalizedDescriptionKey] = @"[Material Error: Unsupported focusMode.]";
        userInfo[NSLocalizedFailureReasonErrorKey] = @"[Material Error: Unsupported focusMode.]";
        error = [[NSError alloc] initWithDomain:@"jimmyou.capture" code:0001 userInfo:userInfo];
    }
    
    if (error) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(capture:failureWithError:)]) {
            [self.delegate capture:self failureWithError:error];
        }
    }
}

- (AVCaptureFlashMode)flashMode {
    return self.activeCamera.flashMode;
}

- (void)setFlashMode:(AVCaptureFlashMode)flashMode {
    NSError *error;
    if ([self isFlashModeSupported:flashMode]) {
        [self.activeCamera lockForConfiguration:&error];
        self.activeCamera.flashMode = flashMode;
        [self.activeCamera unlockForConfiguration];
        
    } else {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        userInfo[NSLocalizedDescriptionKey] = @"[Material Error: Unsupported flashMode.]";
        userInfo[NSLocalizedFailureReasonErrorKey] = @"[Material Error: Unsupported flashMode.]";
        error = [[NSError alloc] initWithDomain:@"jimmyou.capture" code:0002 userInfo:userInfo];
    }
    
    if (error) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(capture:failureWithError:)]) {
            [self.delegate capture:self failureWithError:error];
        }
    }
}

- (AVCaptureTorchMode)torchMode {
    return self.activeCamera.torchMode;
}

- (void)setTorchMode:(AVCaptureTorchMode)torchMode {
    NSError *error;
    if ([self isTorchModeSupported:torchMode]) {
        [self.activeCamera lockForConfiguration:&error];
        self.activeCamera.torchMode = torchMode;
        [self.activeCamera unlockForConfiguration];
        
    } else {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        userInfo[NSLocalizedDescriptionKey] = @"[Material Error: Unsupported torchMode.]";
        userInfo[NSLocalizedFailureReasonErrorKey] = @"[Material Error: Unsupported flashMode.]";
        error = [[NSError alloc] initWithDomain:@"jimmyou.capture" code:0003 userInfo:userInfo];
    }
    
    if (error) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(capture:failureWithError:)]) {
            [self.delegate capture:self failureWithError:error];
        }
    }
}

- (void)setCapturePreset:(CapturePreset)capturePreset {
    _capturePreset = capturePreset;
    self.session.sessionPreset = CapturePresetToString(capturePreset);
}

- (AVCaptureVideoOrientation)videoOrientation {
    AVCaptureVideoOrientation orientation;
    switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationPortrait:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        default:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
    }
    return orientation;
}
- (void)setCaptureButton:(UIButton *)captureButton {
    _captureButton = captureButton;
    [self prepareCaptureButton];
}

- (void)setChangeModeButton:(UIButton *)changeModeButton {
    _changeModeButton = changeModeButton;
    [self prepareChangeModeButton];
}

- (void)setChangeCameraButton:(UIButton *)changeCameraButton {
    _changeCameraButton = changeCameraButton;
    [self prepareChangeCameraButton];
}

- (void)setFlashButton:(UIButton *)flashButton {
    _flashButton = flashButton;
    [self prepareFlashButton];
}

- (void)setIsTapToFocusEnabled:(BOOL)isTapToFocusEnabled {
    _isTapToFocusEnabled = isTapToFocusEnabled;
    if (_isTapToFocusEnabled) {
        UITapGestureRecognizer *tapToFocusGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapToFocusGesture:)];
        tapToFocusGesture.numberOfTapsRequired = 1;
        tapToFocusGesture.numberOfTouchesRequired = 1;
        self.tapToFocusGesture = tapToFocusGesture;
        [self addGestureRecognizer:self.tapToFocusGesture ];
        
        //如果有识别出了focus，那么tapExplose失效
        if (self.tapToExposeGesture) {
            [tapToFocusGesture requireGestureRecognizerToFail:self.tapToExposeGesture];
        }
        
    } else {
        [self removeGestureRecognizer:self.tapToFocusGesture];
        self.tapToFocusGesture = nil;
        
    }
}
- (void)setIsTapToExposeEnabled:(BOOL)isTapToExposeEnabled {
    _isTapToExposeEnabled = isTapToExposeEnabled;
    if (_isTapToExposeEnabled) {
        UITapGestureRecognizer *tapToExposeGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapToFocusGesture:)];
        tapToExposeGesture.numberOfTapsRequired = 2;
        tapToExposeGesture.numberOfTouchesRequired = 1;
        self.tapToExposeGesture = tapToExposeGesture;
        [self addGestureRecognizer:self.tapToExposeGesture];
        
        //如果有识别出了focus，那么tapExplose失效
        if (self.tapToFocusGesture) {
            [self.tapToFocusGesture requireGestureRecognizerToFail:self.tapToExposeGesture];
        }

    } else {
        [self removeGestureRecognizer:self.tapToExposeGesture];
        self.tapToExposeGesture = nil;
    }
}

- (void)setIsTapToResetEnabled:(BOOL)isTapToResetEnabled {
    _isTapToResetEnabled = isTapToResetEnabled;
    if (_isTapToResetEnabled) {
        UITapGestureRecognizer *tapToResetGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapToResetGesture:)];
        tapToResetGesture.numberOfTapsRequired = 2;
        tapToResetGesture.numberOfTouchesRequired = 2;
        self.tapToResetGesture = tapToResetGesture;
        [self addGestureRecognizer:self.tapToResetGesture];
        //如果有识别出了focus，那么tapReset失效
        if (self.tapToExposeGesture) {
            [self.tapToFocusGesture requireGestureRecognizerToFail:self.tapToResetGesture];
        }
        //如果有识别出了tapExplose，那么tapReset失效
        if (self.tapToExposeGesture) {
            [self.tapToExposeGesture requireGestureRecognizerToFail:self.tapToResetGesture];
        }
        
    } else {
        [self removeGestureRecognizer:self.tapToResetGesture];
        self.tapToResetGesture = nil;
    }
}

#pragma mark - private Method
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == &CaptureAdjustingExposureContext) {
        AVCaptureDevice *device = (AVCaptureDevice *)object;
        if (!device.isAdjustingExposure && [device isExposureModeSupported:AVCaptureExposureModeLocked]) {
            [device removeObserver:self forKeyPath:@"adjustingExposure" context:&CaptureAdjustingExposureContext];
            __weak __typeof(self)weakSelf = self;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                if (!strongSelf) return;
                NSError *error;
                [device lockForConfiguration:&error];
                device.exposureMode = AVCaptureExposureModeLocked;
                [device unlockForConfiguration];
                
                if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(capture:failureWithError:)]) {
                    [strongSelf.delegate capture:strongSelf failureWithError:error];
                }
            });
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


#pragma mark gesture
- (void)handleCaptureButton:(UIButton *)button {
    switch (self.mode) {
        case CaptureModePhoto:
            [self captureStillImage];
            break;
        case CaptureModeVideo:{
            if (self.isRecording) {
                [self stopRecording];
                [self stopTimer];
            } else {
                [self startRecording];
                [self startTimer];
            }
            break;
        }
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(capture:didPressCapture:)]) {
        [self.delegate capture:self didPressCapture:button];
    }
}
- (void)handleChangeModeButton:(UIButton *)button {
    [self changeMode];
    if (self.delegate && [self.delegate respondsToSelector:@selector(capture:didPressChangeMode:)]) {
        [self.delegate capture:self didPressChangeMode:button];
    }
}
- (void)handleChangeCameraButton:(UIButton *)button {
    __weak __typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf changeCamera];
    });
    if (self.delegate && [self.delegate respondsToSelector:@selector(capture:didPressChangeCamera:)]) {
        [self.delegate capture:self didPressChangeCamera:button];
    }
    
}
- (void)handleFlashButton:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(capture:didPressFlash:)]) {
        [self.delegate capture:self didPressFlash:button];
    }
}

- (void)handleTapToFocusGesture:(UITapGestureRecognizer *)focusGesture {
    if (self.isTapToFocusEnabled && self.isFocusPointOfInterestSupported) {
        CGPoint point = [focusGesture locationInView:self];
        [self focusAtPoint:[self.preview captureDevicePointOfInterestForPoint:point]];
        if (self.delegate && [self.delegate respondsToSelector:@selector(capture:didTapToFocusAt:)]) {
            [self.delegate capture:self didTapToFocusAt:point];
        }
    }

}
- (void)handleTapToExposeGesture:(UITapGestureRecognizer *)exposeGesture {

    if (self.isTapToExposeEnabled && self.isExposurePointOfInterestSupported) {
        CGPoint point = [exposeGesture locationInView:self];
        [self focusAtPoint:[self.preview captureDevicePointOfInterestForPoint:point]];
        if (self.delegate && [self.delegate respondsToSelector:@selector(capture:didTapToExposeAt:)]) {
            [self.delegate capture:self didTapToExposeAt:point];
        }
    }
    
}
- (void)handleTapToResetGesture:(UITapGestureRecognizer *)resetGesture {
    if (self.isTapToResetEnabled) {
        [self reset];
    }
    CGPoint point = [self.preview pointForCaptureDevicePointOfInterest:CGPointMake(0.5, 0.5)];
    if (self.delegate && [self.delegate respondsToSelector:@selector(capture:didTapToResetAt:)]) {
        [self.delegate capture:self didTapToResetAt:point];
    }
}

- (void)startTimer {
    [self.timer invalidate];
    self.timer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    if (self.delegate && [self.delegate respondsToSelector:@selector(capture:didStartRecord:)]) {
        [self.delegate capture:self didStartRecord:self.timer];
    }
}

- (void)updateTimer {
    CMTime duration = [self recordedDuration];
    Float64 time = CMTimeGetSeconds(duration);
    int hours = (int)(time / 3600);
    int minutes = (int)(time / 60) % 60;
    int seconds = (int)((NSInteger)time % 60);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(capture:didUpdateRecord:hours:minutes:seconds:)]) {
        [self.delegate capture:self didUpdateRecord:self.timer hours:hours minutes:minutes seconds:seconds];
    }
}

- (void)stopTimer {
    CMTime duration = [self recordedDuration];
    Float64 time = CMTimeGetSeconds(duration);
    int hours = (int)(time / 3600);
    int minutes = (int)(time / 60) % 60;
    int seconds = (int)((NSInteger)time % 60);
    
    [self.timer invalidate];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(capture:didStopRecord:hours:minutes:seconds:)]) {
        [self.delegate capture:self didStopRecord:self.timer hours:hours minutes:minutes seconds:seconds];
    }
    self.timer = nil;
}

#pragma mark -AVCaptureFileOutputRecordingDelegate
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections {
    
    self.isRecording = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(captureOutput:didStartRecordingToOutputFileAtURL:fromConnections:)]) {
        [self.delegate capture:self captureOutput:captureOutput didStartRecordingToOutputFileAt:fileURL fromConnections:connections];
    }
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
    
    self.isRecording = false;
    if (self.delegate && [self.delegate respondsToSelector:@selector(capture:captureOutput:didFinishRecordingToOutputFileAt:fromConnections:error:)]) {
        [self.delegate capture:self captureOutput:captureOutput didFinishRecordingToOutputFileAt:outputFileURL fromConnections:connections error:error];
    }
}



@end
