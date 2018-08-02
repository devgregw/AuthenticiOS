//
//  UIView.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 8/1/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import UIKit

extension UIView {
    public func embedInStackViewWithInsets(top t: CGFloat, left l: CGFloat, bottom b: CGFloat, right r: CGFloat) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [self])
        stack.layoutMargins = UIEdgeInsets.init(top: t, left: l, bottom: b, right: r)
        stack.sizeToFit()
        stack.layoutIfNeeded()
        return stack
    }
}
