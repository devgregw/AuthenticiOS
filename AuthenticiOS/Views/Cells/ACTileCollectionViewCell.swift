//
//  ACTileCollectionViewCell.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 10/5/19.
//  Copyright © 2019 Greg Whatley. All rights reserved.
//

import UIKit

class ACTileCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    var action: (() -> Void)!
    
    @objc func clicked() {
        self.action()
    }
    
    public func initialize(imageResource: ACImageResource, width: CGFloat, action: @escaping () -> Void) {
        self.action = action
        self.indicator.startAnimating()
        imageResource.load(intoImageView: imageView, fadeIn: true, setSize: false, scaleDownLargeImages: false, completion: {self.indicator.stopAnimating()})
        rootView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.clicked)))
        imageWidthConstraint.constant = width - 16
        imageHeightConstraint.constant = ACImageResource(imageName: "", width: 1920, height: 1080).calculateHeight(fromWidth: width - 16)
        rootView.layer.cornerRadius = 8
        rootView.clipsToBounds = true
        layer.shadowColor = UIColor.darkGray.cgColor
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.625
        layer.shadowOffset = CGSize(width: 0, height: -1)
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        translatesAutoresizingMaskIntoConstraints = false
    }

}
