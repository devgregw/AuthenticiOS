//
//  ACTabCollectionCollectionViewController.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 5/25/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "accvcell"
private let livestreamReuseIdentifier = "accvlscell"

class ACTabCollectionViewController: UICollectionViewController {
    @IBAction func didRequestClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        ACHomePageViewController.returnToFirstViewController()
    }
    
    @IBAction func showMoreOptions(_ sender: UIBarButtonItem) {
        self.show(ACAboutViewController(), sender: self)
        /*let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "About This App", style: .default, handler: {a in self.show(ACAboutViewController(), sender: self)}))
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: {a in AuthenticButtonAction(type: "OpenURLAction", paramGroup: 0, params: ["url": UIApplicationOpenSettingsURLString]).invoke(viewController: self)}))
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        alert.preferredAction = cancel
        self.present(alert, animated: true, completion: nil)*/
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let btn = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        btn.tintColor = UIColor.white
        self.navigationItem.backBarButtonItem = btn
        Utilities.applyTintColor(to: self)
        self.collectionView!.register(UINib(nibName: "ACCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.register(UINib(nibName: "ACLivestreamCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: livestreamReuseIdentifier)
        collectionView?.collectionViewLayout = ACCollectionViewLayout(columns: 2, delegate: self)
        self.navigationController?.navigationBar.titleTextAttributes = [
            .kern: 3.5,
            .font: UIFont(name: "Effra", size: 21)!,
            .foregroundColor: UIColor.white
        ]
        self.collectionView?.refreshControl = UIRefreshControl()
        self.collectionView?.refreshControl?.attributedTitle = NSAttributedString(string: "PULL TO REFRESH", attributes: [
            .kern: 2.5,
            .font: UIFont(name: "Effra", size: 14)!,
            .foregroundColor: UIColor.black
            ])
        self.collectionView?.refreshControl?.tintColor = UIColor.black
        self.collectionView?.refreshControl?.addTarget(self, action: #selector(self.refreshData), for: .valueChanged)
        self.loadData(wasRefreshed: false)
    }

    private var appearance: AuthenticAppearance?
    private var complete = false
    private var tabs: [AuthenticTab] = []
    
    @objc public func refreshData() {
        loadData(wasRefreshed: true)
    }
    
    public func loadData(wasRefreshed: Bool) {
        self.tabs = []
        self.complete = false
        let trace = Performance.startTrace(name: "load tabs")
        if wasRefreshed {
            trace?.incrementCounter(named: "refresh tabs")
        }
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
                })
                self.tabs.sort(by: { (a, b) in a.index < b.index })
                self.complete = true
                self.collectionView?.reloadData()
                self.collectionView?.collectionViewLayout.invalidateLayout()
                if #available(iOS 10.0, *) {
                    self.collectionView?.refreshControl?.endRefreshing()
                }
                var shortcuts = [UIApplicationShortcutItem]()
                shortcuts.append(UIMutableApplicationShortcutItem(type: "upcoming_events", localizedTitle: "Upcoming Events", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .date), userInfo: nil))
                self.tabs.prefix(4).forEach({ t in
                    shortcuts.append(UIMutableApplicationShortcutItem(type: "tab", localizedTitle: t.title.localizedCapitalized, localizedSubtitle: nil, icon: nil, userInfo: ["id": t.id as NSSecureCoding]))
                })
                UIApplication.shared.shortcutItems = shortcuts
                trace?.stop()
            }) { error in
                self.present(UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert), animated: true)
                trace?.stop()
            }
        })
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.complete ? tabs.count + 2 : 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (indexPath.item == 0) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: livestreamReuseIdentifier, for: indexPath) as! ACLivestreamCollectionViewCell
            cell.initialize(withViewController: self)
            cell.layoutIfNeeded()
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ACCollectionViewCell
        if (indexPath.item == 1) {
            cell.initialize(forUpcomingEvents: self.appearance!.events, withViewController: self)
        } else if !self.tabs.isEmpty {
            cell.initialize(forTab: self.tabs[indexPath.item - 2], withViewController: self)
        }
        cell.layoutIfNeeded()
        return cell
    }

}

extension ACTabCollectionViewController : ACCollectionViewLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, sizeForCellAtIndexPath indexPath: IndexPath) -> CGSize {
        if indexPath.item == 0 {
            return CGSize(width: view.frame.width, height: view.frame.width / 3)
        }
        if indexPath.item == 1 {
            let app = appearance!.events
            let adjustedWidth = view.frame.width / 2
            let ratio = CGFloat(app.header.width) / CGFloat(app.header.height == 0 ? 1 : app.header.height)
            let adjustedHeight = adjustedWidth / ratio
            return CGSize(width: adjustedWidth, height: adjustedHeight)
        }
        guard !self.tabs.isEmpty else {
            return CGSize.zero
        }
        let tab = self.tabs[indexPath.item - 2]
        let adjustedWidth = view.frame.width / 2
        let ratio = CGFloat(tab.header.width) / CGFloat(tab.header.height == 0 ? 1 : tab.header.height)
        let adjustedHeight = adjustedWidth / ratio
        return CGSize(width: adjustedWidth, height: adjustedHeight)
    }
}
