//
//  ACButtonAction.swift
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

class ACButtonAction {
    public let type: String
    
    public let paramGroup: Int
    
    private let properties: NSDictionary
    
    var propertyCount: Int {
        return properties.count
    }
    
    public let rootDictionary: NSDictionary
    
    public static let empty = ACButtonAction(type: "none", paramGroup: -1, params: [:])
    
    public func getProperty(withName name: String) -> Any? {
        return properties[name]
    }
    
    var accessibilityLabel: String {
        switch (self.type) {
        case "OpenEventsPageAction": return "View upcoming events"
        case "OpenTabAction": return "Open page"
        case "OpenEventAction": return "View event details"
        case "OpenURLAction": return "Open webpage"
        case "OpenYouTubeAction": return "Watch on YouTube"
        case "OpenSpotifyAction": return "Listen on Spotify"
        case "ShowMapAction": return "Open maps"
        case "GetDirectionsAction": return "Get directions"
        case "EmailAction": return "Send email"
        case "AddToCalendarAction": return "Add to calendar"
        case "none": return "None"
        default: return "Invalid action"
        }
    }
    
    private func presentAlert(title: String, message: String, vc: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        vc.present(alert, animated: true)
    }
    
    public func invoke(viewController vc: UIViewController, origin: String, medium: String) {
        AnalyticsHelper.invokeAction(self, origin: origin, medium: medium)
        switch (self.type) {
        case "OpenEventsPageAction":
            return ACEventCollectionViewController.present(withTitle: "UPCOMING EVENTS")
        case "OpenTabAction":
            DatabaseHelper.loadTab(id: getProperty(withName: "tabId") as! String, keepSynced: false, completion: {result in
                guard result != nil else {
                    self.presentAlert(title: "Error", message: "We were unable to open the page because it does not exist.", vc: vc)
                    return
                }
                ACTabViewController.present(tab: result!, origin: origin, medium: self.type)
            })
        case "OpenEventAction":
            Database.database().reference().child("/events/\(self.getProperty(withName: "eventId") as! String)/").observeSingleEvent(of: .value, with: {snapshot in
                guard let val = snapshot.value as? NSDictionary else {
                    self.presentAlert(title: "Error", message: "We were unable to open the event because it does not exist.", vc: vc)
                    return
                }
                let event = ACEvent.createNew(dict: val)
                if let placeholder = event as? ACEventPlaceholder {
                    if placeholder.action != nil {
                        AnalyticsHelper.activatePage(event: placeholder, origin: origin, medium: self.type)
                        placeholder.action!.invoke(viewController: vc, origin: origin, medium: medium)
                    } else if placeholder.elements?.count ?? 0 > 0 {
                        ACEventViewController.present(event: placeholder, isPlaceholder: true, origin: origin, medium: self.type)
                    }
                } else {
                    ACEventViewController.present(event: event, isPlaceholder: false, origin: origin, medium: self.type)
                }
            }) { error in self.presentAlert(title: "Error", message: "We were unable to access the database.\n\n\(error.localizedDescription as String)", vc: vc) }
        case "OpenURLAction":
            let urlString = getProperty(withName: "url") as! String
            let url = URL(string: urlString)!
            if !urlString.contains("authentic.church/give") && !urlString.contains("authenticcity.church/give") && (urlString.contains("http://") || urlString.contains("https://")) {
                let safari = SFSafariViewController(url: url)
                safari.preferredBarTintColor = .black
                safari.preferredControlTintColor = .white
                if #available(iOS 13.0, *) {
                    safari.modalPresentationStyle = .pageSheet
                }
                vc.present(safari, animated: true, completion: nil)
            } else {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                } else {
                    let alert = UIAlertController(title: "Error", message: "An app to open the URL \(url) was not found.", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
                    alert.addAction(action)
                    alert.preferredAction = action
                    vc.present(alert, animated: true, completion: nil)
                }
            }
        case "OpenYouTubeAction":
            let youtubeUri = URL(string: getProperty(withName: "youtubeUri") as! String)!
            if UIApplication.shared.canOpenURL(URL(string: "youtube://")!) {
                UIApplication.shared.open(youtubeUri, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            } else {
                let safari = SFSafariViewController(url: URL(string: getProperty(withName: "watchUrl") as! String)!)
                safari.preferredBarTintColor = .black
                safari.preferredControlTintColor = .white
                AppDelegate.topViewController.present(safari, animated: true, completion: nil)
            }
        case "OpenSpotifyAction":
            let spotifyUri = URL(string: getProperty(withName: "spotifyUri") as! String)!
            if UIApplication.shared.canOpenURL(spotifyUri) {
                UIApplication.shared.open(spotifyUri, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            } else {
                let safari = SFSafariViewController(url: URL(string: getProperty(withName: "spotifyUrl") as! String)!)
                safari.preferredBarTintColor = .black
                safari.preferredControlTintColor = .white
                AppDelegate.topViewController.present(safari, animated: true, completion: nil)
            }
        case "ShowMapAction":
            let location = getProperty(withName: "address") as! String
            MapInterface.search(forPlace: location)
        case "GetDirectionsAction":
            let address = getProperty(withName: "address") as! String
            MapInterface.getDirections(toAddress: address)
        case "EmailAction":
            let address = getProperty(withName: "emailAddress")
            if let url = URL(string: "mailto:\(address!)") {
                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            } else {
                presentAlert(title: "Error", message: "This action could not be invoked: '\(address!)' is not a valid email address.", vc: vc)
            }
        case "AddToCalendarAction":
            let atcaCompletion = { (start: Date, end: Date, loc: String, title: String, rrule: ACRecurrenceRule?) in
                let store = EKEventStore()
                store.requestAccess(to: .event) { (granted, error) in
                    if granted {
                        let event = EKEvent(eventStore: store)
                        event.isAllDay = false
                        event.endDate = end
                        event.startDate = start
                        event.structuredLocation = EKStructuredLocation(title: loc)
                        event.title = title
                        if let rule = rrule {
                            event.addRecurrenceRule(rule.toEKRecurrenceRule())
                        }
                        event.calendar = store.defaultCalendarForNewEvents
                        CalendarInterface.add(eventToCalendar: event, withEventStore: store, withViewController: vc)
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
                        let event = ACEvent.createNew(dict: val!)
                        atcaCompletion(event.startDate, event.endDate, event.address == "" ? event.location : event.address, event.title, event.recurrence)
                    } else {
                        self.presentAlert(title: "Error", message: "We were unable to add this event to your calendar because it does not exist.", vc: vc)
                    }
                }) { error in self.presentAlert(title: "Error", message: "We were unable to access the database.\n\n\(error.localizedDescription as String)", vc: vc) }
            } else if self.paramGroup == 1 {
                let dates = self.getProperty(withName: "dates") as! NSDictionary
                let rrule = self.getProperty(withName: "recurrence") as? NSDictionary
                atcaCompletion(Date.parseISO8601(string: dates["start"] as! String), Date.parseISO8601(string: dates["end"] as! String), (self.getProperty(withName: "location") as! String), (self.getProperty(withName: "title") as! String), rrule == nil ? nil : ACRecurrenceRule(dict: rrule!))
            } else {
                self.presentAlert(title: "Error", message: "We were unable to run this action because an invalid parameter group was specified.\n\n\(self.type): \(self.paramGroup)", vc: vc)
            }
        case "none": break
        default:
            let alert = UIAlertController(title: "Error", message: "We were unable to parse this action because the type \"\(self.type)\" is not a recognized action.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            vc.present(alert, animated: true)
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


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
