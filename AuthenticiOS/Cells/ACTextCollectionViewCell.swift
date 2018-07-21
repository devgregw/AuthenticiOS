//
//  ACTextCollectionViewCell.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 7/17/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import UIKit

class ACTextCollectionViewCell: UICollectionViewCell {
    func setText(_ text: String) {
        self.subviews.forEach { v in
            v.removeFromSuperview()
        }
        let label = AuthenticElement.createText(text: text, alignment: "center", size: 18, color: UIColor.black).arrangedSubviews[0]
            label.alpha = 1
            self.addSubview(label)
            self.addConstraints([
                NSLayoutConstraint(item: label, attribute: .height, relatedBy: .lessThanOrEqual, toItem: self, attribute: .height, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: label, attribute: .width, relatedBy: .lessThanOrEqual, toItem: self, attribute: .width, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
                ])
    }
}
