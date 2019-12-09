//
//  ACMoreTableViewController.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 10/27/19.
//  Copyright © 2019 Greg Whatley. All rights reserved.
//

import UIKit

class ACMoreTableViewController: UITableViewController {
    public var items: [ACTabBarItem]!
    public var nav: UINavigationController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "moreCell")
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.items[indexPath.item]
        if let action = item.action {
            action.invoke(viewController: nav, origin: "/tabs/\(item.id)", medium: "more")
            return
        }
        nav.show(item.viewController, sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.items[indexPath.item]
        let cell = tableView.dequeueReusableCell(withIdentifier: "moreCell")!
        cell.selectionStyle = .none
        item.viewController.tabBarItem.title = item.title
        cell.textLabel?.font = UIFont(name: "Alpenglow-ExpandedRegular", size: UIFont.labelFontSize - 2)!
        cell.textLabel?.text = item.title
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}
