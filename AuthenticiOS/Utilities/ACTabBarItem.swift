//
//  ACTabBarItem.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 12/9/19.
//  Copyright © 2019 Greg Whatley. All rights reserved.
//

import Foundation
import UIKit

class ACTabBarItem {
    static public func map(from items: [ACTabBarItem], _ nav: UINavigationController) -> [UIViewController] {
        if items.count > 5 {
            var controllers: [UIViewController] = []
            controllers.append(contentsOf: items.prefix(4).map({i in i.viewController}))
            controllers.append(StoryboardHelper.instantiateMoreTableViewController(with: Array(items.suffix(from: 4)), navigationController: nav))
            return controllers
        } else {
            return items.map({i in i.viewController})
        }
    }
    
    let viewController: UIViewController
    let id: String
    let index: Int
    let title: String
    let action: ACButtonAction?
    
    init(with vc: UIViewController, id: String, index: Int, title: String, action: ACButtonAction?) {
        self.viewController = vc
        self.id = id
        self.index = index
        self.title = title
        self.action = action
    }
}
