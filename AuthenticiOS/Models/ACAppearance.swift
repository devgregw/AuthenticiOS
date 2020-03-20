//
//  ACAppearance.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 4/21/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import Foundation
import UIKit

fileprivate func hexToColor(string: String) -> UIColor {
    let r, g, b, a: CGFloat
    let start = string.index(string.startIndex, offsetBy: 1)
    let hexColor = String(string[start...])

    if hexColor.count == 8 {
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0

        if scanner.scanHexInt64(&hexNumber) {
            r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
            g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
            b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
            a = CGFloat(hexNumber & 0x000000ff) / 255

            return UIColor(red: r, green: g, blue: b, alpha: a)
        }
    }
    if #available(iOS 13.0, *) {
        return UIColor.systemBackground
    } else {
        return UIColor.white
    }
}

class ACAppearance {
    class Livestream {
        let enable: Bool
        let image: String?
        let color: UIColor
        
        init(enable: Bool, image: String?, color: String?) {
            self.enable = enable
            self.image = image
            if #available(iOS 13.0, *) {
                self.color = color == nil ? UIColor.systemBackground : hexToColor(string: color!)
            } else {
                self.color = color == nil ? UIColor.white : hexToColor(string: color!)
            }
        }
        
        convenience init(dict: NSDictionary?) {
            self.init(enable: dict?["enable"] as? Bool ?? true, image: dict?["image"] as? String ?? nil, color: dict?["color"] as? String ?? nil)
        }
    }
    
    class Events {
        let title: String
        
        let hideTitle: Bool
        
        let header: ACImageResource
        
        let index: Int
        
        init(title: String, hideTitle: Bool, header: ACImageResource, index: Int) {
            self.title = title
            self.hideTitle = hideTitle
            self.header = header
            self.index = index
        }
        
        convenience init(dict: NSDictionary?) {
            self.init(title: dict?["title"] as? String ?? "EVENTS", hideTitle: dict?["hideTitle"] as? Bool ?? true, header: dict == nil ? ACImageResource(imageName: "unknown.png", width: 1080, height: 1920) : ACImageResource(dict: dict!["header"] as! NSDictionary), index: dict?["index"] as? Int ?? -999)
        }
    }
    
    class Tabs {
        let fill: Bool
        
        init(fill: Bool) {
            self.fill = fill
        }
        
        convenience init(dict: NSDictionary?) {
            self.init(fill: dict?["fill"] as? Bool ?? true)
        }
    }
    
    let events: Events
    let livestream: Livestream
    let tabs: Tabs
    
    init(dict: NSDictionary) {
        self.events = Events(dict: dict["events"] as? NSDictionary)
        self.tabs = Tabs(dict: dict["tabs"] as? NSDictionary)
        self.livestream = Livestream(dict: dict["livestream"] as? NSDictionary)
    }
}
