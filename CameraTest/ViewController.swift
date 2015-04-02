//
//  ViewController.swift
//  CameraTest
//
//  Created by lostin1 on 2015. 3. 19..
//  Copyright (c) 2015년 lostin. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    var captureDevice:AVCaptureDevice!
    let captureSession = AVCaptureSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        let devices = AVCaptureDevice.devices()
        println(devices)
        
        for device in devices {
            if device.hasMediaType(AVMediaTypeVideo) {
                if device.position == AVCaptureDevicePosition.Back {
                    captureDevice = device as AVCaptureDevice
                }
            }
        }
        if captureDevice != nil {
            beginSession()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func beginSession() {
        var error:NSError? = nil
        captureSession.addInput(AVCaptureDeviceInput(device: captureDevice, error: &error))
        
        if error != nil {
            println("error: \(error?.localizedDescription)")
        }
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.view.layer.addSublayer(previewLayer)
        previewLayer.frame = self.view.layer.frame
        captureSession.startRunning()
    }
    
    func configureDevice() {
        if let device = captureDevice {
            device.lockForConfiguration(nil)
            device.focusMode = .Locked
            device.unlockForConfiguration()
        }
    }
    
    func focusTo(value:Float) {
        if let device = captureDevice {
            if device.lockForConfiguration(nil) {
                device.setFocusModeLockedWithLensPosition(value, completionHandler: {(time)->Void in})
                device.unlockForConfiguration()
            }
        }
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let touchPer = touchPercent(touches.anyObject() as UITouch)
        updateDeviceSettings(Float(touchPer.x), isoValue: Float(touchPer.y))
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        let touchPer = touchPercent(touches.anyObject() as UITouch)
        updateDeviceSettings(Float(touchPer.x), isoValue: Float(touchPer.y))
    }
    
    func touchPercent(touch:UITouch) -> CGPoint {
        let screenSize = UIScreen.mainScreen().bounds.size
        var touchPer = CGPointZero
        
        touchPer.x = touch.locationInView(self.view).x/screenSize.width
        touchPer.y = touch.locationInView(self.view).y/screenSize.height
        
        return touchPer
    }
    
    func updateDeviceSettings(focusValue : Float, isoValue : Float) {
        if let device = captureDevice {
            if(device.lockForConfiguration(nil)) {
                device.setFocusModeLockedWithLensPosition(focusValue, completionHandler: { (time) -> Void in
                    //
                })
                
                // Adjust the iso to clamp between minIso and maxIso based on the active format
                let minISO = device.activeFormat.minISO
                let maxISO = device.activeFormat.maxISO
                let clampedISO = isoValue * (maxISO - minISO) + minISO
                
                device.setExposureModeCustomWithDuration(AVCaptureExposureDurationCurrent, ISO: clampedISO, completionHandler: { (time) -> Void in
                    //
                })
                
                device.unlockForConfiguration()
            }
        }
    }
}

