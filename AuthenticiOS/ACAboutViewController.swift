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
        addView(AuthenticElement.createButton(info: AuthenticButtonInfo(label: "authenticcity.church", action: AuthenticButtonAction.empty), viewController: self, target: self, selector: #selector(self.home)))
        addView(AuthenticElement.createButton(info: AuthenticButtonInfo(label: "Impact the Kingdom", action: AuthenticButtonAction.empty), viewController: self, target: self, selector: #selector(self.getInvolved)))
        addView(AuthenticElement.createButton(info: AuthenticButtonInfo(label: "Merchandise", action: AuthenticButtonAction.empty), viewController: self, target: self, selector: #selector(self.merch)))
        addView(AuthenticElement.createButton(info: AuthenticButtonInfo(label: "Give", action: AuthenticButtonAction.empty), viewController: self, target: self, selector: #selector(self.give)))
    }
}
