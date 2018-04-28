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
    
    static public func createImage(name: String) -> UIImageView {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        Utilities.loadFirebase(image: name, into: image)
        return image
    }
    
    static public func createVideo(provider: String, videoId: String) -> UIWebView {
        let webView = UIWebView()
        webView.allowsInlineMediaPlayback = true
        webView.allowsLinkPreview = true
        webView.allowsPictureInPictureMediaPlayback = true
        webView.mediaPlaybackAllowsAirPlay = true
        webView.loadRequest(URLRequest(url: URL(string: provider == "YouTube" ? "https://www.youtube.com/embed/\(videoId)" : "https://player.vimeo.com/video/\(videoId)")!))
        webView.backgroundColor = UIColor.black
        webView.addConstraint(NSLayoutConstraint(item: webView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: (UIApplication.shared.keyWindow?.bounds.width ?? 500) / 3 * 2))
        return webView
    }
    
    static public func createCustomText(text: String, size: Int, futura: Bool, alignment: String, color: UIColor) -> GWLabel {
        let label = GWLabel()
        label.setInsets(top: 5, left: 10, bottom: 0, right: 10)
        label.text = text
        label.textColor = color
        label.font = UIFont(name: futura ? "Futura PT Web Heavy" : "Proxima Nova", size: CGFloat(size))
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
    }
    
    static public func createTitle(text: String, alignment: String) -> GWLabel {
        return createCustomText(text: text, size: 26, futura: true, alignment: alignment, color: UIColor.black)
    }
    
    static public func createText(text: String, alignment: String) -> GWLabel {
        return createCustomText(text: text, size: 16, futura: false, alignment: alignment, color: UIColor.black)
    }
    
    class ButtonHandler {
        @objc public func invoke(_ sender: UIButton) {
            self.action.invoke(viewController: self.vc)
        }
        
        private let action: AuthenticButtonAction
        private let vc: UIViewController
        
        init(action: AuthenticButtonAction, viewController vc: UIViewController) {
            self.action = action
            self.vc = vc
        }
    }
    
    static public func createButton(dict: NSDictionary, viewController: UIViewController, target: Any?, selector: Selector) -> UIStackView {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Proxima Nova", size: 18) ?? UIFont.systemFont(ofSize: 18)
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsetsMake(15, 5, 15, 5)
        let info = AuthenticButtonInfo(dict: dict)
        button.setTitle(info.label, for: .normal)
        button.addTarget(target, action: selector, for: .touchUpInside)
        let stackView = UIStackView(arrangedSubviews: [button])
        stackView.layoutMargins = UIEdgeInsetsMake(5, 10, 5, 10)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.axis = .vertical
        return stackView
    }
    
    public static func createSeparator(visible: Bool) -> UIStackView {
        let view = UIView()
        view.backgroundColor = visible ? UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1) : UIColor.white
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 2))
        let stackView = UIStackView(arrangedSubviews: [view])
        stackView.layoutMargins = UIEdgeInsetsMake(10, 10, 10, 10)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.axis = .vertical
        return stackView
    }
    
    private var action: AuthenticButtonAction!
    private var vc: UIViewController!
    
    @objc public func invoke(_ sender: UIButton) {
        action.invoke(viewController: vc)
    }
    
    func getView(viewController vc: UIViewController) -> UIView {
        switch (type) {
        case "image":
            return AuthenticElement.createImage(name: getProperty("image") as! String)
        case "video":
            return AuthenticElement.createVideo(provider: getProperty("provider") as! String, videoId: getProperty("videoId") as! String)
        case "title":
            return AuthenticElement.createTitle(text: (getProperty("title") as! String), alignment: getProperty("alignment") as! String)
        case "text":
            return AuthenticElement.createText(text: (getProperty("text") as! String), alignment: getProperty("alignment") as! String)
        case "button":
            self.action = AuthenticButtonInfo(dict: getProperty("_buttonInfo") as! NSDictionary).action
            self.vc = vc
            return AuthenticElement.createButton(dict: getProperty("_buttonInfo") as! NSDictionary, viewController: vc, target: self, selector: #selector(self.invoke(_:)))
        case "separator":
            return AuthenticElement.createSeparator(visible: getProperty("visible") as! Bool)
        default:
            return AuthenticElement.createCustomText(text: "Unknown element: \(type)", size: 16, futura: false, alignment: "left", color: UIColor.red)
        }
    }
}
