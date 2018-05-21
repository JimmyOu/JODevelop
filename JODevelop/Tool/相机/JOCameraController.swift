//
//  JOCameraController.swift
//  JODevelop
//
//  Created by JimmyOu on 2018/3/2.
//  Copyright © 2018年 JimmyOu. All rights reserved.
//

import Foundation
import AVFoundation
let JOTHumbnailCreateNotification = "JOTHumbnailCreateNotification"

protocol JOCameraControllerDelegate: class{
    func deviceConfigurationFailedWithError(error: Error)
    func mediaCaptureFailedWithError(error: Error)
    func assetLibraryWriteFailedWithError(error: Error)
}


class JOCameraController {
    weak var delegate: JOCameraControllerDelegate?
    lazy var captureSession: AVCaptureSession = {
        let session = AVCaptureSession();
        session.sessionPreset = AVCaptureSessionPresetHigh
        return session
    }()
    
    func setupSession() throws -> Bool{
        return true
    }
    
    func setupSessionInputs() throws -> Bool{
        return true
    }
    func setupSessionOutputs() throws -> Bool {
        return true
    }
    func startSession() {
        
    }
    //camera device support
    func switchCameras() -> Bool {
        return true
    }
    var cameraCount: Int {
        get {
            return 0
        }
    }
    var activeCamera: AVCaptureSession {
        get {
            return AVCaptureSession()
        }
    }
    
    //still Image Capture
    func captureStillImage() {
        
    }
    // video recording
    func startRecording() {
        
    }
    func stopRecording() {
        
    }
    func isRecording() -> Bool {
        return true
    }
    
    private var activeVideoInput: AVCaptureDeviceInput?
    private var imageOutput = AVCaptureStillImageOutput()
    private var movieOutput = AVCaptureMovieFileOutput()
    private var outputURL: URL {
        get {
            let dirPath = NSTemporaryDirectory() + "kamera_movie.mov"
            return URL(string:dirPath)!
        }
    }
    
    
    
    
    
    
    
    
}
