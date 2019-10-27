//
//  ACWallpaperPreviewViewController.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 7/26/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import UIKit

class ACWallpaperPreviewViewController: UIViewController {
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        present(loadingAlert, animated: true, completion: {
            UIImageWriteToSavedPhotosAlbum(self.imageView.image!, self, #selector(self.saveCompletion(_:didFinishSavingWithError:contextInfo:)), nil)
        })
    }
    
    public var imageResource: ACImageResource!
    private var loadingAlert: UIAlertController!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc public func saveCompletion(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeMutableRawPointer?) {
        loadingAlert.dismiss(animated: true, completion: {
            guard error == nil else {
                let alert = UIAlertController(title: "Error", message: "An error occurred while saving the image.\n\n\(error!.localizedDescription)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.saveButton.isEnabled = false
        self.saveButton.alpha = 0.5
        let rand = CGFloat(drand48())
        self.view.backgroundColor = UIColor(red: rand, green: rand, blue: rand, alpha: 1)
        self.indicator.color = UIColor(red: 1 - rand, green: 1 - rand, blue: 1 - rand, alpha: 1)
        self.indicator.center = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
        self.imageResource.load(intoImageView: self.imageView, fadeIn: true, setSize: false, scaleDownLargeImages: false, completion: {
            self.saveButton.isEnabled = true
            UIView.animate(withDuration: 0.3, animations: {
                self.view.backgroundColor = UIColor.white
                self.indicator.alpha = 0
                self.saveButton.alpha = 1
            }, completion: {_ in
                self.indicator.stopAnimating()
            })
        })
        self.imageView.clipsToBounds = true
        
        loadingAlert = UIAlertController(title: nil, message: "Saving image...", preferredStyle: .alert)
        let saveIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        saveIndicator.hidesWhenStopped = true
        if #available(iOS 13.0, *) {
            saveIndicator.style = .medium
        } else {
            saveIndicator.style = .gray
        }
        saveIndicator.startAnimating()
        loadingAlert.view.addSubview(saveIndicator)
    }
}
