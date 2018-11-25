//
//  ACToolbarView.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 9/29/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import UIKit
import FirebaseUI
import FirebaseStorage

class ACToolbarView: UIView {
    @IBOutlet weak var toolbarImage: UIImageView!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var rightView: UIView!
    
    private var leftAction: ACButtonAction!
    private var rightAction: ACButtonAction!
    private var imageResource = ACImageResource()
    private var height: CGFloat = CGFloat(200)
    
    private var viewController: UIViewController!
    private var action: ACButtonAction!
    
    @objc public func invokeLeftAction() {
        self.leftAction.invoke(viewController: self.viewController)
    }
    
    @objc public func invokeRightAction() {
        self.rightAction.invoke(viewController: self.viewController)
    }
    
    public func initialize(withImage header: ACImageResource, leftAction: ACButtonAction, rightAction: ACButtonAction, viewController vc: UIViewController) {
        self.imageResource = header
        self.viewController = vc
        self.leftAction = leftAction
        self.rightAction = rightAction
        self.leftView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.invokeLeftAction)))
        self.rightView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.invokeRightAction)))
        self.initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func initialize() {
        frame = CGRect.zero
        autoresizingMask = UIViewAutoresizing(rawValue: UInt(UInt8(UIViewAutoresizing.flexibleWidth.rawValue) | UInt8(UIViewAutoresizing.flexibleHeight.rawValue)))
        let rand = CGFloat(drand48())
        self.backgroundColor = UIColor(red: rand, green: rand, blue: rand, alpha: 1)
        toolbarImage.alpha = 0
        imageResource.load(intoImageView: toolbarImage, fadeIn: true, setSize: false)
        let newHeight = (CGFloat(imageResource.height) / CGFloat(imageResource.width)) * UIScreen.main.bounds.width
        self.constraints.forEach({c in self.removeConstraint(c)})
        self.addConstraints([
            NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: newHeight),
            //NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: UIScreen.main.bounds.width),
            //NSLayoutConstraint(item: toolbarImage, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: newHeight),
            //NSLayoutConstraint(item: toolbarImage, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: UIScreen.main.bounds.width),
            NSLayoutConstraint(item: toolbarImage, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: toolbarImage, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: toolbarImage, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: toolbarImage, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: leftView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: leftView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: leftView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: leftView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: CGFloat(0.5), constant: 0),
            NSLayoutConstraint(item: rightView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: CGFloat(0.5), constant: 0),
            NSLayoutConstraint(item: rightView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: rightView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: rightView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        ])
        self.setNeedsLayout()
        self.layoutIfNeeded()
        self.clipsToBounds = true
    }
}
