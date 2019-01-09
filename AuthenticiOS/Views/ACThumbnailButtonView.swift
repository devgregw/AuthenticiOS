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
            })
        })
    }
    
    init(label: String, thumb: ACImageResource, action: ACButtonAction, origin: String) {
        self.origin = origin
        super.init(frame: CGRect.zero)
        initialize(action: #selector(self.open))
        self.buttonAction = action
        titleLabel.text = label
        thumb.load(intoImageView: thumbnailImage, fadeIn: true, setSize: false)
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
        AppDelegate.automaticPresent(viewController: ACVideoViewController(provider: vendor, id: id))
    }
    
    func initialize(action: Selector) {
        let view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = UIViewAutoresizing(rawValue: UInt(UInt8(UIViewAutoresizing.flexibleWidth.rawValue) | UInt8(UIViewAutoresizing.flexibleHeight.rawValue)))
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
        thumbnailImage.backgroundColor = UIColor(red: rand, green: rand, blue: rand, alpha: 1)
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        return UINib(nibName: "ACThumbnailButtonView", bundle: Bundle.main).instantiate(withOwner: self, options: nil)[0] as! UIView
    }
}
