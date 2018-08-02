//
//  MapInterface.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 8/1/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import Foundation
import UIKit

class MapInterface {
    static func isGoogleMapsAvailable() -> Bool {
        return UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!)
    }
    
    static func getDirections(toAddress address: String) {
        if isGoogleMapsAvailable() {
            UIApplication.shared.open(URL(string: "https://www.google.com/maps/dir/?api=1&destination=\(address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)")!, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.open(URL(string: "http://maps.apple.com/?daddr=\(address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)")!, options: [:], completionHandler: nil)
        }
    }
    
    static func search(forPlace location: String) {
        if isGoogleMapsAvailable() {
            UIApplication.shared.open(URL(string: "https://www.google.com/maps/search/?api=1&query=\(location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)")!, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.open(URL(string: "http://maps.apple.com/?q=\(location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)")!, options: [:], completionHandler: nil)
        }
    }
}
