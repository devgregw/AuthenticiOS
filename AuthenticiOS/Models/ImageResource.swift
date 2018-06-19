//
//  ImageResource.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 6/18/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import Foundation

class ImageResource {
    public let imageName: String
    
    public let width: Int
    
    public let height: Int
    
    init(dict: NSDictionary) {
        self.imageName = dict.value(forKey: "name", default: "unknown.png")
        self.width = dict.value(forKey: "width", default: 720)
        self.height = dict.value(forKey: "height", default: 1080)
    }
    
    convenience init(imageName: String, width: Int, height: Int) {
        self.init(dict: NSDictionary(dictionary: ["name": imageName, "width": width, "height": height]))
    }
}
