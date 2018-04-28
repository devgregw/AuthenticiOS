//
//  RecurrenceRule.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 4/17/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import Foundation
import EventKit

class RecurrenceRule {
    class Occurrence {
        public let startDate: Date
        
        public let endDate: Date
        
        public func format() -> String {
            let cal = Calendar.current
            if (cal.component(.year, from: startDate) != cal.component(.year, from: endDate) || cal.ordinality(of: .day, in: .year, for: startDate) != cal.ordinality(of: .day, in: .year, for: endDate)) {
                return "Starts on \(startDate.format(dateStyle: .long, timeStyle: .none)) at \(startDate.format(dateStyle: .none, timeStyle: .long)) and ends on \(endDate.format(dateStyle: .long, timeStyle: .none)) at \(endDate.format(dateStyle: .none, timeStyle: .long))"
            } else {
                return "From \(startDate.format(dateStyle: .none, timeStyle: .long)) to \(endDate.format(dateStyle: .none, timeStyle: .long)) on \(startDate.format(dateStyle: .long, timeStyle: .none))"
            }
        }
        
        init(start s: Date, end e: Date) {
            self.startDate = s
            self.endDate = e
        }
    }
    
    private let frequency: String
    
    private let interval: Int
    
    private let endDate: Date?
    
    private let count: Int?
    
    public func isInfinite() -> Bool {
        return endDate == nil && count ==  nil
    }
    
    public func toEKRecurrenceRule() -> EKRecurrenceRule {
        var end: EKRecurrenceEnd? = nil
        if (self.endDate != nil) {
            end = EKRecurrenceEnd(end: self.endDate!)
        } else if (self.count != nil) {
            end = EKRecurrenceEnd(occurrenceCount: self.count!)
        }
        let freq: EKRecurrenceFrequency!
        switch (self.frequency) {
        case "daily":
            freq = .daily
            break
        case "weekly":
            freq = .weekly
            break
        case "monthly":
            freq = .monthly
            break
        case "yearly":
            freq = .yearly
            break
        default:
            freq = .daily
        }
        return EKRecurrenceRule(recurrenceWith: freq, interval: self.interval, end: end)
    }
    
    public func format(initialStart s: Date, initialEnd e: Date) -> String {
        let amount = interval == 1 ? "every" : (interval == 2 ? "every other" : "every \(interval)")
        let main = "Repeats \(amount) \(frequency == "daily" ? "day" : frequency.replacingOccurrences(of: "ly", with: ""))\(interval > 2 ? "s" : "")"
        if (endDate != nil) {
            return "\(main) until \(endDate!.format(dateStyle: .long, timeStyle: .long))"
        } else if (count != nil) {
            let num = getOccurrences(initialStart: s, initialEnd: e).map { o in o.startDate >= Date() }.count
            return "\(main) \(num) more time\(num > 1 ? "s" : "")"
        }
        return main
    }
    
    private func getOccurrences(initialStart s: Date, initialEnd e: Date) -> [Occurrence] {
        var list: [Occurrence] = []
        list.append(Occurrence(start: s, end: e))
        if (endDate != nil) {
            while (list.max { a, b in a.startDate > b.startDate }!.startDate < endDate!) {
                let max = list.max { a, b in a.startDate > b.startDate }!
                list.append(max)
            }
            if (list.max { a, b in a.startDate > b.startDate }!.startDate > endDate!) {
                list.removeLast()
            }
        } else if (count != nil) {
            while (list.count < count!) {
                let max = list.max { a, b in a.startDate > b.startDate }!
                list.append(Occurrence(start: addInterval(to: max.startDate), end: addInterval(to: max.endDate)))
            }
        }
        return list
    }
    
    private func addInterval(to: Date) -> Date {
        var components = DateComponents()
        switch (frequency) {
        case "daily":
            components.day = interval
            break
        case "weekly":
            components.day = 7 * interval
            break
        case "monthly":
            components.month = interval
            break
        case "yearly":
            components.year = interval
            break
        default:
            break
        }
        return Calendar.current.date(byAdding: components, to: to)!
    }
    
    public func getNextOccurrence(initialStart s: Date, initialEnd e: Date) -> Occurrence? {
        return getOccurrences(initialStart: s, initialEnd: e).first { o in o.startDate >= Date() }
    }
    
    init(freq: String, interval: Int, end: Date?, count: Int?) {
        self.frequency = freq
        self.interval = interval
        self.endDate = end
        self.count = count
    }
    
    convenience init(dict: NSDictionary) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        let e = dict["endDate"] != nil ? formatter.date(from: dict["endDate"] as! String)! : nil
        self.init(freq: dict["frequency"] as! String, interval: dict["interval"] as! Int, end: e, count: dict["count"] as? Int)
    }
}
