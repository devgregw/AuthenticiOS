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
import MapKit

class AuthenticButtonAction {
    public let type: String
    
    public let paramGroup: Int
    
    private let properties: NSDictionary
    
    public func getProperty(withName name: String) -> Any? {
        return properties[name]
    }
    
    public func invoke(viewController vc: UIViewController) {
        switch (self.type) {
        case "OpenTabAction":
            Database.database().reference().child("/tabs/\(self.getProperty(withName: "tabId") as! String)/").observeSingleEvent(of: .value, with: {snapshot in
                let val = snapshot.value as? NSDictionary
                if (val != nil) {
                    ACTabViewController.present(tab: AuthenticTab(dict: val!), withViewController: vc)
                }
            }) { error in vc.present(UIAlertController(title: "Error", message: error.localizedDescription as String, preferredStyle: .alert), animated: true) }
            break;
        case "OpenURLAction":
            let url = getProperty(withName: "url")
            UIApplication.shared.openURL(URL(string: url as! String)!)
            break;
        case "GetDirectionsAction":
            let address = getProperty(withName: "address") as! String
            if (UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!)) {
                UIApplication.shared.openURL(URL(string: "comgooglemaps://?directionsmode=driving&daddr=\(address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)")!)
            } else {
                CLGeocoder().geocodeAddressString(address) { (placemarks, error) in
                    if (placemarks == nil || (placemarks?.isEmpty)!) {
                        let errAlert = UIAlertController(title: "Error", message: "We could not get directions because the specified address is invalid: placemarks is nil or empty.", preferredStyle: .alert)
                        errAlert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                        vc.present(errAlert, animated: true)
                    } else if (error != nil) {
                        let errAlert = UIAlertController(title: "Error", message: "We could not get directions because of an unexpected error: \(error!.localizedDescription).", preferredStyle: .alert)
                        errAlert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                        vc.present(errAlert, animated: true)
                    } else {
                        MKMapItem(placemark: MKPlacemark(placemark: placemarks![0])).openInMaps(launchOptions: [ MKLaunchOptionsDirectionsModeDriving : true ])
                    }
                }
            }
            break;
        case "EmailAction":
            let address = getProperty(withName: "emailAddress")
            if let url = URL(string: "mailto:\(address!)") {
                UIApplication.shared.openURL(url)
            } else {
                let alert = UIAlertController(title: "Error", message: "This action could not be invoked: '\(address!)' is not an email address.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                vc.present(alert, animated: true)
            }
            break;
        default:
            let alert = UIAlertController(title: "Error", message: "We were unable to parse this action because the type '\(self.type)' is undefined.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            vc.present(alert, animated: true)
            break;
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

