//
//  ACEventViewController.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 4/22/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class ACEventViewController: UIViewController {
    
    @IBOutlet weak var stackView: UIStackView!
    
    private let event: AuthenticEvent?
    
    private func clearViews() {
        while (self.stackView.arrangedSubviews.count > 1) {
            self.stackView.removeArrangedSubview(self.stackView.arrangedSubviews[1])
        }
    }
    
    public static func present(event: AuthenticEvent) {
        AppDelegate.automaticPresent(viewController: ACEventViewController(event: event))
    }
    
    private func addView(_ view: UIView) {
        self.stackView.addArrangedSubview(view)
    }
    
    @objc public func addToCalendar() {
        AuthenticButtonAction(dict: NSDictionary(dictionary: [
            "group": 0,
            "type": "AddToCalendarAction",
            "eventId": self.event!.id
        ])).invoke(viewController: self)
    }
    
    @objc public func getDirections() {
        AuthenticButtonAction(type: "GetDirectionsAction", paramGroup: 0, params: ["address": self.event!.address]).invoke(viewController: self)
    }
    
    @objc public func showOnMap() {
        AuthenticButtonAction(type: "ShowMapAction", paramGroup: 0, params: ["address": self.event!.location]).invoke(viewController: self)
    }
    
    @objc public func register() {
        AuthenticButtonAction(type: "OpenURLAction", paramGroup: 0, params: ["url": self.event!.registrationUrl!]).invoke(viewController: self)
    }
    
    private func initLayout() {
        self.clearViews()
        let i = UIImageView()
        i.contentMode = .scaleAspectFit
        Utilities.loadFirebase(image: self.event!.header.imageName, into: i)
        addView(i)
        addView(AuthenticElement.createTitle(text: self.event!.title, alignment: "center", border: true))
        addView(AuthenticElement.createText(text: self.event!.description, alignment: "left"))
        addView(AuthenticElement.createSeparator(visible: true))
        addView(AuthenticElement.createTitle(text: "Date & Time", alignment: "center", border: true))
        addView(AuthenticElement.createText(text: self.event!.getNextOccurrence().format(hideEndDate: self.event!.hideEndDate), alignment: "left"))
        if let rule = self.event!.recurrence {
            addView(AuthenticElement.createText(text: rule.format(initialStart: self.event!.startDate, initialEnd: self.event!.endDate), alignment: "left"))
        }
        addView(AuthenticElement.createButton(info: AuthenticButtonInfo(label: "Add to Calendar", action: AuthenticButtonAction.empty), viewController: self, target: self, selector: #selector(self.addToCalendar)))
        addView(AuthenticElement.createSeparator(visible: true))
        addView(AuthenticElement.createTitle(text: "Location", alignment: "center", border: true))
        addView(AuthenticElement.createText(text: "\(self.event!.location)\(!String.isNilOrEmpty(self.event!.address) ? "\n\(self.event!.address)" : "")", alignment: "left", selectable: true))
        if (!String.isNilOrEmpty(self.event!.address)) {
            addView(AuthenticElement.createButton(info: AuthenticButtonInfo(label: "Get Directions", action: AuthenticButtonAction.empty), viewController: self, target: self, selector: #selector(self.getDirections)))
        } else {
            addView(AuthenticElement.createButton(info: AuthenticButtonInfo(label: "Show on Map", action: AuthenticButtonAction.empty), viewController: self, target: self, selector: #selector(self.showOnMap)))
        }
        addView(AuthenticElement.createSeparator(visible: true))
        addView(AuthenticElement.createTitle(text: "Price & Registration", alignment: "center", border: true))
        if !String.isNilOrEmpty(self.event!.registrationUrl) {
            addView(AuthenticElement.createText(text: self.event!.price! > Float(0) ? "$\(self.event!.price!)" : "Free", alignment: "left"))
            addView(AuthenticElement.createText(text: "Registration is required", alignment: "left"))
            addView(AuthenticElement.createButton(info: AuthenticButtonInfo(label: "Register Now", action: AuthenticButtonAction.empty), viewController: self, target: self, selector: #selector(self.register)))
        } else {
            addView(AuthenticElement.createText(text: "Free", alignment: "left"))
            addView(AuthenticElement.createText(text: "Registration is not required", alignment: "left"))
        }
        if !UIDevice.current.isiPhoneX {
            addView(AuthenticElement.createSeparator(visible: false))
        }
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initLayout()
    }
    
    init(event: AuthenticEvent) {
        self.event = event
        super.init(nibName: "ACEventViewController", bundle: Bundle.main)
        self.title = event.title
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.event = nil
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyDefaultSettings()
    }
}
