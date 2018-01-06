//
//  ViewController.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 12/28/17.
//  Copyright © 2017 Greg Whatley. All rights reserved.
//

import UIKit
import Firebase

class AuthenticButtonAction {
    public let type: String
    
    public let paramGroup: Int
    
    private let properties: NSDictionary
    
    public func getProperty(withName name: String) -> Any? {
        return properties[name]
    }
    
    public func invoke(viewController vc: UIViewController) {
        if (self.type == "OpenTabAction") {
            Database.database().reference().child("/tabs/\(self.getProperty(withName: "tabId") as! String)/").observeSingleEvent(of: .value, with: {snapshot in
                let val = snapshot.value as? NSDictionary
                if (val != nil) {
                    ACTabViewController.present(tab: AuthenticTab(dict: val!), withViewController: vc)
                }
            }) { error in vc.present(UIAlertController(title: "Error", message: error.localizedDescription as String, preferredStyle: .alert), animated: true) }
        } else {
            vc.present(UIAlertController(title: "Error", message: "Invalid action", preferredStyle: .alert), animated: true)
        }
    }
    
    init(dict: NSDictionary) {
        self.type = dict.value(forKey: "type") as! String
        self.paramGroup = dict.value(forKey: "group") as! Int
        var k: [NSCopying] = []
        var v: [Any] = []
        dict.filter({(key, value) in return (key as! String) != "type" && (key as! String) != "group" }).forEach({ e in k.append(e.key as! NSCopying); v.append(e.value) })
        self.properties = NSDictionary(objects: v, forKeys: k)
    }
}

class AuthenticButtonInfo {
    public let label: String
    
    public let action: AuthenticButtonAction
    
    init(dict: NSDictionary) {
        self.label = dict.value(forKey: "label") as! String
        self.action = AuthenticButtonAction(dict: dict.value(forKey: "action") as! NSDictionary)
    }
}

class AuthenticBundle {
    public let id: String
    
    public let parentId: String
    
    public let index: Int
    
    public let image: String?
    
    public let title: String?
    
    public let text: String?
    
    public let button: AuthenticButtonInfo?
    
    init(dict: NSDictionary) {
        self.id = dict.value(forKey: "id") as! String
        self.parentId = dict.value(forKey: "parent") as! String
        self.index = dict.value(forKey: "index") as! Int
        self.image = dict.value(forKey: "image") as? String
        self.title = dict.value(forKey: "title") as? String
        self.text = dict.value(forKey: "text") as? String
        let buttonDict = dict.value(forKey: "_buttonInfo") as? NSDictionary
        if (buttonDict != nil) {
            self.button = AuthenticButtonInfo(dict: buttonDict!)
        } else {
            self.button = nil
        }
    }
}

class AuthenticTab {
    public let id: String
    
    public let title: String
    
    public let header: String
    
    public let index: Int
    
    public let bundles: [AuthenticBundle]
    
    init(dict: NSDictionary) {
        self.id = dict.value(forKey: "id") as! String
        self.title = dict.value(forKey: "title") as! String
        self.header = dict.value(forKey: "header") as! String
        self.index = dict.value(forKey: "index") as! Int
        self.bundles = (dict.value(forKey: "bundles") as? [NSDictionary])?.map({(dictionary) in AuthenticBundle(dict: dictionary)}) ?? []
    }
}

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

class ACTableViewController2: UIViewController, UITableViewDataSource {
    
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
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Authentic", style: .plain, target: nil, action: nil)
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


class ACTableViewController: UITableViewController {
    
    @IBAction func didRequestClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private var tabs: [AuthenticTab] = []
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tabs.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ACTableViewCell", for: indexPath) as! ACTableViewCell
        let tab = tabs[indexPath.section]
        cell.initialize(withTab: tab, viewController: self)
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 220
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(UINib(nibName: "ACTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "ACTableViewCell")
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        self.tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        self.tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        NotificationCenter.default.addObserver(forName: .UIDeviceOrientationDidChange, object: nil, queue: .main, using: { notification in self.tableView.reloadData() })
        if (self.tabs.count == 0) {
            Database.database().reference().child("tabs").queryOrdered(byChild: "index").observeSingleEvent(of: .value, with: {snapshot in
                let val = snapshot.value as? NSDictionary
                val?.forEach({(key, value) in
                    let tab = value as! NSDictionary
                    self.tabs.append(AuthenticTab(dict: tab))
                    self.tableView.reloadData()
                })
            }) { error in self.present(UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert), animated: true) }
        } else {
            self.tableView.reloadData()
        }
    }
}
