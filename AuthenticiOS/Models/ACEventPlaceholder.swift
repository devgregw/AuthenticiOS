//
//  ACEventPlaceholder.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 9/5/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import Foundation

class ACEventPlaceholder: ACEvent {
    public let elements: [ACElement]?
    public let action: ACButtonAction?
    public let index: Int
    public let visibility: Date?
    
    public override func isVisible() -> Bool {
        guard visibility != nil else {return true}
        return visibility! >= Date()
    }
    
    init(id: String, index: Int, title: String, hideTitle: Bool, header: ACImageResource, elements: [ACElement]?, action: ACButtonAction?, visibility: String?) {
        self.elements = elements
        self.action = action
        self.index = index
        self.visibility = visibility != nil ? Date.parseISO8601(string: visibility!) : nil
        super.init(id: id, title: title, hideTitle: hideTitle, description: "", header: header, location: "", address: "", dateTime: NSDictionary.defaultDateTimeDictionary, hideEndDate: false, recurrence: nil, registration: nil)
    }
    
    convenience init(dict: NSDictionary) {
        self.init(id: dict.value(forKey: "id", default: "invalid"), index: dict.value(forKey: "index", default: 0), title: dict.value(forKey: "title", default: "invalid"), hideTitle: dict.value(forKey: "hideTitle", default: false), header: ACImageResource(dict: dict.value(forKey: "header") as! NSDictionary), elements: (dict.value(forKey: "elements", default: NSArray())).filter({element in (element as? NSDictionary) != nil}).map({ element in ACElement(dict: element as! NSDictionary) }), action: dict.allKeys.contains(where: {k in (k as! String) == "action"}) ? ACButtonAction(dict: dict.value(forKey: "action", default: NSDictionary())) : nil, visibility: dict.value(forKey: "visibility", default: nil))
    }
}
