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
    
    private let event: ACEvent?
    
    private var alreadyInitialized = false
    
    private func clearViews() {
        while (self.stackView.arrangedSubviews.count > 1) {
            self.stackView.removeArrangedSubview(self.stackView.arrangedSubviews[1])
        }
    }
    
    public static func present(event: ACEvent, isPlaceholder: Bool, origin: String, medium: String) {
        if isPlaceholder {
            AnalyticsHelper.activatePage(event: event as! ACEventPlaceholder, origin: origin, medium: medium)
        } else {
            AnalyticsHelper.activatePage(event: event, origin: origin, medium: medium)
        }
        ACEventViewController(event: event).presentSelf(sender: nil)
    }
    
    private func addView(_ view: UIView) {
        self.stackView.addArrangedSubview(view)
    }
    
    @objc public func addToCalendar() {
        ACButtonAction(dict: NSDictionary(dictionary: [
            "group": 0,
            "type": "AddToCalendarAction",
            "eventId": self.event!.id
            ])).invoke(viewController: self, origin: "/events/\(self.event!.id)", medium: "addToCalendar")
    }
    
    @objc public func getDirections() {
        ACButtonAction(type: "GetDirectionsAction", paramGroup: 0, params: ["address": self.event!.address]).invoke(viewController: self, origin: "/events/\(self.event!.id)", medium: "getDirections")
    }
    
    @objc public func showOnMap() {
        ACButtonAction(type: "ShowMapAction", paramGroup: 0, params: ["address": self.event!.location]).invoke(viewController: self, origin: "/events/\(self.event!.id)", medium: "showOnMap")
    }
    
    @objc public func register() {
        ACButtonAction(type: "OpenURLAction", paramGroup: 0, params: ["url": self.event!.registrationUrl!]).invoke(viewController: self, origin: "/events/\(self.event!.id)", medium: "register")
    }
    
    private func initLayout() {
        guard !self.alreadyInitialized else {return}
        self.alreadyInitialized = true
        self.clearViews()
        if let placeholder = self.event! as? ACEventPlaceholder {
            placeholder.elements!.forEach { element in
                self.addView(element.getView(viewController: self, origin: "/events/\(self.event!.id)"))
            }
            return
        }
        let i = UIImageView()
        i.contentMode = .scaleAspectFit
        self.event!.header.load(intoImageView: i, fadeIn: true, setSize: true)
        addView(i)
        addView(ACElement.createTitle(text: self.event!.title, alignment: "center", border: true))
        addView(ACElement.createText(text: self.event!.description, alignment: "left"))
        addView(ACElement.createSeparator(visible: true))
        addView(ACElement.createTitle(text: "Date & Time", alignment: "center", border: true))
        addView(ACElement.createText(text: self.event!.getNextOccurrence().format(hideEndDate: self.event!.hideEndDate), alignment: "left"))
        if let rule = self.event!.recurrence {
            addView(ACElement.createText(text: rule.format(initialStart: self.event!.startDate, initialEnd: self.event!.endDate), alignment: "left"))
        }
        addView(ACElement.createButton(info: ACButtonInfo(label: "Add to Calendar", action: ACButtonAction.empty), viewController: self, target: self, selector: #selector(self.addToCalendar)))
        addView(ACElement.createSeparator(visible: true))
        addView(ACElement.createTitle(text: "Location", alignment: "center", border: true))
        addView(ACElement.createText(text: "\(self.event!.location)\(!String.isNilOrEmpty(self.event!.address) ? "\n\(self.event!.address)" : "")", alignment: "left", selectable: true))
        if (!String.isNilOrEmpty(self.event!.address)) {
            addView(ACElement.createButton(info: ACButtonInfo(label: "Get Directions", action: ACButtonAction.empty), viewController: self, target: self, selector: #selector(self.getDirections)))
        } else {
            addView(ACElement.createButton(info: ACButtonInfo(label: "Show on Map", action: ACButtonAction.empty), viewController: self, target: self, selector: #selector(self.showOnMap)))
        }
        addView(ACElement.createSeparator(visible: true))
        addView(ACElement.createTitle(text: "Price & Registration", alignment: "center", border: true))
        if !String.isNilOrEmpty(self.event!.registrationUrl) {
            addView(ACElement.createText(text: self.event!.price! > Float(0) ? "$\(self.event!.price!)" : "Free", alignment: "left"))
            addView(ACElement.createText(text: "Registration is required", alignment: "left"))
            addView(ACElement.createButton(info: ACButtonInfo(label: "Register Now", action: ACButtonAction.empty), viewController: self, target: self, selector: #selector(self.register)))
        } else {
            addView(ACElement.createText(text: "Free", alignment: "left"))
            addView(ACElement.createText(text: "Registration is not required", alignment: "left"))
        }
        if !UIDevice.current.isiPhoneX {
            addView(ACElement.createSeparator(visible: false))
        }
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initLayout()
    }
    
    init(event: ACEvent) {
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
        applyDefaultAppearance()
    }
}
