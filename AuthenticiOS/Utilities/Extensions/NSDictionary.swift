//
//  NSDictionary.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 8/1/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import Foundation

extension NSDictionary {
    public func value<T>(forKey key: String, default def: T) -> T {
        if let value = self[key] as? T {
            return value
        }
        return def
    }
    
    static var defaultDateTimeDictionary: NSDictionary {
        return NSDictionary(objects: [Date().formatISO8601(), Date().addingTimeInterval(24*3600).formatISO8601()], forKeys: ["start" as NSCopying, "end" as NSCopying])
    }
    
    convenience init(literal: [(key: Any, value: Any)]) {
        var k: [NSCopying] = []
        var v: [Any] = []
        literal.forEach({ e in k.append(e.key as! NSCopying); v.append(e.value) })
        self.init(objects: v, forKeys: k)
    }
}
