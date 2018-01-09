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
    
    public let bundles: [AuthenticBundle]
    
    init(dict: NSDictionary) {
        self.id = dict.value(forKey: "id") as! String
        self.title = dict.value(forKey: "title") as! String
        self.header = dict.value(forKey: "header") as! String
        self.index = dict.value(forKey: "index") as! Int
        self.bundles = (dict.value(forKey: "bundles") as? NSDictionary)?.map({ element in AuthenticBundle(dict: element.value as! NSDictionary) }) ?? []
        //self.bundles = (dict.value(forKey: "bundles") as? [NSDictionary])?.map({(dictionary) in AuthenticBundle(dict: dictionary)}) ?? []
        self.bundles.sort(by: { (a, b) in a.index < b.index })
    }
}
