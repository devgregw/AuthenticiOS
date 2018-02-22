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
    
    private func getProperty(_ name: String) -> Any {
        return self.properties[name]!
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
            Utilities.loadFirebase(image: getProperty("image") as! String, into: image)
            return image
        case "video":
            let webView = UIWebView()
            let provider = getProperty("provider") as! String
            let videoId = getProperty("videoId") as! String
            webView.allowsInlineMediaPlayback = true
            webView.allowsLinkPreview = true
            webView.allowsPictureInPictureMediaPlayback = true
            webView.mediaPlaybackAllowsAirPlay = true
            webView.loadRequest(URLRequest(url: URL(string: provider == "YouTube" ? "https://www.youtube.com/embed/\(videoId)" : "https://player.vimeo.com/video/\(videoId)")!))
            webView.backgroundColor = UIColor.black
            webView.addConstraint(NSLayoutConstraint(item: webView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: (UIApplication.shared.keyWindow?.bounds.width ?? 500) / 3 * 2))
            return webView
        case "title":
            let label = GWLabel()
            label.setInsets(top: 5, left: 10, bottom: 0, right: 10)
            label.text = (getProperty("title") as! String)
            label.font = UIFont(name: "Futura PT Web Heavy", size: 26)
            let alignment = getProperty("alignment") as! String
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
            label.text = (getProperty("text") as! String)
            label.font = UIFont(name: "Proxima Nova", size: 16)
            let alignment = getProperty("alignment") as! String
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
            button.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1)
            button.setTitleColor(UIColor.white, for: .normal)
            button.titleLabel?.font = UIFont(name: "Proxima Nova", size: 18) ?? UIFont.systemFont(ofSize: 18)
            button.layer.cornerRadius = 8
            button.contentEdgeInsets = UIEdgeInsetsMake(15, 5, 15, 5)
            let info = AuthenticButtonInfo(dict: getProperty("_buttonInfo") as! NSDictionary)
            button.setTitle(info.label, for: .normal)
            self.buttonAction = info.action
            self.buttonViewController = vc
            button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.actionButtonClick)))
            let stackView = UIStackView(arrangedSubviews: [button])
            stackView.layoutMargins = UIEdgeInsetsMake(5, 10, 5, 10)
            stackView.isLayoutMarginsRelativeArrangement = true
            stackView.axis = .vertical
            return stackView
        case "separator":
            let view = UIView()
            view.backgroundColor = getProperty("visible") as! Bool ? UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1) : UIColor.white
            view.addConstraint(NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 2))
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
