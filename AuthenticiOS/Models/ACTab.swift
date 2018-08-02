//
//  ACTab.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 1/6/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import Foundation

class ACTab {
    public let id: String
    
    public let title: String
    
    public let header: ACImageResource
    
    public let index: Int
    
    public let elements: [ACElement]
    
    public let hideHeader: Bool
    
    public let hideTitle: Bool
    
    private let visibilityRules: NSDictionary
    
    public let action: ACButtonAction?
    
    public let specialType: String?
    
    public func getShouldBeHidden() -> Bool {
        if (elements.isEmpty) {
            return true
        }
        if (visibilityRules.value(forKey: "override") as! Bool) {
            return false
        }
        let endString = visibilityRules.value(forKey: "end") as! String
        let startString = visibilityRules.value(forKey: "start") as! String
        if endString.isEmpty || startString.isEmpty {
            return true
        }
        let end = Date.parseISO8601(string: endString)
        let start = Date.parseISO8601(string: startString)
        let now = Date()
        return now >= end || now <= start
    }
    
    init(dict: NSDictionary) {
        self.id = dict.value(forKey: "id", default: "INVALID")
        self.title = dict.value(forKey: "title", default: "INVALID")
        self.header = ACImageResource(dict: dict.value(forKey: "header", default: NSDictionary()))
        self.index = dict.value(forKey: "index", default: 0)
        self.elements = (dict.value(forKey: "elements", default: NSArray())).filter({element in (element as? NSDictionary) != nil}).map({ element in ACElement(dict: element as! NSDictionary) })
        self.hideHeader = dict.value(forKey: "hideHeader", default: false)
        self.hideTitle = dict.value(forKey: "hideTitle", default: false)
        self.visibilityRules = dict.value(forKey: "visibility", default: NSDictionary())
        self.specialType = dict.value(forKey: "specialType", default: nil)
        if dict.contains(where: { (k, _) -> Bool in
            return (k as! String) == "action"
        }) {
            self.action = ACButtonAction(dict: dict.value(forKey: "action") as! NSDictionary)
        } else {
            self.action = nil
        }
    }
}
