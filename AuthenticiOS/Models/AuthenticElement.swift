//
//  AuthenticElement.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 2/7/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import Foundation
import UIKit

class AuthenticElement {
    let id: String
    let parent: String
    let type: String
    let properties: NSDictionary
    private var buttonAction: AuthenticButtonAction? = nil
    private var buttonViewController: UIViewController? = nil
    
    init(dict: NSDictionary) {
        self.id = dict["id"] as! String
        self.parent = dict["parent"] as! String
        self.type = dict["type"] as! String
        self.properties = Utilities.literalToNSDictionary(dict.filter({ item -> Bool in
            return item.key as! String != "id" && item.key as! String != "parent" && item.key as! String != "type"
        }))
    }
    
    private func getProperty<T>(_ name: String) -> T {
        return self.properties[name] as! T
    }
    
    @objc private func actionButtonClick() {
        if (self.buttonAction != nil && self.buttonViewController != nil) {
            self.buttonAction!.invoke(viewController: self.buttonViewController!)
        }
    }
    
    func getView(viewController vc: UIViewController) -> UIView {
        switch (type) {
        case "image":
            let image = UIImageView()
            image.contentMode = .scaleAspectFit
            Utilities.loadFirebase(image: getProperty("image"), into: image)
            return image
        //case "video":
        case "title":
            let label = GWLabel()
            label.setInsets(top: 5, left: 10, bottom: 0, right: 10)
            label.text = getProperty("title")
            label.font = UIFont(name: "Futura PT Web Heavy", size: 26)
            let alignment : String = getProperty("alignment")
            switch (alignment) {
            case "center":
                label.textAlignment = .center
                break
            case "right":
                label.textAlignment = .right
                break
            default:
                label.textAlignment = .left
                break;
            }
            return label
        case "text":
            let label = GWLabel()
            label.setInsets(top: 5, left: 10, bottom: 0, right: 10)
            label.text = getProperty("text")
            label.font = UIFont(name: "Proxima Nova", size: 16)
            let alignment : String = getProperty("alignment")
            switch (alignment) {
            case "center":
                label.textAlignment = .center
                break
            case "right":
                label.textAlignment = .right
                break
            default:
                label.textAlignment = .left
                break;
            }
            return label
        case "button":
            let button = UIButton(type: .system)
            button.backgroundColor = UIColor.init(red: 0.15, green: 0.15, blue: 0.15, alpha: 1)
            button.setTitleColor(UIColor.white, for: .normal)
            button.layer.cornerRadius = 8
            button.contentEdgeInsets = UIEdgeInsetsMake(15, 5, 15, 5)
            let info = AuthenticButtonInfo(dict: getProperty("_buttonInfo"))
            button.setTitle(info.label, for: .normal)
            self.buttonAction = info.action
            self.buttonViewController = vc
            button.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.actionButtonClick)))
            let stackView = UIStackView(arrangedSubviews: [button])
            stackView.layoutMargins = UIEdgeInsetsMake(5, 10, 5, 10)
            stackView.isLayoutMarginsRelativeArrangement = true
            stackView.axis = .vertical
            return stackView
        case "separator":
            let view = UIView()
            view.backgroundColor = getProperty("visible") ? UIColor.init(red: 0.15, green: 0.15, blue: 0.15, alpha: 1) : UIColor.white
            view.addConstraint(NSLayoutConstraint.init(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 2))
            let stackView = UIStackView(arrangedSubviews: [view])
            stackView.layoutMargins = UIEdgeInsetsMake(10, 10, 10, 10)
            stackView.isLayoutMarginsRelativeArrangement = true
            stackView.axis = .vertical
            return stackView
        default:
            let label = GWLabel()
            label.setInsets(top: 5, left: 10, bottom: 0, right: 10)
            label.text = "Unknown element: \(type)"
            label.textColor = UIColor.red
            label.font = UIFont(name: "Proxima Nova", size: 16)
            return label
        }
    }
}
