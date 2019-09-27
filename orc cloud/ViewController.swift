//
//  ViewController.swift
//  orc cloud
//
//  Created by Trinh Quang Hoc on 9/9/19.
//  Copyright © 2019 Trinh Quang Hoc. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var captureView: UIView!
    var captureSession: AVCaptureSession!
    var tapRecognizer: UITapGestureRecognizer!
    var capturePhotoOutput: AVCapturePhotoOutput!
    var readyImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
//        setupTapRecognizer()
        setupPhotoOutput()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        captureSession.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        captureSession.stopRunning()
    }

    private func setupCamera() {
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        var input: AVCaptureDeviceInput
        do {
            input = try AVCaptureDeviceInput(device: captureDevice!)
        } catch {
            fatalError("Error configuring capture device: \(error)");
        }
        captureSession = AVCaptureSession()
        captureSession.addInput(input)
        
        // Setup the preview view.
        let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer.frame = captureView.layer.bounds
        captureView.layer.addSublayer(videoPreviewLayer)
    }

//    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
//        if sender.state == .ended {
//            capturePhoto()
//        }
//    }
    
//    private func setupTapRecognizer() {
//        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
//        tapRecognizer?.numberOfTapsRequired = 1
//        tapRecognizer?.numberOfTouchesRequired = 1
//        view.addGestureRecognizer(tapRecognizer!)
//    }
    
    @IBAction func capture(_ sender: Any) {
        capturePhoto()
    }
    private func setupPhotoOutput() {
        capturePhotoOutput = AVCapturePhotoOutput()
        capturePhotoOutput.isHighResolutionCaptureEnabled = true
        captureSession.addOutput(capturePhotoOutput!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let imageViewController = segue.destination as? ImageViewController {
            imageViewController.image = readyImage
            imageViewController.crop = processImage()
        }
    }
}

extension ViewController : AVCapturePhotoCaptureDelegate {
    private func capturePhoto() {
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.isAutoStillImageStabilizationEnabled = true
        photoSettings.isHighResolutionPhotoEnabled = true
        photoSettings.flashMode = .auto
        capturePhotoOutput?.capturePhoto(with: photoSettings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        guard error == nil else {
            fatalError("Failed to capture photo: \(String(describing: error))")
        }
        guard let imageData = photo.fileDataRepresentation() else {
            fatalError("Failed to convert pixel buffer")
        }
        guard let image = UIImage(data: imageData) else {
            fatalError("Failed to convert image data to UIImage")
        }
        readyImage = image
//        readyImage = processImage(image: image)
        performSegue(withIdentifier: "ShowImageSegue", sender: self)
    }
    
    func processImage() -> CGRect {
        let x = captureView.frame.origin.x
        let y = captureView.frame.origin.y
        let width = captureView.frame.size.width
        let height = captureView.frame.size.height
//        print("\(x) \(y) \(width) \(height)")
        let crop = CGRect(x: x, y: y, width: width, height: height)
        
        return crop
    }
    
}
