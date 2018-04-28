//
//  AuthenticEvent.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 4/17/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import Foundation

class AuthenticEvent {
    public let id: String
    
    public let title: String
    
    public let hideTitle: Bool
    
    public let description: String
    
    public let header: String
    
    public let location: String
    
    public let address: String
    
    public let startDate: Date
    
    public let endDate: Date
    
    public let recurrence: RecurrenceRule?
    
    public let registrationUrl: String?
    
    public let price: Float?
    
    public func isRegistrationRequired() -> Bool {
        return self.registrationUrl != nil && self.price != nil
    }
    
    public func getShouldBeHidden() -> Bool {
        let occurrence = getNextOccurrence()
        if (occurrence == nil) {
            return true
        } else {
            return Date() > occurrence!.endDate
        }
    }
    
    public func getNextOccurrence() -> RecurrenceRule.Occurrence? {
        if (self.recurrence != nil) {
            return recurrence!.getNextOccurrence(initialStart: self.startDate, initialEnd: self.endDate)
        } else {
            return RecurrenceRule.Occurrence(start: self.startDate, end: self.endDate)
        }
    }
    
    init(id: String, title: String, hideTitle: Bool, description: String, header: String, location: String, address: String, dateTime: NSDictionary, recurrence: NSDictionary?, registration: NSDictionary?) {
        self.id = id
        self.title = title
        self.hideTitle = hideTitle
        self.description = description
        self.header = header
        self.location = location
        self.address = address
        self.startDate = Date.parseISO8601(string: dateTime["start"] as! String)
        self.endDate = Date.parseISO8601(string: dateTime["end"] as! String)
        self.recurrence = recurrence != nil ? RecurrenceRule(dict: recurrence!) : nil
        if (registration != nil) {
            self.registrationUrl = registration!["url"] as? String
            self.price = registration!["price"] as? Float
        } else {
            self.registrationUrl = nil
            self.price = nil
        }
    }
    
    convenience init(dict: NSDictionary) {
        self.init(id: dict["id"] as! String, title: dict["title"] as! String, hideTitle: dict["hideTitle"] as! Bool, description: dict["description"] as! String, header: dict["header"] as! String, location: dict["location"] as! String, address: dict["address"] as! String, dateTime: dict["dateTime"] as! NSDictionary, recurrence: dict["recurrence"] as? NSDictionary, registration: dict["registration"] as? NSDictionary)
    }
}
