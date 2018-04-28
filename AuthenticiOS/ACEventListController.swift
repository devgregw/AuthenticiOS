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

class ACEventListController: UIViewController, UITableViewDataSource {
    
    static private var title = ""
    
    static func present(withAppearance app: AuthenticAppearance.Events, viewController: UIViewController) {
        title = app.title
        viewController.present(UIStoryboard(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "ueroot"), animated: true)
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    @IBAction func didRequestClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didRequestRefresh(_ sender: Any) {
        self.events = []
        self.tableView.reloadData()
        self.loadData()
    }
    
    private var events: [AuthenticEvent] = []
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return max(1, events.count)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (events.count == 0) {
            let c = UITableViewCell(style: .default, reuseIdentifier: nil)
            c.textLabel?.text = "There are no upcoming events."
            c.textLabel?.font = UIFont(name: "Proxima Nova", size: 18.0)
            c.textLabel?.textAlignment = .center
            return c
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "ACTableViewCell", for: indexPath) as! ACTableViewCell
        let event = events[indexPath.section]
        cell.initialize(withEvent: event, viewController: self)
        return cell
    }
    
    private func loadData() {
        if (self.events.count == 0) {
            indicatorView.startAnimating()
            Database.database().reference().child("events").observeSingleEvent(of: .value, with: {snapshot in
                let val = snapshot.value as? NSDictionary
                val?.forEach({(key, value) in
                    let event = AuthenticEvent(dict: value as! NSDictionary)
                    if (!event.getShouldBeHidden()) {
                        self.events.append(event)
                    }
                    self.events.sort(by: { (a, b) in a.getNextOccurrence()!.startDate < b.getNextOccurrence()!.startDate })
                    self.tableView.reloadData()
                    self.indicatorView.stopAnimating()
                })
            }) { error in self.present(UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert), animated: true) }
        } else {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = ACEventListController.title
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

