//
//  ACImageCollectionViewCell.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 7/26/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import UIKit
import Firebase

class ACImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    private var viewController: UIViewController!
    private var imageResource: ACImageResource!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @objc public func preview() {
        viewController.present(ACWallpaperPreviewViewController(imageResource: imageResource), animated: true, completion: nil)
    }
    
    public func setImage(_ resource: ACImageResource, viewController: UIViewController) {
        let rand = CGFloat(drand48())
        indicator.isHidden = false
        backgroundColor = UIColor(red: rand, green: rand, blue: rand, alpha: 1)
        indicator.color = UIColor(red: 1 - rand, green: 1 - rand, blue: 1 - rand, alpha: 1)
        indicator.center = CGPoint(x: UIScreen.main.bounds.midX / 2, y: UIScreen.main.bounds.midX / 2)
        indicator.startAnimating()
        self.viewController = viewController
        self.imageResource = resource
        gestureRecognizers = []
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.preview)))
        resource.load(intoImageView: imageView, fadeIn: true, setSize: false, scaleDownLargeImages: true, completion: {
            UIView.animate(withDuration: 0.3, animations: {
                self.backgroundColor = UIColor.white
                self.indicator.isHidden = true
            }, completion: {_ in self.indicator.stopAnimating()})
        })
    }
}
