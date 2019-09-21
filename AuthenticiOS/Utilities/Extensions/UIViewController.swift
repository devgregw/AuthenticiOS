//
//  UIViewController.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 8/1/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import UIKit

extension UIViewController {
    func applyDefaultAppearance() {
        // Remove back button label and make the arrow white
        let btn = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        btn.tintColor = UIColor.white
        navigationItem.backBarButtonItem = btn
        
        // Make the navigation bar black and disable translucency
        navigationController?.navigationBar.barTintColor = UIColor.black
        navigationController?.navigationBar.isTranslucent = false
    }
    
    // This method makes decisions based on the top (or most recently presented) view controller
    // to figure out how to present self correctly
    func presentSelf(sender: Any?) {
        AppDelegate.topViewController.show(self, sender: sender)
    }
}
