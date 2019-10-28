//
//  ACTabViewController.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 1/2/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class ACTabViewController: UIViewController {
    
    @IBOutlet weak var stackView: UIStackView!
    
    public var tab: ACTab!
    
    private var alreadyInitialized = false
    
    private func clearViews() {
        guard self.stackView != nil else {
            return
        }
        while (self.stackView.arrangedSubviews.count > 1) {
            self.stackView.removeArrangedSubview(self.stackView.arrangedSubviews[1])
        }
    }
    
    public static func instantiateViewController(for tab: ACTab) -> UIViewController {
        if let specialType = tab.specialType {
            switch specialType {
            case "wallpapers":
                let vc = StoryboardHelper.instantiateWallpaperCollectionViewController(with: tab)
                vc.initialize(withTab: tab)
                return vc
            default: return StoryboardHelper.instantiateTabViewController(with: tab)
            }
        } else {
            return StoryboardHelper.instantiateTabViewController(with: tab)
        }
    }
    
    public static func present(tab: ACTab, origin: String, medium: String) {
        AnalyticsHelper.activatePage(tab: tab, origin: origin, medium: medium)
        if tab.action != nil {
            tab.action!.invoke(viewController: AppDelegate.topViewController, origin: origin, medium: medium)
            return
        }
        if let type = tab.specialType {
            if type == "wallpapers" {
                let vc = StoryboardHelper.instantiateWallpaperCollectionViewController(with: tab)
                vc.initialize(withTab: tab)
                vc.presentSelf(sender: nil)
                return
            }
        }
        StoryboardHelper.instantiateTabViewController(with: tab).presentSelf(sender: nil)
    }
    
    private var fullExpAction: NSDictionary!
    
    @objc public func runFullExpAction() {
        ACButtonAction(dict: self.fullExpAction).invoke(viewController: self, origin: "fullexp", medium: "controller")
    }
    
    private func initLayout(forSpecialType specialType: String) {
        switch (specialType) {
        case "fullexp":
            view.backgroundColor = UIColor.black
            let controllerElement = self.tab!.elements[0]
            self.fullExpAction = (controllerElement.getProperty("action") as! NSDictionary)
            let controllerView = controllerElement.getView(viewController: self, origin: "/tabs/\(self.tab!.id)")
            controllerView.isUserInteractionEnabled = true
            controllerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.runFullExpAction)))
            controllerView.clipsToBounds = true
            
            var indicator: UIActivityIndicatorView
            if #available(iOS 13.0, *) {
                indicator = UIActivityIndicatorView(style: .large)
            } else {
                indicator = UIActivityIndicatorView(style: .whiteLarge)
            }
            indicator.startAnimating()
            indicator.frame.size = CGSize(width: 50, height: 50)
            indicator.center = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
            view.addSubview(indicator)
            view.sendSubviewToBack(indicator)
            
            self.stackView.addArrangedSubview(controllerView)
            if let scroll = self.stackView.superview as? UIScrollView {
                scroll.isScrollEnabled = false
            }
            self.view.addConstraints([
                NSLayoutConstraint(item: controllerView, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: controllerView, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1, constant: 0)
            ])
            break
        case "watchPlaylist":
            guard self.tab!.elements.count > 0 else {return}
            if #available(iOS 13, *) {
                self.view.backgroundColor = UIColor.systemBackground
            }
            var elements = self.tab!.elements
            let first = elements.first!
            let videoInfo = first.getProperty("videoInfo") as! NSDictionary
            (self.stackView.superview as! UIScrollView).indicatorStyle = .default
            self.stackView.addArrangedSubview(ACElement.createVideo(provider: videoInfo.object(forKey: "provider") as! String, videoId: videoInfo.object(forKey: "id") as! String, thumbnail: videoInfo.object(forKey: "thumbnail") as! String, title: videoInfo.object(forKey: "title") as! String, large: true, hideTitle: true, origin: "/tabs/\(self.tab!.id)"))
            elements.removeFirst()
            guard elements.count > 0 else {return}
            var skip = false
            for i in 0...(elements.count - 1) {
                if skip {
                    skip = false
                    continue
                }
                skip = true
                let horizontal = UIStackView(arrangedSubviews: [])
                horizontal.distribution = .fillEqually
                horizontal.translatesAutoresizingMaskIntoConstraints = false
                horizontal.axis = .horizontal
                horizontal.spacing = 0
                let fVideoInfo = elements[i].getProperty("videoInfo") as! NSDictionary
                horizontal.addArrangedSubview(ACHalfThumbnailButtonView(vendor: fVideoInfo.object(forKey: "provider") as! String, id: fVideoInfo.object(forKey: "id") as! String, thumb: fVideoInfo.object(forKey: "thumbnail") as! String, title: fVideoInfo.object(forKey: "title") as! String, hideTitle: true, origin: "/tabs/\(self.tab!.id)"))
                //horizontal.addConstraint(NSLayoutConstraint(item: horizontal.arrangedSubviews[0], attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: UIScreen.main.bounds.width / 2))
                if i + 1 != elements.count {
                    let sVideoInfo = elements[i + 1].getProperty("videoInfo") as! NSDictionary
                    let nView = ACHalfThumbnailButtonView(vendor: sVideoInfo.object(forKey: "provider") as! String, id: sVideoInfo.object(forKey: "id") as! String, thumb: sVideoInfo.object(forKey: "thumbnail") as! String, title: sVideoInfo.object(forKey: "title") as! String, hideTitle: true, origin: "/tabs/\(self.tab!.id)")
                    horizontal.addArrangedSubview(nView)
                    //horizontal.addConstraint(NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: UIScreen.main.bounds.width / 2))
                    horizontal.addConstraint(NSLayoutConstraint(item: nView, attribute: .leading, relatedBy: .equal, toItem: horizontal.arrangedSubviews[0], attribute: .trailing, multiplier: 1, constant: 0))
                } else {
                    horizontal.addConstraint(NSLayoutConstraint(item: horizontal.arrangedSubviews[0], attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: UIScreen.main.bounds.width / 2))
                    horizontal.addConstraint(NSLayoutConstraint(item: horizontal.arrangedSubviews[0], attribute: .leading, relatedBy: .equal, toItem: horizontal, attribute: .leading, multiplier: 1, constant: 0))
                }
                self.stackView.addArrangedSubview(horizontal)
            }
            break
        default:
            let alert = UIAlertController(title: "Content Unavailable", message: "Sorry, this content requires an updated version of the Authentic app.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Back", style: .cancel, handler: {_ in
                self.navigationController?.popViewController(animated: true)
            }))
            alert.addAction(UIAlertAction(title: "Open App Store", style: .default, handler: {_ in
                ACButtonAction(type: "OpenURLAction", paramGroup: 0, params: ["url": "itms-apps://itunes.apple.com/app/id1402645724"]).invoke(viewController: self, origin: "/tabs/\(self.tab!.id)", medium: "contentUnavailable")
                self.navigationController?.popViewController(animated: false)
            }))
            present(alert, animated: true, completion: nil)
            return
        }
    }
    
    private func initLayout() {
        guard !self.alreadyInitialized else {return}
        self.alreadyInitialized = true
        self.clearViews()
        if let specialType = self.tab!.specialType {
            initLayout(forSpecialType: specialType)
        } else if self.tab!.elements.count == 0 {
            let label = UILabel()
            label.textColor = UIColor.black
            label.text = "No content"
            label.textAlignment = .center
            self.stackView.addArrangedSubview(label)
        } else {
            self.tab!.elements.forEach({ element in
                self.stackView.addArrangedSubview(element.getView(viewController: self, origin: "/tabs/\(self.tab!.id)"))
            })
        }
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.tab!.title
        self.tabBarItem.title = self.tab!.title.capitalized
        if let action = self.tab!.action {
            action.invoke(viewController: navigationController!, origin: "/tabs/\(self.tab!.id)", medium: "action")
            navigationController!.popViewController(animated: false)
        } else {
            applyDefaultAppearance()
        }
    }
}
