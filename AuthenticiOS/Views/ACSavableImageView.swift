//
//  ACSavableImageView.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 8/1/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import Foundation
import UIKit

class ACSavableImageView: UIImageView {
    private var imageResource: ACImageResource
    private var vc: UIViewController
    private var loadingAlert: UIAlertController
    
    init(imageResource: ACImageResource, viewController vc: UIViewController) {
        self.imageResource = ACImageResource()
        self.vc = vc
        loadingAlert = UIAlertController(title: nil, message: "Saving image...", preferredStyle: .alert)
        let indicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        indicator.hidesWhenStopped = true
        if #available(iOS 13.0, *) {
            indicator.style = .medium
        } else {
            indicator.style = .gray
        }
        indicator.startAnimating()
        loadingAlert.view.addSubview(indicator)
        super.init(image: nil)
        imageResource.load(intoImageView: self, fadeIn: true, setSize: true, scaleDownLargeImages: false)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.expand)))
        self.isUserInteractionEnabled = true
    }
    
    @objc public func saveCompletion(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeMutableRawPointer?) {
        loadingAlert.dismiss(animated: true, completion: {
            guard error == nil else {
                let alert = UIAlertController(title: "Error", message: "An error occurred while saving the image.\n\n\(error!.localizedDescription)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                self.vc.present(alert, animated: true, completion: nil)
                return
            }
            let alert = UIAlertController(title: "Image Saved", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            self.vc.present(alert, animated: true, completion: nil)
        })
    }
    
    @objc public func expand() {
        vc.present(loadingAlert, animated: true, completion: {
            UIImageWriteToSavedPhotosAlbum(self.image!, self, #selector(self.saveCompletion(_:didFinishSavingWithError:contextInfo:)), nil)
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
