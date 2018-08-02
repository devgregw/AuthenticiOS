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
        resource.load(intoImageView: imageView, fadeIn: true, setSize: false)
        let rand = CGFloat(drand48())
        backgroundColor = UIColor(red: rand, green: rand, blue: rand, alpha: 1)
        self.viewController = viewController
        self.imageResource = resource
        gestureRecognizers = []
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.preview)))
    }
}
