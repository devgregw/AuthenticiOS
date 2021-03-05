//
//  AnalyticsHelper.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 12/20/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAnalytics

class AnalyticsHelper {
    static func invokeAction(_ action: ACButtonAction, origin: String, medium: String) {
        AppDelegate.log("Invoking action - type: \(action.type); paramGroup: \(action.paramGroup); count: \(action.propertyCount); source: \(origin); medium: \(medium);")
        Analytics.logEvent("invoke_action", parameters: [
            AnalyticsParameterContentType: "\(action.type)(\(action.paramGroup))",
            AnalyticsParameterContent: action.propertyCount,
            AnalyticsParameterSource: origin,
            AnalyticsParameterMedium: medium,
        ])
    }
    
    static func activatePage(id: String, title: String, type: String, content: String, origin: String, medium: String) {
        AppDelegate.log("Activating page - id: \(id); title: \(title); type: \(type); content: \(content); source: \(origin); medium: \(medium);")
        Analytics.logEvent("activate_page", parameters: [
            AnalyticsParameterItemID: id,
            AnalyticsParameterItemName: title,
            AnalyticsParameterContentType: type,
            AnalyticsParameterContent: content,
            AnalyticsParameterSource: origin,
            AnalyticsParameterMedium: medium,
        ])
    }
    
    static func activatePage(tab: ACTab, origin: String, medium: String) {
        activatePage(id: tab.id, title: tab.title, type: "tab", content: tab.action?.type ?? (tab.specialType ?? "elements(\(tab.elements.count))"), origin: origin, medium: medium)
    }
    
    static func activatePage(event: ACEvent, origin: String, medium: String) {
        activatePage(id: event.id, title: event.title, type: "event", content: "event", origin: origin, medium: medium)
    }
    
    static func activatePage(event: ACEventPlaceholder, origin: String, medium: String) {
        activatePage(id: event.id, title: event.title, type: "eventPlaceholder", content: event.action?.type ?? "elements", origin: origin, medium: medium)
    }
}
