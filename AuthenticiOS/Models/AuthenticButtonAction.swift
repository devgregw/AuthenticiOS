//
//  AuthenticButtonAction.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 1/6/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import MapKit
import EventKit

class AuthenticButtonAction {
    public let type: String
    
    public let paramGroup: Int
    
    private let properties: NSDictionary
    
    public func getProperty(withName name: String) -> Any? {
        return properties[name]
    }
    
    @objc public func invoke(viewController vc: UIViewController) {
        switch (self.type) {
        case "OpenTabAction":
            Database.database().reference().child("/tabs/\(self.getProperty(withName: "tabId") as! String)/").observeSingleEvent(of: .value, with: {snapshot in
                let val = snapshot.value as? NSDictionary
                if (val != nil) {
                    ACTabViewController.present(tab: AuthenticTab(dict: val!), withViewController: vc)
                }
            }) { error in vc.present(UIAlertController(title: "Error", message: error.localizedDescription as String, preferredStyle: .alert), animated: true) }
            break
        case "OpenEventAction":
            Database.database().reference().child("/events/\(self.getProperty(withName: "eventId") as! String)/").observeSingleEvent(of: .value, with: {snapshot in
                let val = snapshot.value as? NSDictionary
                if (val != nil) {
                    ACEventViewController.present(event: AuthenticEvent(dict: val!), withViewController: vc)
                }
            }) { error in vc.present(UIAlertController(title: "Error", message: error.localizedDescription as String, preferredStyle: .alert), animated: true) }
            break
        case "OpenURLAction":
            let url = getProperty(withName: "url")
            UIApplication.shared.openURL(URL(string: url as! String)!)
            break
        case "ShowMapAction":
            let location = getProperty(withName: "address") as! String
            Utilities.MapInterface.search(forPlace: location)
        case "GetDirectionsAction":
            let address = getProperty(withName: "address") as! String
            Utilities.MapInterface.getDirections(toAddress: address)
            break
        case "EmailAction":
            let address = getProperty(withName: "emailAddress")
            if let url = URL(string: "mailto:\(address!)") {
                UIApplication.shared.openURL(url)
            } else {
                let alert = UIAlertController(title: "Error", message: "This action could not be invoked: '\(address!)' is not an email address.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                vc.present(alert, animated: true)
            }
            break
        case "AddToCalendarAction":
            var start: Date? = nil
            var end: Date? = nil
            var loc: String? = nil
            var title: String? = nil
            var rrule: RecurrenceRule?
            if self.paramGroup == 0 {
                Database.database().reference().child("/events/\(self.getProperty(withName: "eventId") as! String)/").observeSingleEvent(of: .value, with: {snapshot in
                    let val = snapshot.value as? NSDictionary
                    if (val != nil) {
                        let event = AuthenticEvent(dict: val!)
                        start = event.startDate
                        end = event.endDate
                        loc = event.address == "" ? event.location : event.address
                        rrule = event.recurrence
                    }
                }) { error in vc.present(UIAlertController(title: "Error", message: error.localizedDescription as String, preferredStyle: .alert), animated: true) }
            } else if self.paramGroup == 1 {
                let dates = self.getProperty(withName: "dateTime") as! NSDictionary
                start = Date.parseISO8601(string: dates["start"] as! String)
                end = Date.parseISO8601(string: dates["end"] as! String)
                loc = (self.getProperty(withName: "location") as! String)
                title = (self.getProperty(withName: "title") as! String)
                rrule = nil
            } else {
                let alert = UIAlertController(title: "Error", message: "We were unable to run this action because an invalid parameter group was specified.\n\n\(self.type): \(self.paramGroup)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                vc.present(alert, animated: true)
            }
            let store = EKEventStore()
            store.requestAccess(to: .event) { (granted, error) in
                if granted {
                    let event = EKEvent(eventStore: store)
                    event.isAllDay = false
                    event.endDate = end
                    event.startDate = start
                    event.location = loc
                    event.title = title
                    if let rule = rrule {
                        event.addRecurrenceRule(rule.toEKRecurrenceRule())
                    }
                    event.calendar = store.defaultCalendarForNewEvents
                    do {
                        try store.save(event, span: .thisEvent, commit: true)
                    } catch let saveError {
                        let alert = UIAlertController(title: "Error", message: "We were unable to add \"\(title)\" to your calendar.\n\n\(saveError.localizedDescription)", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                        vc.present(alert, animated: true)
                    }
                } else {
                    if let e = error {
                        let alert = UIAlertController(title: "Error", message: "We were unable to access your calendar.\n\n\(e.localizedDescription)", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                        vc.present(alert, animated: true)
                    } else {
                        let alert = UIAlertController(title: "Error", message: "We were unable to access your calendar because you denied permission.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                        vc.present(alert, animated: true)
                    }
                }
            }
        default:
            let alert = UIAlertController(title: "Error", message: "We were unable to parse this action because the type '\(self.type)' is undefined.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            vc.present(alert, animated: true)
            break
        }
    }
    
    init(dict: NSDictionary) {
        self.type = dict.value(forKey: "type") as! String
        self.paramGroup = dict.value(forKey: "group") as! Int
        var k: [NSCopying] = []
        var v: [Any] = []
        dict.filter({(key, value) in return (key as! String) != "type" && (key as! String) != "group" }).forEach({ e in k.append(e.key as! NSCopying); v.append(e.value) })
        self.properties = NSDictionary(objects: v, forKeys: k)
    }
}

