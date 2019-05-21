//
//  ACThumbnailButtonView.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 7/20/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class ACThumbnailButtonView: UIView {
    
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var thumbnailBackgroundView: UIView!
    
    private var origin: String
    
    init(vendor: String, id: String, thumb: String, title: String, origin: String) {
        self.origin = origin
        super.init(frame: CGRect.zero)
        initialize(action: #selector(self.watch))
        self.vendor = vendor
        self.id = id
        titleLabel.text = title
        self.thumbnailImage.alpha = 0
        thumbnailImage.sd_setImage(with: URL(string: thumb)!, placeholderImage: nil, options: SDWebImageOptions.scaleDownLargeImages, progress: nil, completed: { _, _, _, _ in
            UIView.animate(withDuration: 0.3, animations: {
                self.thumbnailImage.alpha = 1
                self.indicator.alpha = 0
                self.thumbnailBackgroundView.backgroundColor = UIColor.white
            }, completion: {_ in self.indicator.stopAnimating()})
        })
    }
    
    init(label: String, thumb: ACImageResource, action: ACButtonAction, origin: String) {
        self.origin = origin
        super.init(frame: CGRect.zero)
        initialize(action: #selector(self.open))
        self.buttonAction = action
        titleLabel.text = label
        thumb.load(intoImageView: thumbnailImage, fadeIn: true, setSize: false, scaleDownLargeImages: true, completion: {
            UIView.animate(withDuration: 0.3, animations: {
                self.indicator.alpha = 0
                self.thumbnailBackgroundView.backgroundColor = UIColor.white
            }, completion: {_ in self.indicator.stopAnimating()})
        })
    }
    
    override init(frame: CGRect) {
        self.origin = "::init"
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        self.origin = "::init"
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
        ACVideoViewController(provider: vendor, id: id).presentSelf(sender: nil)
    }
    
    func initialize(action: Selector) {
        let view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = UIView.AutoresizingMask(rawValue: UInt(UInt8(UIView.AutoresizingMask.flexibleWidth.rawValue) | UInt8(UIView.AutoresizingMask.flexibleHeight.rawValue)))
        view.layoutIfNeeded()
        let top = CALayer()
        top.frame = CGRect(x: 166, y: 0, width: view.frame.size.width + 224, height: 0.5)
        top.backgroundColor = UIColor.lightGray.cgColor
        view.layer.addSublayer(top)
        let bottom = CALayer()
        bottom.frame = CGRect(x: 166, y: view.frame.size.height, width: view.frame.size.width + 224, height: 0.5)
        bottom.backgroundColor = UIColor.lightGray.cgColor
        view.layer.addSublayer(bottom)
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: action))
        let rand = CGFloat(drand48())
        thumbnailBackgroundView.backgroundColor = UIColor(red: rand, green: rand, blue: rand, alpha: 1)
        indicator.color = UIColor(red: 1 - rand, green: 1 - rand, blue: 1 - rand, alpha: 1)
        indicator.center = CGPoint(x: 79, y: 50)
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        return UINib(nibName: "ACThumbnailButtonView", bundle: Bundle.main).instantiate(withOwner: self, options: nil)[0] as! UIView
    }
}
