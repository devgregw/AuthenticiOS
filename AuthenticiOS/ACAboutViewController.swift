//
//  ACAboutViewController.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 5/4/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import UIKit

class ACAboutViewController: UIViewController {
    @IBOutlet weak var stackView: UIStackView!
    
    private func addView(_ v: UIView) {
        stackView.addArrangedSubview(v)
    }
    
    @objc public func launchAMS() {
        AuthenticButtonAction(type: "OpenURLAction", paramGroup: 0, params: ["url": "https://accams.devgregw.com"]).invoke(viewController: self)
    }
    
    @objc public func home() {
        AuthenticButtonAction(type: "OpenURLAction", paramGroup: 0, params: ["url": "https://www.authenticcity.church"]).invoke(viewController: self)
    }
    
    @objc public func getInvolved() {
        AuthenticButtonAction(type: "OpenURLAction", paramGroup: 0, params: ["url": "https://www.authenticcity.church/next/"]).invoke(viewController: self)
    }
    
    @objc public func merch() {
        AuthenticButtonAction(type: "OpenURLAction", paramGroup: 0, params: ["url": "https://www.authenticcity.church/new-products/"]).invoke(viewController: self)
    }
    
    @objc public func give() {
        AuthenticButtonAction(type: "OpenURLAction", paramGroup: 0, params: ["url": "https://www.authenticcity.church/give/"]).invoke(viewController: self)
    }
    
    @objc public func fb() {
        AuthenticButtonAction(type: "OpenURLAction", paramGroup: 0, params: ["url": "https://www.facebook.com/AuthenticCityChurch/"]).invoke(viewController: self)
    }
    
    @objc public func ig() {
        AuthenticButtonAction(type: "OpenURLAction", paramGroup: 0, params: ["url": "https://instagram.com/authentic_city_church"]).invoke(viewController: self)
    }
    
    @objc public func tw() {
        AuthenticButtonAction(type: "OpenURLAction", paramGroup: 0, params: ["url": "https://twitter.com/AuthenticCity_"]).invoke(viewController: self)
    }
    
    @objc public func yt() {
        AuthenticButtonAction(type: "OpenURLAction", paramGroup: 0, params: ["url": "https://www.youtube.com/channel/UCxrYck_z50n5It7ifj1LCjA"]).invoke(viewController: self)
    }
    
    @objc public func dev() {
        AuthenticButtonAction(type: "OpenURLAction", paramGroup: 0, params: ["url": "https://devgregw.com"]).invoke(viewController: self)
    }
    
    @objc public func gh() {
        AuthenticButtonAction(type: "OpenURLAction", paramGroup: 0, params: ["url": "https://github.com/devgregw/AuthenticiOS"]).invoke(viewController: self)
    }
    
    @objc public func tr() {
        AuthenticButtonAction(type: "OpenURLAction", paramGroup: 0, params: ["url": "https://trello.com/b/QUgekVh6"]).invoke(viewController: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "ABOUT"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Launch AMS", style: .plain, target: self, action: #selector(self.launchAMS))
        Utilities.applyTintColor(to: self)
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        let banner = #imageLiteral(resourceName: "full.png")
        imageView.image = banner
        let newHeight = (banner.size.height / banner.size.width) * (UIScreen.main.bounds.width)
        imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: newHeight))
        addView(imageView)
        addView(AuthenticElement.createTitle(text: "AUTHENTIC CITY CHURCH", alignment: "center"))
        addView(AuthenticElement.createText(text: "Version \(VersionInfo.Version)-u\(VersionInfo.Update) for iOS devices", alignment: "center"))
        addView(AuthenticElement.createSeparator(visible: true))
        addView(AuthenticElement.createCustomText(text: "FOR ALL TO LOVE GOD, LOVE PEOPLE, AND IMPACT THE KINGDOM.", size: 33, futura: false, alignment: "center", color: UIColor.black))
        addView(AuthenticElement.createSeparator(visible: true))
        addView(AuthenticElement.createTitle(text: "CONNECT WITH US", alignment: "center"))
        addView(AuthenticElement.createButton(info: AuthenticButtonInfo(label: "Visit Our Website", action: AuthenticButtonAction.empty), viewController: self, target: self, selector: #selector(self.home)))
        addView(AuthenticElement.createSeparator(visible: false))
        addView(AuthenticElement.createButton(info: AuthenticButtonInfo(label: "Take the Next Step", action: AuthenticButtonAction.empty), viewController: self, target: self, selector: #selector(self.getInvolved)))
        addView(AuthenticElement.createButton(info: AuthenticButtonInfo(label: "Merchandise", action: AuthenticButtonAction.empty), viewController: self, target: self, selector: #selector(self.merch)))
        addView(AuthenticElement.createButton(info: AuthenticButtonInfo(label: "Give", action: AuthenticButtonAction.empty), viewController: self, target: self, selector: #selector(self.give)))
        addView(AuthenticElement.createSeparator(visible: false))
        addView(AuthenticElement.createButton(info: AuthenticButtonInfo(label: "Instagram", action: AuthenticButtonAction.empty), viewController: self, target: self, selector: #selector(self.ig)))
        addView(AuthenticElement.createButton(info: AuthenticButtonInfo(label: "Facebook", action: AuthenticButtonAction.empty), viewController: self, target: self, selector: #selector(self.fb)))
        addView(AuthenticElement.createButton(info: AuthenticButtonInfo(label: "Twitter", action: AuthenticButtonAction.empty), viewController: self, target: self, selector: #selector(self.tw)))
        addView(AuthenticElement.createButton(info: AuthenticButtonInfo(label: "YouTube", action: AuthenticButtonAction.empty), viewController: self, target: self, selector: #selector(self.yt)))
        addView(AuthenticElement.createSeparator(visible: true))
        addView(AuthenticElement.createText(text: "Designed and developed by Greg Whatley for Authentic City Church", alignment: "center"))
        addView(AuthenticElement.createButton(info: AuthenticButtonInfo(label: "Learn More", action: AuthenticButtonAction.empty), viewController: self, target: self, selector: #selector(self.dev)))
        addView(AuthenticElement.createButton(info: AuthenticButtonInfo(label: "GitHub Repository", action: AuthenticButtonAction.empty), viewController: self, target: self, selector: #selector(self.gh)))
        addView(AuthenticElement.createButton(info: AuthenticButtonInfo(label: "Trello Roadmap", action: AuthenticButtonAction.empty), viewController: self, target: self, selector: #selector(self.tr)))
        addView(AuthenticElement.createSeparator(visible: false))
    }
}
