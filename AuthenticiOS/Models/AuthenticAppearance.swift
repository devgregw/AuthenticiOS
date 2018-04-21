//
//  AuthenticAppearance.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 4/21/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import Foundation

class AuthenticAppearance {
    class Events {
        let title: String
        
        let hideTitle: Bool
        
        let header: String
        
        init(dict: NSDictionary) {
            self.title = dict["title"] as! String
            self.hideTitle = dict["hideTitle"] as! Bool
            self.header = dict["header"] as! String
        }
    }
    
    let events: Events
    
    init(dict: NSDictionary) {
        self.events = Events(dict: dict["events"] as! NSDictionary)
    }
}
