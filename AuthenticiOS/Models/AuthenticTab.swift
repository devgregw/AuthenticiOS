//
//  AuthenticTab.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 1/6/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import Foundation

class AuthenticTab {
    public let id: String
    
    public let title: String
    
    public let header: String
    
    public let index: Int
    
    public let elements: [AuthenticElement]
    
    public let hideHeader: Bool
    
    public let hideTitle: Bool
    
    private let visibilityRules: NSDictionary
    
    public func getShouldBeHidden() -> Bool {
        //TODO
        return false
    }
    
    init(dict: NSDictionary) {
        self.id = dict.value(forKey: "id") as! String
        self.title = dict.value(forKey: "title") as! String
        self.header = dict.value(forKey: "header") as! String
        self.index = dict.value(forKey: "index") as! Int
        self.elements = (dict.value(forKey: "elements") as? NSArray)?.map({ element in AuthenticElement(dict: element as! NSDictionary) }) ?? []
        self.hideHeader = dict.value(forKey: "hideHeader") as? Bool ?? false
        self.hideTitle = dict.value(forKey: "hideTitle") as? Bool ?? false
        self.visibilityRules = dict.value(forKey: "visibility") as! NSDictionary
    }
}
