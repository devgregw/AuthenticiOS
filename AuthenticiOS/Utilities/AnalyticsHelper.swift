//
//  AnalyticsHelper.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 12/20/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import Foundation
import Firebase

class AnalyticsHelper {
    static func activatePage(id: String, title: String, type: String, content: String, origin: String, medium: String) {
        CLSNSLogv("%@", getVaList(["Activating page: \(id) \(title) \(type) \(content) \(origin) \(medium)"]))
        Analytics.logEvent("activate_page", parameters: [
            AnalyticsParameterItemID: id,
            AnalyticsParameterItemName: title,
            AnalyticsParameterContentType: type,
            AnalyticsParameterContent: content,
            AnalyticsParameterOrigin: origin,
            AnalyticsParameterMedium: medium,
        ])
    }
    
    static func activatePage(tab: ACTab, origin: String, medium: String) {
        activatePage(id: tab.id, title: tab.title, type: "tab", content: tab.action?.type ?? (tab.specialType ?? "elements"), origin: origin, medium: medium)
    }
    
    static func activatePage(event: ACEvent, origin: String, medium: String) {
        activatePage(id: event.id, title: event.title, type: "event", content: "event", origin: origin, medium: medium)
    }
    
    static func activatePage(event: ACEventPlaceholder, origin: String, medium: String) {
        activatePage(id: event.id, title: event.title, type: "eventPlaceholder", content: event.action?.type ?? "elements", origin: origin, medium: medium)
    }
}
