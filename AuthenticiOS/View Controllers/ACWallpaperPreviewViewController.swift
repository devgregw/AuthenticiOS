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
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        present(loadingAlert, animated: true, completion: {
            UIImageWriteToSavedPhotosAlbum(self.imageView.image!, self, #selector(self.saveCompletion(_:didFinishSavingWithError:contextInfo:)), nil)
        })
    }
    
    private let imageName: String
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
        visualEffectView.layer.cornerRadius = 16
        Utilities.loadFirebase(image: imageName, into: imageView)
        loadingAlert = UIAlertController(title: nil, message: "Saving image...", preferredStyle: .alert)
        let indicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        indicator.hidesWhenStopped = true
        indicator.activityIndicatorViewStyle = .gray
        indicator.startAnimating()
        loadingAlert.view.addSubview(indicator)
    }

    init(imageName: String) {
        self.imageName = imageName
        super.init(nibName: "ACWallpaperPreviewViewController", bundle: Bundle.main)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.imageName = ""
        super.init(coder: aDecoder)
    }
}
