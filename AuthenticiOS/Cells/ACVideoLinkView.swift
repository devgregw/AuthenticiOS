//
//  ACVideoLinkView.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 7/20/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import UIKit

class ACVideoLinkView: UIView {
    
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var width: NSLayoutConstraint!
    
    init(vendor: String, id: String, thumb: String, title: String) {
        super.init(frame: CGRect.zero)
        setup(vendor, id, thumb, title)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup("", "", "", "")
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup("", "", "", "")
    }
    
    private var vendor: String!
    private var id: String!
    
    @objc func open() {
        UIApplication.shared.open(URL(string: self.vendor! == "YouTube" ? "https://youtube.com/watch?v=\(self.id!)" : "https://vimeo.com/\(self.id!)")!, options: [:], completionHandler: nil)
    }
    
    func setup(_ v: String, _ i: String, _ th: String, _ ti: String) {
        self.vendor = v
        self.id = i
        let view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = UIViewAutoresizing(rawValue: UInt(UInt8(UIViewAutoresizing.flexibleWidth.rawValue) | UInt8(UIViewAutoresizing.flexibleHeight.rawValue)))
        titleLabel.text = ti
        thumbnailImage.sd_setImage(with: URL(string: th)!, completed: nil)
        //width.constant = UIScreen.main.bounds.width / 2
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
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.open)))
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        return UINib(nibName: "ACVideoLinkView", bundle: Bundle.main).instantiate(withOwner: self, options: nil)[0] as! UIView
    }
}
