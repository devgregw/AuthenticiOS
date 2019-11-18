//
//  ACMoreTableViewController.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 10/27/19.
//  Copyright © 2019 Greg Whatley. All rights reserved.
//

import UIKit

class ACMoreTableViewController: UITableViewController {
    public var tabs: [ACTab]!
    public var nav: UINavigationController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "moreCell")
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tabs?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let t = self.tabs[indexPath.item]
        if let action = t.action {
            action.invoke(viewController: nav, origin: "/tabs/\(t.id)", medium: "more")
            return
        }
        nav.show(ACTabViewController.instantiateViewController(for: t), sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let t = self.tabs[indexPath.item]
        let cell = tableView.dequeueReusableCell(withIdentifier: "moreCell")!
        cell.selectionStyle = .none
        let vc = StoryboardHelper.instantiateTabViewController(with: t)
        vc.tabBarItem.title = t.title
        cell.textLabel?.font = UIFont(name: "Alpenglow-ExpandedRegular", size: UIFont.labelFontSize - 2)!
        cell.textLabel?.text = self.tabs[indexPath.item].title
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}
