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
import SafariServices

class AuthenticButtonAction {
    public let type: String
    
    public let paramGroup: Int
    
    private let properties: NSDictionary
    
    public let rootDictionary: NSDictionary
    
    public static let empty = AuthenticButtonAction(type: "__UNDEFINED__", paramGroup: -1, params: [:])
    
    public func getProperty(withName name: String) -> Any? {
        return properties[name]
    }
    
    private func presentAlert(title: String, message: String, vc: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        vc.present(alert, animated: true)
    }
    
    @objc public func invoke(viewController vc: UIViewController) {
        switch (self.type) {
        case "OpenTabAction":
            Database.database().reference().child("/tabs/\(self.getProperty(withName: "tabId") as! String)/").observeSingleEvent(of: .value, with: {snapshot in
                let val = snapshot.value as? NSDictionary
                if (val != nil) {
                    ACTabViewController.present(tab: AuthenticTab(dict: val!))
                } else {
                    self.presentAlert(title: "Error", message: "We were unable to open the page because it does not exist.", vc: vc)
                }
            }) { error in self.presentAlert(title: "Error", message: "We were unable to access the database.\n\n\(error.localizedDescription as String)", vc: vc) }
            break
        case "OpenEventAction":
            Database.database().reference().child("/events/\(self.getProperty(withName: "eventId") as! String)/").observeSingleEvent(of: .value, with: {snapshot in
                let val = snapshot.value as? NSDictionary
                if (val != nil) {
                    ACEventViewController.present(event: AuthenticEvent(dict: val!))
                } else {
                    self.presentAlert(title: "Error", message: "We were unable to open the event because it does not exist.", vc: vc)
                }
            }) { error in self.presentAlert(title: "Error", message: "We were unable to access the database.\n\n\(error.localizedDescription as String)", vc: vc) }
            break
        case "OpenURLAction":
            let url = getProperty(withName: "url") as! String
            if url.contains("spotify") {
                UIApplication.shared.open(URL(string: url)!, options: [:], completionHandler: nil)
            } else {
                AppDelegate.getTopmostViewController().present(SFSafariViewController(url: URL(string: url)!), animated: true, completion: nil)
            }
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
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                presentAlert(title: "Error", message: "This action could not be invoked: '\(address!)' is not a valid email address.", vc: vc)
            }
            break
        case "AddToCalendarAction":
            let atcaCompletion = { (start: Date, end: Date, loc: String, title: String, rrule: RecurrenceRule?) in
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
                            self.presentAlert(title: "Add to Calendar", message: "\"\(title)\" was added to your calendar successfully.", vc: vc)
                        } catch let saveError {
                            self.presentAlert(title: "Error", message: "We were unable to add \"\(title)\" to your calendar.\n\n\(saveError.localizedDescription)", vc: vc)
                        }
                    } else {
                        if let e = error {
                            self.presentAlert(title: "Error", message: "We were unable to access your calendar.\n\n\(e.localizedDescription)", vc: vc)
                        } else {
                            self.presentAlert(title: "Error", message: "We were unable to access your calendar because you denied permission.", vc: vc)
                        }
                    }
                }
            }
            if self.paramGroup == 0 {
                Database.database().reference().child("/events/\(self.getProperty(withName: "eventId") as! String)/").observeSingleEvent(of: .value, with: {snapshot in
                    let val = snapshot.value as? NSDictionary
                    if (val != nil) {
                        let event = AuthenticEvent(dict: val!)
                        atcaCompletion(event.startDate, event.endDate, event.address == "" ? event.location : event.address, event.title, event.recurrence)
                    } else {
                        self.presentAlert(title: "Error", message: "We were unable to add this event to your calendar because it does not exist.", vc: vc)
                    }
                }) { error in self.presentAlert(title: "Error", message: "We were unable to access the database.\n\n\(error.localizedDescription as String)", vc: vc) }
            } else if self.paramGroup == 1 {
                let dates = self.getProperty(withName: "dateTime") as! NSDictionary
                atcaCompletion(Date.parseISO8601(string: dates["start"] as! String), Date.parseISO8601(string: dates["end"] as! String), (self.getProperty(withName: "location") as! String), (self.getProperty(withName: "title") as! String), nil)
            } else {
                self.presentAlert(title: "Error", message: "We were unable to run this action because an invalid parameter group was specified.\n\n\(self.type): \(self.paramGroup)", vc: vc)
            }
        default:
            let alert = UIAlertController(title: "Error", message: "We were unable to parse this action because the type \"\(self.type)\" is not a recognized action.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            vc.present(alert, animated: true)
            break
        }
    }
    
    init(dict: NSDictionary) {
        self.rootDictionary = dict
        self.type = dict.value(forKey: "type") as! String
        self.paramGroup = Int(String(describing: dict.value(forKey: "group")!))!
        var k: [NSCopying] = []
        var v: [Any] = []
        dict.filter({(key, value) in return (key as! String) != "type" && (key as! String) != "group" }).forEach({ e in k.append(e.key as! NSCopying); v.append(e.value) })
        self.properties = NSDictionary(objects: v, forKeys: k)
    }
    
    convenience init(type t: String, paramGroup group: Int, params: [AnyHashable : Any]) {
        var keys = Array<NSCopying>()
        keys.append("type" as NSCopying)
        keys.append("group" as NSCopying)
        params.keys.forEach({k in keys.append(k as! NSCopying)})
        var values = Array<Any>()
        values.append(t)
        values.append(group)
        params.values.forEach({v in values.append(v)})
        self.init(dict: NSDictionary(objects: values, forKeys: keys))
    }
}

