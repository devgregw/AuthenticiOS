//
//  AuthenticBundle.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 1/6/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorageUI

class AuthenticBundle {
    public let id: String
    
    public let parentId: String
    
    public let index: Int
    
    public let image: String?
    
    public let title: String?
    
    public let text: String?
    
    public let button: AuthenticButtonInfo?
    
    private var viewController: UIViewController?
    
    @objc private func actionButtonClick() {
        if (self.button != nil && self.viewController != nil) {
            button!.action.invoke(viewController: self.viewController!)
        }
    }
    
    public func createViews(viewController vc: UIViewController) -> [UIView] {
        var views: [UIView] = []
        self.viewController = vc
        let spacer = UIView()
        spacer.addConstraint(NSLayoutConstraint(item: spacer, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 10))
        views.append(spacer)
        if (self.image != nil) {
            let i = UIImageView()
            i.contentMode = .scaleAspectFit
            i.sd_setImage(with: Storage.storage().reference().child(self.image!), placeholderImage: nil, completion: { (image, e, c, r) in
                if (image == nil) {
                    return
                }
                let newHeight = (image!.size.height / image!.size.width) * (UIScreen.main.bounds.width)
                i.addConstraint(NSLayoutConstraint(item: i, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: newHeight))
            })
            views.append(i)
        }
        if (self.title != nil) {
            let label = UILabel()
            label.font = UIFont.preferredFont(forTextStyle: .title1)
            label.textColor = UIColor.white
            label.textAlignment = .center
            label.text = self.title!
            views.append(label)
        }
        if (self.text != nil) {
            let label = UILabel()
            label.textColor = UIColor.white
            label.text = self.text!
            label.textAlignment = .center
            views.append(label)
        }
        if (self.button != nil) {
            let button = UIButton(type: .system)
            button.setTitle(self.button!.label, for: .normal)
            button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.actionButtonClick)))
            views.append(button)
        }
        return views
    }
 
    init(dict: NSDictionary) {
        self.id = dict.value(forKey: "id") as! String
        self.parentId = dict.value(forKey: "parent") as! String
        self.index = dict.value(forKey: "index") as! Int
        self.image = dict.value(forKey: "image") as? String
        self.title = dict.value(forKey: "title") as? String
        self.text = dict.value(forKey: "text") as? String
        let buttonDict = dict.value(forKey: "_buttonInfo") as? NSDictionary
        if (buttonDict != nil) {
            self.button = AuthenticButtonInfo(dict: buttonDict!)
        } else {
            self.button = nil
        }
    }
}

