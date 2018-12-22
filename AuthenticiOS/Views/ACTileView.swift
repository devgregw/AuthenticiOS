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

class ACTileView: UIView {
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var tintView: UIView!
    
    private var text: String = ""
    private var imageResource = ACImageResource()
    private var height: CGFloat = CGFloat(200)
    
    private var origin: String!
    
    private var viewController: UIViewController!
    private var action: ACButtonAction!
    
    @objc public func invokeAction() {
        action.invoke(viewController: viewController, origin: "tile:\(origin!)")
    }
    
    public func initialize(withTitle title: String, height: Int, header: ACImageResource, action: ACButtonAction, viewController vc: UIViewController, origin: String) {
        self.height = CGFloat(height)
        self.text = title
        self.imageResource = header
        self.viewController = vc
        self.action = action
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.invokeAction)))
        self.origin = origin
        self.initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func loadViewFromNib() -> UIView {
        return UINib(nibName: "ACTileView", bundle: Bundle.main).instantiate(withOwner: self, options: nil)[0] as! UIView
    }
    
    private func initialize() {
        //let view = loadViewFromNib()
        frame = CGRect.zero
        autoresizingMask = UIViewAutoresizing(rawValue: UInt(UInt8(UIViewAutoresizing.flexibleWidth.rawValue) | UInt8(UIViewAutoresizing.flexibleHeight.rawValue)))
        //view.layoutIfNeeded()
        let rand = CGFloat(drand48())
        self.backgroundColor = UIColor(red: rand, green: rand, blue: rand, alpha: 1)
        image.alpha = 0
        self.subviews.forEach { v in
            if let l = v as? ACInsetLabel {
                l.removeFromSuperview()
            }
        }
        self.tintView.alpha = self.text == "" ? 0 : 1
        imageResource.load(intoImageView: image, fadeIn: true, setSize: false, completion: { UIView.animate(withDuration: 0.3, animations: {self.backgroundColor = UIColor.white}) })
        let label = (ACElement.createTitle(text: self.text, alignment: "center", border: false, size: 18, color: UIColor.white, bold: true) as! UIStackView).arrangedSubviews[0]
        self.addSubview(label)
        self.image.clipsToBounds = true
        self.constraints.forEach({c in self.removeConstraint(c)})
        self.addConstraints([
            NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: self.height + 1),
            //NSLayoutConstraint(item: image, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1, constant: 0),
            //NSLayoutConstraint(item: image, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: UIScreen.main.bounds.width),
            NSLayoutConstraint(item: image, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: image, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -1),
            NSLayoutConstraint(item: image, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: image, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0),
            /*NSLayoutConstraint(item: tintView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: self.height),
            NSLayoutConstraint(item: tintView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: UIScreen.main.bounds.width),*/
            NSLayoutConstraint(item: tintView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: tintView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -1),
            NSLayoutConstraint(item: tintView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: tintView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: label, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1, constant: -1),
            NSLayoutConstraint(item: label, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: -1),
            NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
            ])
        self.setNeedsLayout()
        self.layoutIfNeeded()
        self.clipsToBounds = true
        //addSubview(view)
    }
}
