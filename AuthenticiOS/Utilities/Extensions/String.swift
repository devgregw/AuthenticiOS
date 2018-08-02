//
//  String.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 8/1/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import Foundation

extension String {
    public static func isNilOrEmpty(_ str: String?) -> Bool {
        return (str?.count ?? 0) == 0
    }
}
