//
//  ACCollectionViewCell.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 5/25/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import UIKit
import FirebaseStorageUI
import FirebaseStorage

class ACCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var image: UIImageView!
    
    private var text: String = ""
    private var imageName: String = ""
    
    override func layoutSubviews() {
        image.alpha = 0
        self.subviews.forEach { v in
            if let l = v as? ACInsetLabel {
                l.removeFromSuperview()
            }
        }
        image.sd_setImage(with: Storage.storage().reference().child(imageName), placeholderImage: nil, completion: { (i, e, c, r) in
            UIView.animate(withDuration: 0.3, animations: {
                self.image.alpha = 1
            })
        })
        let label = (AuthenticElement.createTitle(text: self.text, alignment: "center", size: 22, color: UIColor.white) as! UIStackView).arrangedSubviews[0]
        self.addSubview(label)
        self.addConstraints([
            NSLayoutConstraint(item: label, attribute: .height, relatedBy: .lessThanOrEqual, toItem: self, attribute: .height, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: label, attribute: .width, relatedBy: .lessThanOrEqual, toItem: self, attribute: .width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
            ])
        super.layoutSubviews()
    }
    
    public func initialize(forUpcomingEvents appearance: AuthenticAppearance.Events) {
        self.text = appearance.title
        self.imageName = appearance.header
        self.initialize()
    }
    
    public func initialize(forTab tab: AuthenticTab) {
        self.text = tab.title
        self.imageName = tab.header
        self.initialize()
    }
    
    private func initialize() {
        print("cell initialized: \(self.text), \(self.imageName)")
        let rand = CGFloat(drand48())
        self.backgroundColor = UIColor(red: rand, green: rand, blue: rand, alpha: 1)
        self.setNeedsLayout()
    }
}
