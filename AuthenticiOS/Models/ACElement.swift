//
//  ACElement.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 2/7/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import SafariServices

class ACElement {
    let id: String
    let parent: String
    let type: String
    let properties: NSDictionary
    private var buttonAction: ACButtonAction? = nil
    private var buttonViewController: UIViewController? = nil
    
    init(dict: NSDictionary) {
        self.id = dict["id"] as! String
        self.parent = dict["parent"] as! String
        self.type = dict["type"] as! String
        self.properties = NSDictionary(literal: dict.filter({ item -> Bool in
            return item.key as! String != "id" && item.key as! String != "parent" && item.key as! String != "type"
        }))
    }
    
    public func getProperty(_ name: String) -> Any? {
        return self.properties[name]
    }
    
    static public func createImage(imageResource: ACImageResource, enlargable: Bool, vc: UIViewController?) -> UIView {
        if enlargable {
            let view = ACSavableImageView(imageResource: imageResource, viewController: vc!)
            let stack = UIStackView(arrangedSubviews: [createText(text: "Tap to download.", alignment: "left", size: 12, color: UIColor.gray, selectable: false), view])
            stack.axis = .vertical
            return stack
        }
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        imageResource.load(intoImageView: image, fadeIn: true, setSize: true, scaleDownLargeImages: false)
        return image
    }
    
    static public func createVideo(provider: String, videoId: String, thumbnail: String, title: String, origin: String) -> ACThumbnailButtonView {
        return ACThumbnailButtonView(vendor: provider, id: videoId, thumb: thumbnail, title: title, origin: origin)
    }
    
