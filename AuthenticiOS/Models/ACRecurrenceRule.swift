//
//  ACRecurrenceRule.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 4/17/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import Foundation
import EventKit

class ACRecurrenceRule {
    class Occurrence {
        public let startDate: Date
        
        public let endDate: Date
        
        public func format(hideEndDate: Bool) -> String {
            let cal = Calendar.current
            if (cal.component(.year, from: startDate) != cal.component(.year, from: endDate) || cal.ordinality(of: .day, in: .year, for: startDate) != cal.ordinality(of: .day, in: .year, for: endDate)) {
                return "Starts on \(startDate.format(dateStyle: .full, timeStyle: .none)) at \(startDate.format(dateStyle: .none, timeStyle: .short)) and ends on \(endDate.format(dateStyle: .full, timeStyle: .none)) at \(endDate.format(dateStyle: .none, timeStyle: .short))"
            } else {
                if hideEndDate {
                    return "Starts on \(startDate.format(dateStyle: .full, timeStyle: .none)) at \(startDate.format(dateStyle: .none, timeStyle: .short))"
                }
                return "From \(startDate.format(dateStyle: .none, timeStyle: .short)) to \(endDate.format(dateStyle: .none, timeStyle: .short)) on \(startDate.format(dateStyle: .full, timeStyle: .none))"
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
        if (isInfinite()) {
            return main
        } else if (endDate != nil) {
            return "\(main) until \(endDate!.format(dateStyle: .full, timeStyle: .short))"
        } else if (count != nil) {
            let num = getOccurrences(originalStart: s, originalEnd: e).filter { o in o.startDate >= Date() }.count
            return "\(main) \(num) more time\(num != 1 ? "s" : "")"
        } else {
            return "Error"
        }
    }
    
    private func getOccurrences(originalStart: Date, originalEnd: Date) -> [Occurrence] {
        let duration = originalEnd.timeIntervalSince(originalStart)
        var occurrences = [Occurrence]()
        if isInfinite() {
            var firstAfter = originalStart
            while firstAfter < Date() {
                firstAfter = addInterval(to: firstAfter)
            }
            for _ in 1...10 {
                occurrences.append(Occurrence(start: firstAfter, end: firstAfter.addingTimeInterval(duration)))
                firstAfter = addInterval(to: firstAfter)
            }
        } else if let until = endDate {
            var nextStart = originalStart
            var after = addInterval(to: nextStart)
            while after < until {
                occurrences.append(Occurrence(start: nextStart, end: nextStart.addingTimeInterval(duration)))
                nextStart = after
                after = addInterval(to: after)
            }
        } else if let number = count {
            occurrences.append(Occurrence(start: originalStart, end: originalEnd))
            for _ in 1...(number - 1) {
                let oc = occurrences.last!
                occurrences.append(Occurrence(start: addInterval(to: oc.startDate), end: addInterval(to: oc.endDate)))
            }
        }
        return occurrences
    }
    
    /*private func getOccurrences(initialStart s: Date, initialEnd e: Date) -> [Occurrence] {
        var list: [Occurrence] = []
        list.append(Occurrence(start: s, end: e))
        if (endDate != nil) {
            while (list.max { a, b in a.startDate < b.startDate }!.startDate < endDate!) {
                let max = list.max { a, b in a.startDate < b.startDate }!
                list.append(max)
            }
            if (list.max { a, b in a.startDate < b.startDate }!.startDate > endDate!) {
                list.removeLast()
            }
        } else if (count != nil) {
            while (list.count < count!) {
                let max = list.max { a, b in a.startDate < b.startDate }!
                list.append(Occurrence(start: addInterval(to: max.startDate), end: addInterval(to: max.endDate)))
            }
        } else {
            return ACRecurrenceRule(freq: frequency, interval: interval, end: nil, count: 30).getOccurrences(initialStart: s, initialEnd: e)
        }
        return list
    }*/
    
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
        return getOccurrences(originalStart: s, originalEnd: e).first { o in Date() <= o.startDate }
        //return getOccurrences(initialStart: s, initialEnd: e).first { o in o.startDate <= Date() }
    }
    
    init(freq: String, interval: Int, end: Date?, count: Int?) {
        self.frequency = freq
        self.interval = interval
        self.endDate = end
        self.count = count
    }
    
    convenience init(dict: NSDictionary) {
        let e = dict["date"] != nil ? Date.parseISO8601(string: dict["date"] as! String) : nil
        self.init(freq: dict["frequency"] as! String, interval: dict["interval"] as! Int, end: e, count: dict["number"] as? Int)
    }
}
