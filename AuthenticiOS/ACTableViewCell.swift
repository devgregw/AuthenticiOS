//
//  ACTableViewCell.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 1/2/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorageUI

class ACTableViewCell: UITableViewCell {
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    private var tab: AuthenticTab?
    private var event: AuthenticEvent?
    private var action: (() -> Void)?
    private var viewController: UIViewController?
    
    @IBAction func didRecognizeTap(_ sender: UITapGestureRecognizer) {
        if (tab != nil) {
            ACTabViewController.present(tab: self.tab!, withViewController: self.viewController!)
        } else if (event != nil) {
            ACEventViewController.present(event: self.event!, withViewController: self.viewController!)
        } else {
            action!()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.headerImage.layer.masksToBounds = true
        self.contentView.layer.cornerRadius = 10
        self.contentView.layer.masksToBounds = true//false
        self.contentView.layer.borderColor = UIColor.black.cgColor
        self.contentView.layer.borderWidth = 0.5
        self.contentView.frame = UIEdgeInsetsInsetRect(self.contentView.frame, UIEdgeInsetsMake(0, 10, 0, 10))
    }
    
    func initializeForUpcomingEvents(withAppearance appearance: AuthenticAppearance.Events, viewController: UIViewController) {
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didRecognizeTap(_:))))
        self.action = {
            ACEventListController.present(withAppearance: appearance, viewController: viewController)
        }
        self.viewController = viewController
        if (appearance.hideTitle) {
            let c = NSLayoutConstraint(item: self.titleLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
            c.identifier = "titleLabelHeightConstraint"
            self.titleLabel.addConstraint(c)
        } else {
            self.titleLabel.removeConstraints(self.titleLabel.constraints.filter({ constraint in
                return (constraint.identifier ?? "") == "titleLabelHeightConstraint"
            }))
            self.titleLabel.text = appearance.title
        }
        self.loadReference(Storage.storage().reference().child(appearance.header))
    }
    
    func initialize(withTab: AuthenticTab, viewController: UIViewController) {
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didRecognizeTap(_:))))
        self.tab = withTab
        self.viewController = viewController
        if (self.tab!.hideTitle) {
            let c = NSLayoutConstraint(item: self.titleLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
            c.identifier = "titleLabelHeightConstraint"
            self.titleLabel.addConstraint(c)
        } else {
                self.titleLabel.removeConstraints(self.titleLabel.constraints.filter({ constraint in
                    return (constraint.identifier ?? "") == "titleLabelHeightConstraint"
                }))
            self.titleLabel.text = self.tab!.title
        }
        self.loadReference(Storage.storage().reference().child(self.tab!.header))
    }
    
    func initialize(withEvent: AuthenticEvent, viewController: UIViewController) {
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didRecognizeTap(_:))))
        self.event = withEvent
        self.viewController = viewController
        if (self.event!.hideTitle) {
            let c = NSLayoutConstraint(item: self.titleLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
            c.identifier = "titleLabelHeightConstraint"
            self.titleLabel.addConstraint(c)
        } else {
            self.titleLabel.removeConstraints(self.titleLabel.constraints.filter({ constraint in
                return (constraint.identifier ?? "") == "titleLabelHeightConstraint"
            }))
            self.titleLabel.text = self.event!.title
        }
        self.loadReference(Storage.storage().reference().child(self.event!.header))
    }
    
    func updateSize(_ image: UIImage?) {
        let i = image ?? self.headerImage.image
        let newHeight = (i!.size.height / i!.size.width) * (UIScreen.main.bounds.width - 20)
        heightConstraint.constant = newHeight
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    func loadReference(_ ref: StorageReference) {
        headerImage.sd_setImage(with: ref, placeholderImage: nil, completion: {(i, e, t, r) in
            self.updateSize(i!)
        })
    }
}
