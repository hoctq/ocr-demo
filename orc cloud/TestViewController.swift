//
//  TestViewController.swift
//  orc cloud
//
//  Created by Trinh Quang Hoc on 9/23/19.
//  Copyright © 2019 Trinh Quang Hoc. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let image = UIImage(named: "aaaa")
        imageView.image = image

        // Do any additional setup after loading the view.
    }
    
    func processImage(image: UIImage) -> UIImage {
        let cgImage = image.cgImage!
        let x = imageView.frame.origin.x
        let y = imageView.frame.origin.y
        let width = imageView.frame.size.width
        let height = imageView.frame.size.height
        print("\(x) \(y) \(width) \(height)")
        let crop = CGRect(x: x, y: y, width: width, height: height)
        let imageRef: CGImage = cgImage.cropping(to: crop)!
        let img = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        return img
    }
    
    @IBAction func tapbtn(_ sender: Any) {
        print("gogo")
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
