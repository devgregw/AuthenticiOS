//
//  ViewController.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 12/28/17.
//  Copyright © 2017 Greg Whatley. All rights reserved.
//

import UIKit
import Firebase

class ACHomeViewController: UIViewController {
    
    @IBOutlet weak var constraint: NSLayoutConstraint!
    @IBOutlet weak var button: UIButton!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.button.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseInOut, animations: {
            self.constraint.constant = 75
            self.view.layoutIfNeeded()
        }) { b in
            UIView.animate(withDuration: 0.25, animations: {
                self.button.alpha = 1
            })
        }
    }
}

class ACTableViewController: UIViewController, UITableViewDataSource {
    
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
    
    private var tabs: [AuthenticTab] = []
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tabs.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ACTableViewCell", for: indexPath) as! ACTableViewCell
        let tab = tabs[indexPath.section]
        cell.initialize(withTab: tab, viewController: self)
        return cell
    }
    
    private func loadData() {
        if (self.tabs.count == 0) {
            indicatorView.startAnimating()
            Database.database().reference().child("tabs").observeSingleEvent(of: .value, with: {snapshot in
                let val = snapshot.value as? NSDictionary
                val?.forEach({(key, value) in
                    let tab = value as! NSDictionary
                    self.tabs.append(AuthenticTab(dict: tab))
                    self.tabs.sort(by: { (a, b) in a.index < b.index })
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
        NotificationCenter.default.addObserver(forName: .UIDeviceOrientationDidChange, object: nil, queue: .main, using: { notification in self.tableView.reloadData() })
        self.loadData()
    }
}
