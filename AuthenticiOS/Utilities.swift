//
//  Utilities.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 2/7/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorageUI

class GWLabel: UILabel {
    private var top: CGFloat = 0
    private var left: CGFloat = 0
    private var bottom: CGFloat = 0
    private var right: CGFloat = 0
    
    func setInsets(top t: CGFloat, left l: CGFloat, bottom b: CGFloat, right r: CGFloat) {
        self.top = t
        self.left = l
        self.bottom = b
        self.right = r
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, UIEdgeInsets(top: self.top, left: self.left, bottom: self.bottom, right: self.right)))
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            var contentSize = super.intrinsicContentSize
            contentSize.height += top + bottom
            contentSize.width += left + right
            return contentSize
        }
    }
}

class Utilities {
    static func applyTintColor(to vc: UIViewController) {
        vc.navigationController?.navigationBar.barTintColor = UIColor.black
    }
    
    static func literalToNSDictionary(_ literal: [(key: Any, value: Any)]) -> NSDictionary {
        var k: [NSCopying] = []
        var v: [Any] = []
        literal.forEach({ e in k.append(e.key as! NSCopying); v.append(e.value) })
        return NSDictionary(objects: v, forKeys: k)
    }
    
    static func loadFirebase(image: String, into: UIImageView) {
        into.sd_setImage(with: Storage.storage().reference().child(image), placeholderImage: nil, completion: { (i, e, c, r) in
            if (i == nil) {
                return
            }
            let newHeight = (i!.size.height / i!.size.width) * (UIScreen.main.bounds.width)
            into.addConstraint(NSLayoutConstraint(item: into, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: newHeight))
        })
    }
}
