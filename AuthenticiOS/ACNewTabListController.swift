//
//  ACNewTabListController.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 4/25/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ACNewTabListController: UITableViewController {
    @IBAction func didRequestClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func showMoreOptions(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "About This App", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: nil))
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        alert.preferredAction = cancel
        self.present(alert, animated: true, completion: nil)
    }
    
    private var appearance: AuthenticAppearance?
    private var complete = false
    private var tabs: [AuthenticTab] = []
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.complete ? max(2, tabs.count + 1) : 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ACTableViewCell", for: indexPath) as! ACTableViewCell
        if (indexPath.section == 0) {
            cell.initializeForUpcomingEvents(withAppearance: self.appearance!.events, viewController: self)
        } else {
            let tab = tabs[indexPath.section - 1]
            cell.initialize(withTab: tab, viewController: self)
        }
        return cell
    }
    
    @objc public func loadData() {
        self.tabs = []
        self.complete = false
        //self.tableView.reloadData()
        let appRef = Database.database().reference().child("appearance")
        appRef.keepSynced(true)
        appRef.observeSingleEvent(of: .value, with: { appearanceSnapshot in
            self.appearance = AuthenticAppearance(dict: appearanceSnapshot.value as! NSDictionary)
            let tabsRef = Database.database().reference().child("tabs")
            tabsRef.keepSynced(true)
            tabsRef.observeSingleEvent(of: .value, with: {snapshot in
                let val = snapshot.value as? NSDictionary
                val?.forEach({(key, value) in
                    let tab = AuthenticTab(dict: value as! NSDictionary)
                    if (!tab.getShouldBeHidden()) {
                        self.tabs.append(tab)
                    }
                    self.tabs.sort(by: { (a, b) in a.index < b.index })
                    self.complete = true
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                    var shortcuts = [UIApplicationShortcutItem]()
                    shortcuts.append(UIMutableApplicationShortcutItem(type: "upcoming_events", localizedTitle: "Upcoming Events", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .date), userInfo: nil))
                    self.tabs.prefix(4).forEach({ t in
                        shortcuts.append(UIMutableApplicationShortcutItem(type: "tab", localizedTitle: t.title.localizedCapitalized, localizedSubtitle: nil, icon: nil, userInfo: ["id": t.id]))
                    })
                    UIApplication.shared.shortcutItems = shortcuts
                })
            }) { error in self.present(UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert), animated: true) }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Utilities.applyTintColor(to: self)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Home", style: .plain, target: nil, action: nil)
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 220
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.register(UINib(nibName: "ACTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "ACTableViewCell")
        self.refreshControl?.tintColor = UIColor.white
        self.refreshControl?.addTarget(self, action: #selector(self.loadData), for: .valueChanged)
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to Refresh", attributes: [.font: UIFont(name: "Proxima Nova", size: 12.0)!, .foregroundColor: UIColor.white])
        self.loadData()
    }
}
