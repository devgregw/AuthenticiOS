//
//  UIViewController.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 8/1/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import UIKit

enum ACRefreshControlStyle {
    case automatic
    case light
    case dark
}

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
    
    func setupRefreshControl(for scroll: UIScrollView, selector: Selector, style: ACRefreshControlStyle = .automatic) {
        var color: UIColor
        if style == .automatic {
            if #available(iOS 13.0, *) {
                color = traitCollection.userInterfaceStyle == .dark ? .white : .black
            } else {
                color = .white
            }
        } else {
            color = style == .light ? .white : .black
        }
        if scroll.refreshControl == nil {
            scroll.refreshControl = UIRefreshControl()
        }
        scroll.refreshControl?.tintColor = color
        scroll.refreshControl?.addTarget(self, action: selector, for: .valueChanged)
        scroll.refreshControl?.attributedTitle = NSAttributedString(string: "PULL TO REFRESH", attributes: [
            //.kern: 2.5,
            .font: UIFont(name: "Alpenglow-ExpandedRegular", size: 12)!,
            .foregroundColor: color
        ])
    }
    
    // This method makes decisions based on the top (or most recently presented) view controller
    // to figure out how to present self correctly
    func presentSelf(sender: Any?) {
        AppDelegate.topViewController.show(self, sender: sender)
    }
}

extension UICollectionViewController {
    func setupRefreshControl(selector: Selector, style: ACRefreshControlStyle = .automatic) {
        setupRefreshControl(for: collectionView, selector: selector, style: style)
    }
}

extension UITableViewController {
    func setupRefreshControl(selector: Selector, style: ACRefreshControlStyle = .automatic) {
        setupRefreshControl(for: tableView, selector: selector, style: style)
    }
}
