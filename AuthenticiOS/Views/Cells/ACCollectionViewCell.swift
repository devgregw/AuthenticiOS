//
//  ACCollectionViewCell.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 5/25/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import UIKit
import FirebaseUI
import FirebaseStorage

class ACCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var image: UIImageView!
    
    private var text: String = ""
    private var imageResource = ACImageResource()
    
    private var eventsAppearance: ACAppearance.Events!
    private var viewController: UIViewController!
    private var tab: ACTab!
    private var event: ACEvent!
    
    @objc public func presentUpcomingEvents() {
        ACEventCollectionViewController.present(withAppearance: eventsAppearance)
    }
    
    @objc public func presentTab() {
        ACTabViewController.present(tab: self.tab)
    }
    
    @objc public func presentEvent() {
        ACEventViewController.present(event: self.event)
    }
    
    @objc public func invokeAction() {
        tab.action?.invoke(viewController: viewController)
    }
    
    public func initialize(forUpcomingEvents appearance: ACAppearance.Events, withViewController vc: UIViewController) {
        self.text = appearance.title
        self.imageResource = appearance.header
        self.eventsAppearance = appearance
        self.viewController = vc
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.presentUpcomingEvents)))
        self.initialize()
    }
    
    public func initialize(forTab tab: ACTab, withViewController vc: UIViewController) {
        self.text = tab.title
        self.imageResource = tab.header
        self.tab = tab
        self.viewController = vc
        if tab.action == nil {
            self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.presentTab)))
        } else {
            self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.invokeAction)))
        }
        self.initialize()
    }
    
    public func initialize(forEvent event: ACEvent, withViewController vc: UIViewController) {
        self.text = event.title
        self.imageResource = event.header
        self.event = event
        self.viewController = vc
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.presentEvent)))
        self.initialize()
    }
    
    private func initialize() {
        let rand = CGFloat(drand48())
        self.backgroundColor = UIColor(red: rand, green: rand, blue: rand, alpha: 1)
        image.alpha = 0
        self.subviews.forEach { v in
            if let l = v as? ACInsetLabel {
                l.removeFromSuperview()
            }
        }
        imageResource.load(intoImageView: image, fadeIn: true, setSize: false)
        let label = (ACElement.createTitle(text: self.text, alignment: "center", border: false, size: 18, color: UIColor.white, bold: true) as! UIStackView).arrangedSubviews[0]
        self.addSubview(label)
        self.constraints.forEach({c in self.removeConstraint(c)})
        self.addConstraints([
            NSLayoutConstraint(item: label, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: label, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
            ])
        self.setNeedsLayout()
    }
}
