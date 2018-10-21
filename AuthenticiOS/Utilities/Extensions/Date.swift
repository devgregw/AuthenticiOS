//
//  Date.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 8/1/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import Foundation

fileprivate var iso8601Formatter: DateFormatter?
fileprivate var customFormatter: DateFormatter?

extension Date {
    private static func getIso8601() -> DateFormatter {
        if iso8601Formatter == nil {
            iso8601Formatter = DateFormatter()
            iso8601Formatter!.calendar = Calendar.autoupdatingCurrent
            iso8601Formatter!.locale = Locale.autoupdatingCurrent
            iso8601Formatter!.timeZone = TimeZone(abbreviation: "GMT")
            iso8601Formatter!.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        }
        return iso8601Formatter!
    }
    
    static func parseISO8601(string: String) -> Date {
        return getIso8601().date(from: string)!
    }
    
    func formatISO8601() -> String {
        return Date.getIso8601().string(from: self)
    }
    
    func format(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) -> String {
        if customFormatter == nil {
            customFormatter = DateFormatter()
            customFormatter!.calendar = Calendar.autoupdatingCurrent
            customFormatter!.locale = Locale.autoupdatingCurrent
            customFormatter!.timeZone = TimeZone.autoupdatingCurrent
        }
        customFormatter!.dateStyle = dateStyle
        customFormatter!.timeStyle = timeStyle
        return customFormatter!.string(from: self)
    }
}
