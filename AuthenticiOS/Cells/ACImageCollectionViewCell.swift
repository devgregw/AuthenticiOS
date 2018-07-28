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
    private var imageName: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @objc public func preview() {
        viewController.present(ACWallpaperPreviewViewController(imageName: imageName), animated: true, completion: nil)
    }
    
    public func setImage(_ resource: ImageResource, viewController: UIViewController) {
        imageView.sd_setImage(with: Storage.storage().reference().child(resource.imageName))
        let rand = CGFloat(drand48())
        imageView.backgroundColor = UIColor(red: rand, green: rand, blue: rand, alpha: 1)
        self.viewController = viewController
        self.imageName = resource.imageName
        gestureRecognizers = []
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.preview)))
    }
}