    static public func createTitle(text: String, alignment: String, border: Bool, size: Int = 24, color: UIColor = UIColor.black, bold: Bool = false) -> UIView {
        let label = ACInsetLabel()
        label.attributedText = NSAttributedString(string: text, attributes: [
            .kern: 2.5,
            .foregroundColor: color,
            .font: UIFont(name: "Effra" + (bold ? "-Bold" : ""), size: CGFloat(size))!
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
    
    static public func createButton(info: ACButtonInfo, viewController: UIViewController, target: Any?, selector: Selector) -> UIStackView {
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
    
    static public func createThumbnailButton(info: ACButtonInfo, thumbnail: ACImageResource, origin: String) -> UIView {
        return ACThumbnailButtonView(label: info.label, thumb: thumbnail, action: info.action, origin: origin)
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
    
    public static func createTile(title: String, height: Int, header: ACImageResource, action: ACButtonAction, viewController vc: UIViewController, origin: String) -> UIView {
        let tile = UINib(nibName: "ACTileView", bundle: Bundle.main).instantiate(withOwner: nil, options: nil)[0] as! ACTileView
        tile.initialize(withTitle: title, height: height, header: header, action: action, viewController: vc, origin: origin)
        return tile
    }
    
    public static func createToolbar(image: ACImageResource, leftAction: ACButtonAction, rightAction: ACButtonAction, viewController vc: UIViewController, origin: String) -> UIView {
        let toolbar = UINib(nibName: "ACToolbarView", bundle: Bundle.main).instantiate(withOwner: nil, options: nil)[0] as! ACToolbarView
        toolbar.initialize(withImage: image, leftAction: leftAction, rightAction: rightAction, viewController: vc, origin: origin)
        return toolbar
    }
    
    class ACHTMLWebViewDelegate: NSObject, UIWebViewDelegate {
        func webViewDidFinishLoad(_ webView: UIWebView) {
            var js = webView.stringByEvaluatingJavaScript(from: "document.getElementById(\"root\").offsetHeight;")!
            if js == "" { js = "0" }
            let height = Double(js).map { CGFloat($0) }!
            webView.addConstraint(NSLayoutConstraint(item: webView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height))
        }
        
        func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
            if navigationType == .linkClicked {
                //UIApplication.shared.open(request.url!, options: [:], completionHandler: nil)
                ACButtonAction(type: "OpenURLAction", paramGroup: 1, params: [
                    "url": request.url!.absoluteString
                    ]).invoke(viewController: AppDelegate.topViewController, origin: "html", medium: "user")
                return false
            }
            return true
        }
    }
    
    class ACNoZoomScrollViewDelegate: NSObject, UIScrollViewDelegate {
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return nil
        }
    }
    
    static let htmlDelegate = ACHTMLWebViewDelegate()
    static let noZoomDelegate = ACNoZoomScrollViewDelegate()
    
    public static func createHTMLReader(code: String) -> UIView {
        let webView = UIWebView()
        webView.delegate = htmlDelegate
        webView.loadHTMLString("<!DOCTYPE html><html><head><style type=\"text/css\">* { font-family: \"Proxima Nova\"; } p {padding-left: 4px; padding-right: 4px; padding-bottom: 1rem;}</style></head><body><div id=\"root\">\(code)<br></div></body></html>", baseURL: URL(fileURLWithPath: Bundle.main.bundlePath))
        webView.scrollView.delegate = noZoomDelegate
        webView.scrollView.isScrollEnabled = false
        return webView
        /*let label = UILabel()
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        let html = "<div id=\"root\" style=\"padding: 8px;\">\(code)</div>"
        label.attributedText = try! NSAttributedString(data: html.data(using: String.Encoding.unicode, allowLossyConversion: true)!, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
        label.font = UIFont(name: "Proxima Nova", size: 18)!
        return label*/
    }
    
    private var action: ACButtonAction!
    private var vc: UIViewController!
    private var origin: String!
    
    private var imageIndex = 0
    private var images = [String]()
    
    @objc public func invoke(_ sender: UIButton) {
        action.invoke(viewController: vc, origin: "element:\(origin!)", medium: "button")
    }
    
    @objc public func enlargeImage(_ sender: UIImageView) {
        ACButtonAction(type: "OpenURLAction", paramGroup: 0, params: ["url": "https://authentic.gregwhatley.dev/meta/storage/\(images[sender.tag])"]).invoke(viewController: vc, origin: "element:\(origin!)", medium: "enlargableImage")
    }
    
    func getView(viewController vc: UIViewController, origin: String) -> UIView {
        self.vc = vc
        self.origin = origin
        switch (type) {
        case "image":
            return ACElement.createImage(imageResource: ACImageResource(dict: getProperty("image") as! NSDictionary), enlargable: getProperty("enlargeButton") as! Bool, vc: vc)
        case "video":
            let videoInfo = getProperty("videoInfo") as! NSDictionary
            return ACElement.createVideo(provider: videoInfo.object(forKey: "provider") as! String, videoId: videoInfo.object(forKey: "id") as! String, thumbnail: videoInfo.object(forKey: "thumbnail") as! String, title: videoInfo.object(forKey: "title") as! String, origin: origin)
        case "title":
            return ACElement.createTitle(text: (getProperty("title") as! String), alignment: getProperty("alignment") as! String, border: true)
        case "text":
            return ACElement.createText(text: (getProperty("text") as! String), alignment: getProperty("alignment") as! String)
        case "button":
            self.action = ACButtonInfo(dict: getProperty("_buttonInfo") as! NSDictionary).action
            return ACElement.createButton(info: ACButtonInfo(dict: getProperty("_buttonInfo") as! NSDictionary), viewController: vc, target: self, selector: #selector(self.invoke(_:)))
        case "thumbnailButton":
            return ACElement.createThumbnailButton(info: ACButtonInfo(dict: getProperty("_buttonInfo") as! NSDictionary), thumbnail: ACImageResource(dict: getProperty("thumbnail") as! NSDictionary), origin: origin)
        case "separator":
            return ACElement.createSeparator(visible: getProperty("visible") as! Bool)
        case "tile":
            return ACElement.createTile(title: getProperty("title") as! String, height: getProperty("height") as? Int ?? 200, header: ACImageResource(dict: getProperty("header") as! NSDictionary), action: ACButtonAction(dict: getProperty("action") as! NSDictionary), viewController: vc, origin: origin)
        case "toolbar":
            return ACElement.createToolbar(image: ACImageResource(dict: getProperty("image") as! NSDictionary), leftAction: ACButtonAction(dict: getProperty("leftAction") as! NSDictionary), rightAction: ACButtonAction(dict: getProperty("rightAction") as! NSDictionary), viewController: vc, origin: origin)
        case "fullExpController":
            let controller = UIImageView()
            controller.contentMode = .scaleAspectFill
            //controller.autoresizingMask = UIViewAutoresizing(rawValue: UInt(UInt8(UIViewAutoresizing.flexibleWidth.rawValue) | UInt8(UIViewAutoresizing.flexibleHeight.rawValue)))
            ACImageResource(dict: getProperty("image") as! NSDictionary).load(intoImageView: controller, fadeIn: true, setSize: false, scaleDownLargeImages: false)
            return controller
        case "html":
            return ACElement.createHTMLReader(code: getProperty("html") as! String)
        default:
            return ACElement.createText(text: "Unknown element: \(type)", alignment: "left", size: 16, color: UIColor.red)
        }
    }
}
