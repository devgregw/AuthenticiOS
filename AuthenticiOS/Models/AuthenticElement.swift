//
//  AuthenticElement.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 2/7/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import Foundation
import UIKit

class AuthenticElement {
    let id: String
    let parent: String
    let type: String
    let properties: NSDictionary
    
    init(dict: NSDictionary) {
        self.id = dict["id"] as! String
        self.parent = dict["parent"] as! String
        self.type = dict["type"] as! String
        self.properties = Utilities.literalToNSDictionary(dict.filter({ item -> Bool in
            return item.key as! String != "id" && item.key as! String != "parent" && item.key as! String != "type"
        }))
    }
    
    private func getProperty<T>(_ name: String) -> T {
        return self.properties[name] as! T
    }
    
    func getView() -> UIView {
        switch (type) {
        case "image":
            let image = UIImageView()
            image.contentMode = .scaleAspectFit
            Utilities.loadFirebase(image: getProperty("image"), into: image)
            return image
        //case "video":
        case "title":
            let label = GWLabel()
            label.setInsets(top: 5, left: 10, bottom: 0, right: 10)
            label.text = getProperty("title")
            label.font = UIFont(name: "Futura PT Web Heavy", size: 26)
            let alignment : String = getProperty("alignment")
            switch (alignment) {
            case "center":
                label.textAlignment = .center
                break
            case "right":
                label.textAlignment = .right
                break
            default:
                label.textAlignment = .left
                break;
            }
            return label
        case "text":
            let label = GWLabel()
            label.setInsets(top: 5, left: 10, bottom: 0, right: 10)
            label.text = getProperty("text")
            label.font = UIFont(name: "Proxima Nova", size: 16)
            let alignment : String = getProperty("alignment")
            switch (alignment) {
            case "center":
                label.textAlignment = .center
                break
            case "right":
                label.textAlignment = .right
                break
            default:
                label.textAlignment = .left
                break;
            }
            return label
        //case "button":
        //case "separator":
        default:
            let label = GWLabel()
            label.setInsets(top: 5, left: 10, bottom: 0, right: 10)
            label.text = "Unknown element: \(type)"
            label.textColor = UIColor.red
            label.font = UIFont(name: "Proxima Nova", size: 16)
            return label
        }
    }
}
