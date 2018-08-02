//
//  UIViewController.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 8/1/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import UIKit

extension UIViewController {
    func applyDefaultSettings() {
        let btn = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        btn.tintColor = UIColor.white
        navigationItem.backBarButtonItem = btn
        navigationController?.navigationBar.barTintColor = UIColor.black
        navigationController?.navigationBar.isTranslucent = false
    }
}
