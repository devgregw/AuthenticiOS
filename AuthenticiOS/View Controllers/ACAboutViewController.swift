//
//  ACAboutViewController.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 5/4/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import UIKit
import Firebase

class ACAboutViewController: UIViewController {
    @IBOutlet weak var stackView: UIStackView!
    
    private func addView(_ v: UIView) {
        stackView.addArrangedSubview(v)
    }
    
    @objc public func launchAMS() {
        ACButtonAction(type: "OpenURLAction", paramGroup: 0, params: ["url": "https://accams.devgregw.com"]).invoke(viewController: self)
    }
    
    @objc public func home() {
        ACButtonAction(type: "OpenURLAction", paramGroup: 0, params: ["url": "https://www.authenticcity.church"]).invoke(viewController: self)
    }
    
    @objc public func getInvolved() {
        ACButtonAction(type: "OpenURLAction", paramGroup: 0, params: ["url": "https://www.authenticcity.church/next/"]).invoke(viewController: self)
    }
    
    @objc public func merch() {
        ACButtonAction(type: "OpenURLAction", paramGroup: 0, params: ["url": "https://www.authenticcity.church/new-products/"]).invoke(viewController: self)
    }
    
    @objc public func give() {
        ACButtonAction(type: "OpenURLAction", paramGroup: 0, params: ["url": "https://www.authenticcity.church/give/"]).invoke(viewController: self)
    }
    
    @objc public func fb() {
        ACButtonAction(type: "OpenURLAction", paramGroup: 0, params: ["url": "https://www.facebook.com/AuthenticCityChurch/"]).invoke(viewController: self)
    }
    
    @objc public func ig() {
        ACButtonAction(type: "OpenURLAction", paramGroup: 0, params: ["url": "https://instagram.com/authentic_city_church"]).invoke(viewController: self)
    }
    
    @objc public func tw() {
        ACButtonAction(type: "OpenURLAction", paramGroup: 0, params: ["url": "https://twitter.com/AuthenticCity_"]).invoke(viewController: self)
    }
    
    @objc public func yt() {
        ACButtonAction(type: "OpenURLAction", paramGroup: 0, params: ["url": "https://www.youtube.com/channel/UCxrYck_z50n5It7ifj1LCjA"]).invoke(viewController: self)
    }
    
    @objc public func dev() {
        ACButtonAction(type: "OpenURLAction", paramGroup: 0, params: ["url": "https://devgregw.com"]).invoke(viewController: self)
    }
    
    @objc public func gh() {
        ACButtonAction(type: "OpenURLAction", paramGroup: 0, params: ["url": "https://github.com/devgregw/AuthenticiOS"]).invoke(viewController: self)
    }
    
    @objc public func tr() {
        ACButtonAction(type: "OpenURLAction", paramGroup: 0, params: ["url": "https://trello.com/b/QUgekVh6"]).invoke(viewController: self)
    }
    
    @objc public func docs() {
        ACButtonAction(type: "OpenURLAction", paramGroup: 0, params: ["url": "https://docs.accams.devgregw.com"]).invoke(viewController: self)
    }
    
    @objc public func pp() {
        ACButtonAction(type: "OpenURLAction", paramGroup: 0, params: ["url": "https://docs.accams.devgregw.com/privacy-policy"]).invoke(viewController: self)
    }
    
    @objc public func settings() {
        ACButtonAction(type: "OpenURLAction", paramGroup: 0, params: ["url": UIApplicationOpenSettingsURLString]).invoke(viewController: self)
    }
    
