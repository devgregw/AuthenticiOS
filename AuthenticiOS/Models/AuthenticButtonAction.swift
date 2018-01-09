//
//  AuthenticButtonAction.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 1/6/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class AuthenticButtonAction {
    public let type: String
    
    public let paramGroup: Int
    
    private let properties: NSDictionary
    
    public func getProperty(withName name: String) -> Any? {
        return properties[name]
    }
    
    public func invoke(viewController vc: UIViewController) {
        if (self.type == "OpenTabAction") {
            Database.database().reference().child("/tabs/\(self.getProperty(withName: "tabId") as! String)/").observeSingleEvent(of: .value, with: {snapshot in
                let val = snapshot.value as? NSDictionary
                if (val != nil) {
                    ACTabViewController.present(tab: AuthenticTab(dict: val!), withViewController: vc)
                }
            }) { error in vc.present(UIAlertController(title: "Error", message: error.localizedDescription as String, preferredStyle: .alert), animated: true) }
        } else {
            vc.present(UIAlertController(title: "Error", message: "Invalid action", preferredStyle: .alert), animated: true)
        }
    }
    
    init(dict: NSDictionary) {
        self.type = dict.value(forKey: "type") as! String
        self.paramGroup = dict.value(forKey: "group") as! Int
        var k: [NSCopying] = []
        var v: [Any] = []
        dict.filter({(key, value) in return (key as! String) != "type" && (key as! String) != "group" }).forEach({ e in k.append(e.key as! NSCopying); v.append(e.value) })
        self.properties = NSDictionary(objects: v, forKeys: k)
    }
}

