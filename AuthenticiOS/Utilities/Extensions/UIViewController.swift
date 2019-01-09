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
        let vc = AppDelegate.topViewController
        // If the most recently displayed (top) view controller is the home page view controller,
        // there's some additional stuff to do
        if let hp = vc as? ACHomePageViewController {
            // Get the index of the currently displayed page
            let index = ACHomePageViewController.controllers.index(of: hp.viewControllers!.first!)
            // If the index is 0, the home page view controller is displaying the logo and up arrow;
            // this view controller doesn't have a navigation controller
            if index == 0 {
                // Instantiate the tabs collection view controller (it is not neccessary to cast it)
                let nvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "hmroot")
                // Present the tabs collection view controller because it has a navigation controller
                vc.present(nvc, animated: true, completion: {
                    // Use the navigation controller to show self
                    nvc.show(self, sender: sender)
                })
            } else {
                // No special handling is needed because the home page view controller is already displaying the
                // tabs collection view controller which has a navigation controller
                hp.viewControllers!.first!.show(self, sender: nil)
            }
        } else {
            // The home page view controller is the only view controller without a navigation controller,
            // so it is safe to assume the top view controller has a navigation controller and can correctly show new view controllers
            vc.show(self, sender: sender)
        }
    }
}