    @objc public func devNotifications() {
        let settingsAlert = UIAlertController(title: "Development Notifications", message: "Development notifications are for internal testing use only.  Interacting with them may cause instability.\n\n/topics/dev", preferredStyle: .actionSheet)
        settingsAlert.addAction(UIAlertAction(title: "Subscribe", style: .destructive, handler: { _ in
            Messaging.messaging().subscribe(toTopic: "dev")
            let message = UIAlertController(title: "Subscribed to /topics/dev", message: nil, preferredStyle: .alert)
            message.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            message.preferredAction = message.actions.first
            self.present(message, animated: true, completion: nil)
        }))
        settingsAlert.addAction(UIAlertAction(title: "Unsubscribe", style: .default, handler: { _ in
            Messaging.messaging().unsubscribe(fromTopic: "dev")
            let message = UIAlertController(title: "Unsubscribed from /topics/dev", message: nil, preferredStyle: .alert)
            message.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            message.preferredAction = message.actions.first
            self.present(message, animated: true, completion: nil)
        }))
        settingsAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(settingsAlert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "ABOUT"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Launch AMS", style: .plain, target: self, action: #selector(self.launchAMS))
        self.navigationItem.rightBarButtonItem!.tintColor = UIColor.white
        applyDefaultSettings()
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        let banner = #imageLiteral(resourceName: "full.png")
        imageView.image = banner
        let newHeight = (banner.size.height / banner.size.width) * (UIScreen.main.bounds.width)
        imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: newHeight))
        imageView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(self.devNotifications)))
        addView(imageView)
        addView(ACElement.createTitle(text: "AUTHENTIC CITY CHURCH", alignment: "center", border: true))
        addView(ACElement.createText(text: "Version \(VersionInfo.FullVersion) for iOS devices", alignment: "center"))
        addView(ACElement.createButton(info: ACButtonInfo(label: "Settings", action: ACButtonAction.empty), viewController: self, target: self, selector: #selector(self.settings)))
        addView(ACElement.createSeparator(visible: true))
        addView(ACElement.createText(text: "FOR ALL TO LOVE GOD, LOVE PEOPLE, AND IMPACT THE KINGDOM.", alignment: "center", size: 33, color: UIColor.black))
        addView(ACElement.createSeparator(visible: true))
        addView(ACElement.createTitle(text: "CONNECT WITH US", alignment: "center", border: true))
        addView(ACElement.createButton(info: ACButtonInfo(label: "Visit Our Website", action: ACButtonAction.empty), viewController: self, target: self, selector: #selector(self.home)))
        addView(ACElement.createSeparator(visible: false))
        addView(ACElement.createButton(info: ACButtonInfo(label: "Take the Next Step", action: ACButtonAction.empty), viewController: self, target: self, selector: #selector(self.getInvolved)))
        addView(ACElement.createButton(info: ACButtonInfo(label: "Merchandise", action: ACButtonAction.empty), viewController: self, target: self, selector: #selector(self.merch)))
        addView(ACElement.createButton(info: ACButtonInfo(label: "Give", action: ACButtonAction.empty), viewController: self, target: self, selector: #selector(self.give)))
        addView(ACElement.createSeparator(visible: false))
        addView(ACElement.createButton(info: ACButtonInfo(label: "Instagram", action: ACButtonAction.empty), viewController: self, target: self, selector: #selector(self.ig)))
        addView(ACElement.createButton(info: ACButtonInfo(label: "Facebook", action: ACButtonAction.empty), viewController: self, target: self, selector: #selector(self.fb)))
        addView(ACElement.createButton(info: ACButtonInfo(label: "Twitter", action: ACButtonAction.empty), viewController: self, target: self, selector: #selector(self.tw)))
        addView(ACElement.createButton(info: ACButtonInfo(label: "YouTube", action: ACButtonAction.empty), viewController: self, target: self, selector: #selector(self.yt)))
        addView(ACElement.createSeparator(visible: true))
        addView(ACElement.createText(text: "Designed and developed by Greg Whatley for Authentic City Church", alignment: "center"))
        addView(ACElement.createButton(info: ACButtonInfo(label: "Visit My Website", action: ACButtonAction.empty), viewController: self, target: self, selector: #selector(self.dev)))
        addView(ACElement.createButton(info: ACButtonInfo(label: "GitHub Repository", action: ACButtonAction.empty), viewController: self, target: self, selector: #selector(self.gh)))
        addView(ACElement.createButton(info: ACButtonInfo(label: "Trello Roadmap", action: ACButtonAction.empty), viewController: self, target: self, selector: #selector(self.tr)))
        addView(ACElement.createSeparator(visible: true))
        addView(ACElement.createButton(info: ACButtonInfo(label: "Legal Documentation", action: ACButtonAction.empty), viewController: self, target: self, selector: #selector(self.docs)))
        addView(ACElement.createButton(info: ACButtonInfo(label: "Privacy Policy", action: ACButtonAction.empty), viewController: self, target: self, selector: #selector(self.pp)))
        addView(ACElement.createSeparator(visible: false))
        addView(ACElement.createText(text: Messaging.messaging().fcmToken ?? "Unavailable", alignment: "left", size: 14, color: UIColor.gray, selectable: true))
        addView(ACElement.createSeparator(visible: false))
    }
}
