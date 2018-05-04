//
//  AuthenticButtonInfo.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 1/6/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import Foundation

class AuthenticButtonInfo {
    public let label: String
    
    public let action: AuthenticButtonAction
    
    init(dict: NSDictionary) {
        self.label = dict.value(forKey: "label") as! String
        self.action = AuthenticButtonAction(dict: dict.value(forKey: "action") as! NSDictionary)
    }
    
    convenience init(label lbl: String, action a: AuthenticButtonAction) {
        self.init(dict: NSDictionary(dictionary: ["label": lbl, "action": a.rootDictionary]))
    }
}

