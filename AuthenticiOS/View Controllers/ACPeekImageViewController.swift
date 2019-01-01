//
//  ACPeekImageViewController.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 1/1/19.
//  Copyright © 2019 Greg Whatley. All rights reserved.
//

import UIKit

class ACPeekImageViewController: UIViewController {
    static public var image: UIImage?
    static public var title: String?
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var imageView: UIImageView!
    var nameLabel: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = ACPeekImageViewController.image
        nameLabel = (ACElement.createTitle(text: ACPeekImageViewController.title!, alignment: "center", border: false, size: 24, color: .white, bold: true) as! UIStackView).arrangedSubviews[0]
        stackView.insertArrangedSubview(nameLabel, at: 0)
        //view.addSubview(nameLabel)
        //view.constraints.forEach({c in view.removeConstraint(c)})
        /*view.addConstraints([
            NSLayoutConstraint(item: nameLabel, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: nameLabel, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: nameLabel, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: nameLabel, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
            ])*/
        view.setNeedsLayout()
    }
}
