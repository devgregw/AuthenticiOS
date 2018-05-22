//
//  Utilities.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 2/7/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorageUI

extension Date {
    
    static func parseISO8601(string: String) -> Date {
        /*let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return formatter.date(from: string)!*/
        let formatter = DateFormatter()
        formatter.calendar = Calendar.autoupdatingCurrent
        formatter.locale = Locale.autoupdatingCurrent
        formatter.timeZone = TimeZone(abbreviation: "GMT")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return formatter.date(from: string)!
    }
    
    func format(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.autoupdatingCurrent
        formatter.locale = Locale.autoupdatingCurrent
        formatter.timeZone = TimeZone.autoupdatingCurrent
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        return formatter.string(from: self)
    }
}

extension UITextView {
    public func embedInStackViewWithInsets(top t: CGFloat, left l: CGFloat, bottom b: CGFloat, right r: CGFloat) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [self])
        stack.layoutMargins = UIEdgeInsetsMake(t, l, b, r)
        stack.sizeToFit()
        stack.layoutIfNeeded()
        return stack
    }
}

extension String {
    public static func isNilOrEmpty(_ str: String?) -> Bool {
        return (str?.count ?? 0) == 0
    }
}

class VersionInfo {
    static let Version = "1.0.0"
    static let Update = 0
}

class Reachability {
    static func getConnectionStatus(completionHandler: @escaping (Bool) -> Void) {
        let address = "https://example.com"
        let url = URL(string: address)!
        let request = URLRequest(url: url)
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            if (error != nil || response == nil) {
                DispatchQueue.main.async {
                    completionHandler(false)
                }
            } else {
                DispatchQueue.main.async {
                    completionHandler(true)
                }
            }
        })
        task.resume()
    }
}

class Utilities {
    class MapInterface {
        static func isGoogleMapsAvailable() -> Bool {
            return UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!)
        }
        
        static func getDirections(toAddress address: String) {
            if isGoogleMapsAvailable() {
                UIApplication.shared.openURL(URL(string: "https://www.google.com/maps/dir/?api=1&destination=\(address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)")!)
            } else {
                UIApplication.shared.openURL(URL(string: "http://maps.apple.com/?daddr=\(address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)")!)
            }
        }
        
        static func search(forPlace location: String) {
            if isGoogleMapsAvailable() {
                UIApplication.shared.openURL(URL(string: "https://www.google.com/maps/search/?api=1&query=\(location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)")!)
            } else {
                UIApplication.shared.openURL(URL(string: "http://maps.apple.com/?q=\(location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)")!)
            }
        }
    }
    
    static func applyTintColor(to vc: UIViewController) {
        vc.navigationController?.navigationBar.barTintColor = UIColor.black
    }
    
    static func literalToNSDictionary(_ literal: [(key: Any, value: Any)]) -> NSDictionary {
        var k: [NSCopying] = []
        var v: [Any] = []
        literal.forEach({ e in k.append(e.key as! NSCopying); v.append(e.value) })
        return NSDictionary(objects: v, forKeys: k)
    }
    
    static func loadFirebase(image: String, into: UIImageView) {
        into.sd_setImage(with: Storage.storage().reference().child(image), placeholderImage: nil, completion: { (i, e, c, r) in
            if (i == nil) {
                return
            }
            let newHeight = (i!.size.height / i!.size.width) * (UIScreen.main.bounds.width)
            into.addConstraint(NSLayoutConstraint(item: into, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: newHeight))
        })
    }
}
