//
//  ImageViewController.swift
//  orc cloud
//
//  Created by Trinh Quang Hoc on 9/10/19.
//  Copyright © 2019 Trinh Quang Hoc. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {

    var image: UIImage!
    var activityIndicator: UIActivityIndicatorView!
    var crop: CGRect!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let resizedImage = resize(image: image, to: view.frame.size) else {
            fatalError("Error resizing image")
        }
        let imageView = UIImageView(frame: view.frame)
        imageView.contentMode = .scaleAspectFit
        let crImg = cropImage(image, toRect: crop, viewWidth: view.frame.width, viewHeight: view.frame.height)
        imageView.image = crImg
        view.addSubview(imageView)

        let prImg = processImage(image: resizedImage)
        setupCloseButton()
        setupActivityIndicator()
        detectBoundingBoxes(for: prImg)
    }

    private func setupCloseButton() {
        let closeButton = UIButton()
        view.addSubview(closeButton)
        
        // Stylistic features.
        closeButton.setTitle("✕", for: .normal)
        closeButton.setTitleColor(UIColor.gray, for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 32)
        
        // Add a target function when the button is tapped.
        closeButton.addTarget(self, action: #selector(closeAction), for: .touchDown)
        
        // Constrain the button to be positioned in the top left corner (with some offset).
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
    }
    
    @objc private func closeAction() {
        dismiss(animated: false, completion: nil)
    }

    private func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        activityIndicator.startAnimating()
    }
    
    private func detectBoundingBoxes(for image: UIImage) {
        GoogleCloudOCR().detect(from: image) { ocrResult in
            self.activityIndicator.stopAnimating()
            guard let ocrResult = ocrResult else {
                fatalError("Did not recognize any text in this image")
            }
            let result = self.extractEmailAddrIn(text: ocrResult.annotations[0].text)
            print(result)
            if result.count == 0 {
                let alert = UIAlertController(title: "Email not found", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    self.dismiss(animated: false, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
                for i in 1...result.count{
                    alert.addAction(UIAlertAction(title: result[i-1].replacingOccurrences(of: " ", with: ""), style: .default, handler: { action in
                        self.dismiss(animated: false, completion: nil)
                    }))
                }
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    self.dismiss(animated: false, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func extractEmailAddrIn(text: String) -> [String] {
        var results = [String]()
        print(text)
        let emailRegex = "[A-Z0-9a-z._%+-]+[ A-Z0-9a-z._%+-]+@[ A-Za-z0-9.-]+\\.[ a-z]{2,6}"
        let nsText = text as NSString
        do {
            let regExp = try NSRegularExpression(pattern: emailRegex, options: .caseInsensitive)
            let range = NSMakeRange(0, nsText.length)
            let matches = regExp.matches(in: text, options: .reportProgress, range: range)

            for match in matches {
                let matchRange = match.range
                results.append(nsText.substring(with: matchRange))
            }
        } catch _ {
        }
        return results
    }
    
    private func resize(image: UIImage, to targetSize: CGSize) -> UIImage? {
//        print(targetSize)
        let size = image.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle.
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }

        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height + 1)
//        print(newSize)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func processImage(image: UIImage) -> UIImage {
        let cgImage = image.cgImage!
//        print(crop!)
//        print("imgsize1\(image.size)")
        let imageRef: CGImage = cgImage.cropping(to: crop)!
        let img = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
//        print("imgsize2\(img.size)")
        return img
    }
    
    func cropImage1(image: UIImage) -> UIImage {
        let cgImage = image.cgImage!
        let size = image.size
//        print(size)
        let widthRatio = view.frame.size.width / size.width
        let heighRatio = view.frame.size.height / size.height
        var newCrop: CGRect
        if (widthRatio > heighRatio) {
            newCrop = CGRect(x: self.crop.origin.x / heighRatio, y: self.crop.origin.y / heighRatio, width: self.crop.width / heighRatio, height: self.crop.height / heighRatio)
        } else {
//            newCrop = CGRect(x: self.crop.origin.x / widthRatio, y: self.crop.origin.y / widthRatio, width: self.crop.height / widthRatio, height: self.crop.width / widthRatio)
            newCrop = CGRect(x: 108, y: 30, width: self.crop.height / widthRatio, height: self.crop.width / widthRatio)
            
        }
//        print(newCrop)
        let imageRef: CGImage = cgImage.cropping(to: newCrop)!
        let img = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
//        print("imgsize3\(img.size)")
        return img
    }
    func cropImage(_ inputImage: UIImage, toRect cropRect: CGRect, viewWidth: CGFloat, viewHeight: CGFloat) -> UIImage?
    {
        let imageViewScale = max(inputImage.size.width / viewWidth,
                                 inputImage.size.height / viewHeight)

        // Scale cropRect to handle images larger than shown-on-screen size
        let cropZone = CGRect(x:cropRect.origin.y * imageViewScale,
                              y:cropRect.origin.x * imageViewScale,
                              width:cropRect.size.height * imageViewScale,
                              height:cropRect.size.width * imageViewScale)

        // Perform cropping in Core Graphics
        guard let cutImageRef: CGImage = inputImage.cgImage?.cropping(to:cropZone)
        else {
            return nil
        }
//        print(inputImage.size)
//        print(cropZone)
        // Return image to UIImage
        let croppedImage: UIImage = UIImage(cgImage: cutImageRef, scale: inputImage.scale, orientation: inputImage.imageOrientation)
//        print("imgsize4\(croppedImage.size)")
        return croppedImage
    }
}
