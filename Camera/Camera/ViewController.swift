//
//  ViewController.swift
//  Camera
//
//  Created by naver on 2018/11/20.
//  Copyright © 2018 naver. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class ViewController: UIViewController {
    
    @IBOutlet var videPreViewView: GLView!
    
    private let session = AVCaptureSession()
    private let queue = DispatchQueue(label: "com.shuang.song.capturesession")

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSession()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startCamera()
    }
    
    private func configureSession() {
        session.beginConfiguration()
        do {
            var defaultVideoDevice: AVCaptureDevice?
            if let dualCameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
                defaultVideoDevice = dualCameraDevice
            } else if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                defaultVideoDevice = backCameraDevice
            }
            
            guard let videoDevice = defaultVideoDevice else { return }
            let deviceInput = try AVCaptureDeviceInput(device: videoDevice)
            if session.canAddInput(deviceInput) {
                session.addInput(deviceInput)
            }
            
            
            
            let videoOutPut = AVCaptureVideoDataOutput()
            videoOutPut.alwaysDiscardsLateVideoFrames = false
            videoOutPut.videoSettings = [String(kCVPixelBufferPixelFormatTypeKey): kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange]
            if session.canAddOutput(videoOutPut) {
                session.addOutput(videoOutPut)
            }
            videoOutPut.setSampleBufferDelegate(self, queue: queue)
            
        } catch {
            print("\(error)")
            return
        }
        session.commitConfiguration()
    }
    
    private func startCamera() {
        session.startRunning()
    }
    


}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if let pixleBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            videPreViewView.display(pixleBuffer)
        }
    }
    
    
}
