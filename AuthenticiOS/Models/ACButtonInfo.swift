//
//  ACButtonInfo.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 1/6/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import Foundation

class ACButtonInfo {
    public let label: String
    
    public let action: ACButtonAction
    
    init(dict: NSDictionary) {
        self.label = dict.value(forKey: "label") as! String
        self.action = ACButtonAction(dict: dict.value(forKey: "action") as! NSDictionary)
    }
    
    convenience init(label lbl: String, action a: ACButtonAction) {
        self.init(dict: NSDictionary(dictionary: ["label": lbl, "action": a.rootDictionary]))
    }
}

