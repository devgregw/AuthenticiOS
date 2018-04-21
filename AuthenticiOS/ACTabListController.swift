//
//  ACTabListController.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 4/16/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ACTabListController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    @IBAction func didRequestClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didRequestRefresh(_ sender: Any) {
        self.tabs = []
        self.tableView.reloadData()
        self.loadData()
    }
    
    private var appearance: AuthenticAppearance?
    private var complete = false
    private var tabs: [AuthenticTab] = []
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.complete ? tabs.count + 1 : 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ACTableViewCell", for: indexPath) as! ACTableViewCell
        if (indexPath.section == 0) {
            cell.initializeForUpcomingEvents(withAppearance: self.appearance!.events, viewController: self)
        } else {
            let tab = tabs[indexPath.section - 1]
            cell.initialize(withTab: tab, viewController: self)
        }
        return cell
    }
    
    private func loadData() {
        if (self.tabs.count == 0) {
            indicatorView.startAnimating()
            Database.database().reference().child("appearance").observeSingleEvent(of: .value, with: { appearanceSnapshot in
                self.appearance = AuthenticAppearance(dict: appearanceSnapshot.value as! NSDictionary)
                Database.database().reference().child("tabs").observeSingleEvent(of: .value, with: {snapshot in
                    let val = snapshot.value as? NSDictionary
                    val?.forEach({(key, value) in
                        let tab = AuthenticTab(dict: value as! NSDictionary)
                        if (!tab.getShouldBeHidden()) {
                            self.tabs.append(tab)
                        }
                        self.tabs.sort(by: { (a, b) in a.index < b.index })
                        self.complete = true
                        self.tableView.reloadData()
                        self.indicatorView.stopAnimating()
                    })
                }) { error in self.present(UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert), animated: true) }
            })
        } else {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Utilities.applyTintColor(to: self)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 220
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.register(UINib(nibName: "ACTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "ACTableViewCell")
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        self.tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        self.tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        self.loadData()
    }
}
