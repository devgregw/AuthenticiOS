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
        
        let header: ImageResource
        
        init(title: String, hideTitle: Bool, header: ImageResource) {
            self.title = title
            self.hideTitle = hideTitle
            self.header = header
        }
        
        convenience init(dict: NSDictionary) {
            self.init(title: dict["title"] as! String, hideTitle: dict["hideTitle"] as! Bool, header: ImageResource(dict: dict["header"] as! NSDictionary))
        }
    }
    
    let events: Events
    
    init(dict: NSDictionary) {
        self.events = Events(dict: dict["events"] as! NSDictionary)
    }
}
