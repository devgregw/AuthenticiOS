//
//  ACEvent.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 4/17/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import Foundation

class ACEvent {
    public let id: String
    
    public let title: String
    
    public let hideTitle: Bool
    
    public let description: String
    
    public let header: ACImageResource
    
    public let location: String
    
    public let address: String
    
    public let startDate: Date
    
    public let endDate: Date
    
    public let hideEndDate: Bool
    
    public let recurrence: ACRecurrenceRule?
    
    public let registrationUrl: String?
    
    public let price: Float?
    
    public func isVisible() -> Bool {
        return !getShouldBeHidden()
    }
    
    private func getShouldBeHidden() -> Bool {
        return Date() > getNextOccurrence().endDate
    }
    
    public func getNextOccurrence() -> ACRecurrenceRule.Occurrence {
        return recurrence?.getNextOccurrence(initialStart: self.startDate, initialEnd: self.endDate) ?? ACRecurrenceRule.Occurrence(start: self.startDate, end: self.endDate)
    }
    
    init(id: String, title: String, hideTitle: Bool, description: String, header: ACImageResource, location: String, address: String, dateTime: NSDictionary, hideEndDate: Bool, recurrence: NSDictionary?, registration: NSDictionary?) {
        self.id = id
        self.title = title
        self.hideTitle = hideTitle
        self.description = description
        self.header = header
        self.location = location
        self.address = address
        self.startDate = Date.parseISO8601(string: dateTime["start"] as! String)
        self.endDate = Date.parseISO8601(string: dateTime["end"] as! String)
        self.hideEndDate = hideEndDate
        self.recurrence = recurrence != nil ? ACRecurrenceRule(dict: recurrence!) : nil
        if (registration != nil) {
            self.registrationUrl = registration!["url"] as? String
            self.price = registration!["price"] as? Float
        } else {
            self.registrationUrl = nil
            self.price = nil
        }
    }
    
    static func createNew(dict: NSDictionary) -> ACEvent {
        if (dict.allKeys.contains(where: { (key) -> Bool in
            String(describing: key) == "index"
        })) {
            return ACEventPlaceholder(dict: dict)
        } else {
            return ACEvent(dict: dict)
        }
    }
    
    convenience init(dict: NSDictionary) {
        self.init(id: dict.value(forKey: "id", default: "INVALID"), title: dict.value(forKey: "title", default: "INVALID"), hideTitle: dict.value(forKey: "hideTitle", default: false), description: dict.value(forKey: "description", default: "INVALID"), header: ACImageResource(dict:                                         dict.value(forKey: "header", default: NSDictionary())), location: dict.value(forKey: "location", default: "INVALID"), address: dict.value(forKey: "address", default: ""), dateTime: dict.value(forKey: "dateTime", default: NSDictionary.defaultDateTimeDictionary), hideEndDate: dict.value(forKey: "hideEndDate", default: false), recurrence: dict["recurrence"] as? NSDictionary, registration: dict["registration"] as? NSDictionary)
    }
}
