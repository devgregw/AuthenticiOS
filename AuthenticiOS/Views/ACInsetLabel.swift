//
//  ACInsetLabel.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 8/1/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import Foundation
import UIKit

class ACInsetLabel: UILabel {
    override var alignmentRectInsets: UIEdgeInsets {
        return UIEdgeInsets.init(top: -5, left: -5, bottom: -5, right: -5)
    }
    
    private let insets = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        let superSize = super.intrinsicContentSize
        let w = superSize.width + insets.left + insets.right
        let h = superSize.height + insets.top + insets.bottom
        return CGSize(width: w, height: h)
    }
}
