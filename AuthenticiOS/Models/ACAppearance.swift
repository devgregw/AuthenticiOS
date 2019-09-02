//
//  ACAppearance.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 4/21/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import Foundation

class ACAppearance {
    class Events {
        let title: String
        
        let hideTitle: Bool
        
        let header: ACImageResource
        
        init(title: String, hideTitle: Bool, header: ACImageResource) {
            self.title = title
            self.hideTitle = hideTitle
            self.header = header
        }
        
        convenience init(dict: NSDictionary) {
            self.init(title: dict["title"] as! String, hideTitle: dict["hideTitle"] as! Bool, header: ACImageResource(dict: dict["header"] as! NSDictionary))
        }
    }
    
    class Tabs {
        let fill: Bool
        
        init(fill: Bool) {
            self.fill = fill
        }
        
        convenience init(dict: NSDictionary) {
            self.init(fill: dict["fill"] as? Bool ?? true)
        }
    }
    
    let events: Events
    
    let tabs: Tabs
    
    init(dict: NSDictionary) {
        self.events = Events(dict: dict["events"] as! NSDictionary)
        self.tabs = Tabs(dict: dict["tabs"] as! NSDictionary)
    }
}
