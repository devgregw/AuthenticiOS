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
    
    static func isAppleMapsAvailable() -> Bool {
        return UIApplication.shared.canOpenURL(URL(string: "http://maps.apple.com")!)
    }
    
    private static func queryMap(apple: URL, google: URL) {
        let gmaps = isGoogleMapsAvailable()
        let amaps = isAppleMapsAvailable()
        let openApple = {UIApplication.shared.open(apple, options: [:], completionHandler: nil)}
        let openGoogle = {UIApplication.shared.open(google, options: [:], completionHandler: nil)}
        if gmaps && amaps {
            let alert = UIAlertController(title: "Select App", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Apple Maps", style: .default, handler: {_ in openApple()}))
            alert.addAction(UIAlertAction(title: "Google Maps", style: .default, handler: {_ in openGoogle()}))
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancel)
            alert.preferredAction = cancel
            AppDelegate.getTopmostViewController().present(alert, animated: true, completion: nil)
        } else if gmaps {
            openGoogle()
        } else {
            openApple()
        }
    }
    
    static func getDirections(toAddress address: String) {
        queryMap(apple: URL(string: "http://maps.apple.com/?daddr=\(address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)")!, google: URL(string: "https://www.google.com/maps/dir/?api=1&destination=\(address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)")!)
    }
    
    static func search(forPlace location: String) {
        queryMap(apple: URL(string: "http://maps.apple.com/?q=\(location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)")!, google: URL(string: "https://www.google.com/maps/search/?api=1&query=\(location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)")!)
    }
}
