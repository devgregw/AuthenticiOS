//
//  ACHalfThumbnailButtonView.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 8/21/19.
//  Copyright © 2019 Greg Whatley. All rights reserved.
//

import UIKit
import Foundation
import SDWebImage

class ACHalfThumbnailButtonView: UIView {

    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var thumbnailBackgroundView: UIView!
    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var titleLabelViewHeight: NSLayoutConstraint!
    
    private var origin: String
    private let hideTitle: Bool
    
    init(vendor: String, id: String, thumb: String, title: String, hideTitle: Bool, origin: String) {
        self.origin = origin
        self.hideTitle = hideTitle
        super.init(frame: CGRect.zero)
        initialize(action: #selector(self.watch), resource: ACImageResource(imageName: "unknown.png", width: 1920, height: 1080))
        self.vendor = vendor
        self.id = id
        self.accessibilityLabel = title
        titleLabel.text = title
        self.thumbnailImage.alpha = 0
        thumbnailImage.sd_setImage(with: URL(string: thumb)!, placeholderImage: nil, options: SDWebImageOptions.scaleDownLargeImages, progress: nil, completed: { _, _, _, _ in
            UIView.animate(withDuration: 0.3, animations: {
                self.thumbnailImage.alpha = 1
                self.indicator.isHidden = true
                self.thumbnailBackgroundView.backgroundColor = UIColor.white
            }, completion: {_ in self.indicator.stopAnimating()})
        })
    }
    
    init(label: String, thumb: ACImageResource, action: ACButtonAction, hideTitle: Bool, origin: String) {
        self.origin = origin
        self.hideTitle = hideTitle
        super.init(frame: CGRect.zero)
        initialize(action: #selector(self.open), resource: thumb)
        self.buttonAction = action
        titleLabel.text = label
        self.accessibilityLabel = title
        thumb.load(intoImageView: thumbnailImage, fadeIn: true, setSize: false, scaleDownLargeImages: true, completion: {
            UIView.animate(withDuration: 0.3, animations: {
                self.indicator.isHidden = true
                self.thumbnailBackgroundView.backgroundColor = UIColor.white
            }, completion: {_ in self.indicator.stopAnimating()})
        })
    }
    
    override init(frame: CGRect) {
        self.origin = "::init"
        self.hideTitle = false
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.origin = "::init"
        self.hideTitle = false
        super.init(coder: aDecoder)
    }
    
    private var vendor: String!
    private var id: String!
    
    private var buttonAction: ACButtonAction!
    
    private var title: String!
    
    @objc func open() {
        buttonAction.invoke(viewController: AppDelegate.topViewController, origin: "thumbnailButton:\(origin)", medium: "open")
    }
    
    @objc func watch() {
        StoryboardHelper.instantiateVideoViewController(with: vendor, id: id).presentSelf(sender: nil)
    }
    
    func initialize(action: Selector, resource: ACImageResource) {
        let view = loadViewFromNib()
        
        if hideTitle {
            titleLabel.removeFromSuperview()
            titleLabelViewHeight.constant = 0
        }
        
        self.accessibilityTraits = [.allowsDirectInteraction, .button]
        self.isAccessibilityElement = true
        
        view.layer.masksToBounds = false
        rootView.layer.cornerRadius = 8
        rootView.clipsToBounds = true
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.75
        view.layer.shadowOffset = CGSize(width: 0, height: -1)
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.scale
        
        let widthMargin = CGFloat(16)
        let heightMargin = CGFloat(20)
        self.addConstraint(NSLayoutConstraint(item: rootView!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: resource.calculateHeight(fromWidth: (UIScreen.main.bounds.width / 2) - widthMargin) + heightMargin - 22.5))
        self.addConstraint(NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: UIScreen.main.bounds.width / 2))
        view.frame = bounds
        view.autoresizingMask = UIView.AutoresizingMask(rawValue: UInt(UInt8(UIView.AutoresizingMask.flexibleWidth.rawValue) | UInt8(UIView.AutoresizingMask.flexibleHeight.rawValue)))
        view.layoutIfNeeded()
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: action))
        let rand = CGFloat(drand48())
        thumbnailBackgroundView.backgroundColor = UIColor(red: rand, green: rand, blue: rand, alpha: 1)
        indicator.color = UIColor(red: 1 - rand, green: 1 - rand, blue: 1 - rand, alpha: 1)
        indicator.center = CGPoint(x: 79, y: 50)
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        return UINib(nibName: "ACHalfThumbnailButtonView", bundle: Bundle.main).instantiate(withOwner: self, options: nil)[0] as! UIView
    }

}
