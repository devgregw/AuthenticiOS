//
//  ACEventListController.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 4/16/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ACEventListController: UITableViewController {
    
    static private var title = ""
    
    static func present(withAppearance app: AuthenticAppearance.Events, viewController: UIViewController) {
        title = app.title
        viewController.present(UIStoryboard(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "ueroot"), animated: true)
    }
    
    @IBAction func didRequestClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private var events: [AuthenticEvent] = []
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return max(1, events.count)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (events.count == 0) {
            let c = UITableViewCell(style: .default, reuseIdentifier: nil)
            c.textLabel?.text = "There are no upcoming events."
            c.textLabel?.font = UIFont(name: "Proxima Nova", size: 18.0)
            c.textLabel?.textAlignment = .center
            c.backgroundColor = UIColor.clear
            return c
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "ACTableViewCell", for: indexPath) as! ACTableViewCell
        let event = events[indexPath.section]
        cell.initialize(withEvent: event, viewController: self)
        return cell
    }
    
    @objc public func loadData() {
        self.events = []
        let eventsRef = Database.database().reference().child("events")
        eventsRef.keepSynced(true)
            eventsRef.observeSingleEvent(of: .value, with: {snapshot in
                let val = snapshot.value as? NSDictionary
                val?.forEach({(key, value) in
                    let event = AuthenticEvent(dict: value as! NSDictionary)
                    if (!event.getShouldBeHidden()) {
                        self.events.append(event)
                    }
                    self.events.sort(by: { (a, b) in a.getNextOccurrence().startDate < b.getNextOccurrence().startDate })
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                })
            }) { error in self.present(UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert), animated: true) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = ACEventListController.title
        Utilities.applyTintColor(to: self)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Events", style: .plain, target: nil, action: nil)
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 220
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.register(UINib(nibName: "ACTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "ACTableViewCell")
        self.refreshControl?.tintColor = UIColor.white
        self.refreshControl?.addTarget(self, action: #selector(self.loadData), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Utilities.applyTintColor(to: self)
        self.loadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
