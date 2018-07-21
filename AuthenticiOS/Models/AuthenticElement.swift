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
    
    static public func createImage(name: String, enlargable: Bool, vc: UIViewController?) -> UIView {
        if enlargable {
            let view = ACEnlargableImageView(imageName: name, viewController: vc!)
            let stack = UIStackView(arrangedSubviews: [view, createText(text: "Tap to open.", alignment: "left", size: 12, color: UIColor.gray, selectable: false)])
            stack.axis = .vertical
            return stack
        }
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        Utilities.loadFirebase(image: name, into: image)
        return image
    }
    
    static public func createVideo(provider: String, videoId: String, thumbnail: String, title: String) -> UIView {
        return ACVideoLinkView(vendor: provider, id: videoId, thumb: thumbnail, title: title)
        /*let webView = UIWebView()
        webView.allowsInlineMediaPlayback = true
        webView.allowsLinkPreview = true
        webView.allowsPictureInPictureMediaPlayback = true
        webView.mediaPlaybackAllowsAirPlay = true
        webView.loadRequest(URLRequest(url: URL(string: provider == "YouTube" ? "https://www.youtube.com/embed/\(videoId)" : "https://player.vimeo.com/video/\(videoId)")!))
        webView.backgroundColor = UIColor.black
        webView.addConstraint(NSLayoutConstraint(item: webView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: (UIApplication.shared.keyWindow?.bounds.width ?? 500) / 3 * 2))
        return webView*/
    }
    
    static public func createTitle(text: String, alignment: String, border: Bool, size: Int = 24, color: UIColor = UIColor.black) -> UIView {
        let label = ACInsetLabel()
        label.attributedText = NSAttributedString(string: text, attributes: [
            .kern: 2.5,
            .foregroundColor: color,
            .font: UIFont(name: "Effra", size: CGFloat(size))!
        ])
        if border {
            label.layer.borderColor = color.cgColor
            label.layer.borderWidth = 2
        }
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        let sv = label.embedInStackViewWithInsets(top: 0, left: 0, bottom: 0, right: 0)
        sv.axis = .vertical
        switch (alignment) {
        case "center":
            label.textAlignment = .center
            sv.alignment = .center
            break
        case "right":
            label.textAlignment = .right
            sv.alignment = .trailing
            break
        default:
            label.textAlignment = .left
            sv.alignment = .leading
            break
        }
        return sv
    }
    
    static public func createText(text: String, alignment: String, size: Int = 16, color: UIColor = UIColor.black, selectable: Bool = false) -> UIStackView {
        let label = UITextView()
        label.isEditable = false
        label.isSelectable = selectable
        label.textContainer.lineBreakMode = .byWordWrapping
        label.text = text
        label.textColor = color
        label.font = UIFont(name: "Proxima Nova", size: CGFloat(size))
        switch (alignment) {
        case "center":
            label.textAlignment = .center
            break
        case "right":
            label.textAlignment = .right
            break
        default:
            label.textAlignment = .left
            break
        }
        label.isScrollEnabled = false
        label.sizeToFit()
        label.layoutIfNeeded()
        return label.embedInStackViewWithInsets(top: 5, left: 10, bottom: 0, right: 10)
    }
    
    static public func createButton(info: AuthenticButtonInfo, viewController: UIViewController, target: Any?, selector: Selector) -> UIStackView {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Proxima Nova", size: 18)!
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets.init(top: 15, left: 5, bottom: 15, right: 5)
        button.setTitle(info.label, for: .normal)
        button.addTarget(target, action: selector, for: .touchUpInside)
        let stackView = UIStackView(arrangedSubviews: [button])
        stackView.layoutMargins = UIEdgeInsets.init(top: 5, left: 10, bottom: 5, right: 10)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.axis = .vertical
        return stackView
    }
    
    public static func createSeparator(visible: Bool) -> UIStackView {
        let view = UIView()
        view.backgroundColor = visible ? UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1) : UIColor.white
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 2))
        let stackView = UIStackView(arrangedSubviews: [view])
        stackView.layoutMargins = UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.axis = .vertical
        return stackView
    }
    
    private var action: AuthenticButtonAction!
    private var vc: UIViewController!
    
    private var imageIndex = 0
    private var images = [String]()
    
    @objc public func invoke(_ sender: UIButton) {
        action.invoke(viewController: vc)
    }
    
    @objc public func enlargeImage(_ sender: UIImageView) {
        AuthenticButtonAction.init(type: "OpenURLAction", paramGroup: 0, params: ["url": "https://accams.devgregw.com/meta/storage/\(images[sender.tag])"]).invoke(viewController: vc)
    }
    
    func getView(viewController vc: UIViewController) -> UIView {
        self.vc = vc
        switch (type) {
        case "image":
            return AuthenticElement.createImage(name: ImageResource(dict: getProperty("image") as! NSDictionary).imageName, enlargable: getProperty("enlargeButton") as! Bool, vc: vc)
        case "video":
            return AuthenticElement.createVideo(provider: getProperty("provider") as! String, videoId: getProperty("videoId") as! String)
        case "title":
            return AuthenticElement.createTitle(text: (getProperty("title") as! String), alignment: getProperty("alignment") as! String, border: true)
        case "text":
            return AuthenticElement.createText(text: (getProperty("text") as! String), alignment: getProperty("alignment") as! String)
        case "button":
            self.action = AuthenticButtonInfo(dict: getProperty("_buttonInfo") as! NSDictionary).action
            return AuthenticElement.createButton(info: AuthenticButtonInfo(dict: getProperty("_buttonInfo") as! NSDictionary), viewController: vc, target: self, selector: #selector(self.invoke(_:)))
        case "separator":
            return AuthenticElement.createSeparator(visible: getProperty("visible") as! Bool)
        default:
            return AuthenticElement.createText(text: "Unknown element: \(type)", alignment: "left", size: 16, color: UIColor.red)
        }
    }
}
