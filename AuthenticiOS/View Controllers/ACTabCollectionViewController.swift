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

extension UICollectionView {
    override open var safeAreaInsets: UIEdgeInsets {
        return UIEdgeInsets.zero
    }
}

class ACTabCollectionViewController: UICollectionViewController {
    @IBAction func didRequestClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        ACHomePageViewController.returnToFirstViewController()
    }
    
    @IBAction func showMoreOptions(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Development Menu", message: "This menu will not be visible to users.\n\nYour FCM Registration Token is:\n\(Messaging.messaging().fcmToken ?? "<unavailable>")", preferredStyle: .actionSheet)
        alert.popoverPresentationController?.barButtonItem = sender
        alert.addAction(UIAlertAction(title: "Switch to \(AppDelegate.useDevelopmentDatabase ? "Production" : "Development") Database", style: .destructive, handler: {_ in
            AppDelegate.useDevelopmentDatabase = !AppDelegate.useDevelopmentDatabase
            self.loadData(wasRefreshed: true)
        }))
        alert.addAction(UIAlertAction(title: "Share FCM Registration Token", style: .default, handler: {_ in
            let activityController = UIActivityViewController(activityItems: [(Messaging.messaging().fcmToken ?? "<unavailable>") as NSString], applicationActivities: nil)
            activityController.popoverPresentationController?.barButtonItem = sender
            self.present(activityController, animated: true, completion: nil)
        }))
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        alert.preferredAction = cancel
        present(alert, animated: true, completion: nil)
    }
    
    private func configureCollectionView() {
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: collectionView!)
        }
        self.collectionView?.register(UINib(nibName: "ACCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView?.register(UINib(nibName: "ACLivestreamCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: livestreamReuseIdentifier)
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if AppDelegate.appMode == AppMode.Production {
            self.navigationItem.rightBarButtonItem = nil
        }
        applyDefaultSettings()
        configureCollectionView()
        self.loadData(wasRefreshed: false)
    }
    
    private var appearance: ACAppearance?
    private var complete = false
    private var tabs: [ACTab] = []
    private var appRef: DatabaseReference!
    private var tabsRef: DatabaseReference!
    private var trace: Trace!
    private var actionToPop: ACButtonAction?
    
    @objc public func refreshData() {
        loadData(wasRefreshed: true)
    }
    
    private func listenForAppearanceChange() {
        if appRef != nil {
            appRef.removeAllObservers()
        }
        appRef = Database.database().reference()
        if AppDelegate.useDevelopmentDatabase {
            appRef = appRef.child("dev")
        }
        appRef = appRef.child("appearance")
        appRef.keepSynced(true)
        appRef.observe(.value, with: self.onAppearanceChange) { error in
            self.present(UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert), animated: true)
            self.trace?.stop()
        }
    }
    
    private func listenForTabChange() {
        if tabsRef != nil {
            tabsRef.removeAllObservers()
        }
        tabsRef = Database.database().reference()
        if AppDelegate.useDevelopmentDatabase {
            tabsRef = tabsRef.child("dev")
        }
        tabsRef = tabsRef.child("tabs")
        tabsRef.keepSynced(true)
        tabsRef.observe(.value, with: self.onTabChange) { error in
            self.present(UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert), animated: true)
            self.trace?.stop()
        }
    }
    
    private func onAppearanceChange(_ appearanceSnapshot: DataSnapshot) {
        self.appearance = ACAppearance(dict: appearanceSnapshot.value as! NSDictionary)
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
            self.collectionView?.collectionViewLayout.invalidateLayout()
            self.collectionView?.invalidateIntrinsicContentSize()
        }
    }
    
    private func onTabChange(_ snapshot: DataSnapshot) {
        let val = snapshot.value as? NSDictionary
        self.tabs.removeAll()
        val?.forEach({(key, value) in
            let tab = ACTab(dict: value as! NSDictionary)
            if (tab.isVisible()) {
                self.tabs.append(tab)
            }
        })
        self.tabs.sort(by: { (a, b) in a.index < b.index })
        self.complete = true
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
            self.collectionView?.collectionViewLayout.invalidateLayout()
            self.collectionView?.invalidateIntrinsicContentSize()
            if #available(iOS 10.0, *) {
                self.collectionView?.refreshControl?.endRefreshing()
            }
            var shortcuts = [UIApplicationShortcutItem]()
            shortcuts.append(UIMutableApplicationShortcutItem(type: "upcoming_events", localizedTitle: "Upcoming Events", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .date), userInfo: nil))
            self.tabs.prefix(4).forEach({ t in
                shortcuts.append(UIMutableApplicationShortcutItem(type: "tab", localizedTitle: t.title.localizedCapitalized, localizedSubtitle: nil, icon: nil, userInfo: ["id": t.id as NSSecureCoding]))
            })
            UIApplication.shared.shortcutItems = shortcuts
            self.trace?.stop()
        }
    }
    
    public func loadData(wasRefreshed: Bool) {
        self.tabs = []
        self.complete = false
        self.collectionView?.reloadData()
        trace = Performance.startTrace(name: "load tabs")
        if wasRefreshed {
            trace?.incrementMetric("refresh tabs", by: 1)
        }
        listenForAppearanceChange()
        listenForTabChange()
    }
}

extension ACTabCollectionViewController {
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
            return CGSize(width: view.frame.width, height: ACLivestreamCollectionViewCell.cellHeight)
        }
        let isLeftColumn = indexPath.section == 0
        var tabsInColumn = (isLeftColumn ? self.tabs.filter({t in t.index % 2 == 0}) : self.tabs.filter({t in t.index % 2 > 0})).count
        if !isLeftColumn {
            tabsInColumn += 1
        }
        let fill = (isLeftColumn ? self.appearance!.tabs.fillLeft : self.appearance!.tabs.fillRight) && tabsInColumn <= 4
        let availableHeight = UIScreen.main.bounds.height - UIApplication.shared.statusBarFrame.height - navigationController!.navigationBar.frame.height - ACLivestreamCollectionViewCell.cellHeight
        if indexPath.item == 1 {
            let app = appearance!.events
            if fill {
                return CGSize(width: view.frame.width / 2, height: availableHeight / CGFloat(tabsInColumn))
            }
            let adjustedWidth = view.frame.width / 2
            let ratio = CGFloat(app.header.width) / CGFloat(app.header.height == 0 ? 1 : app.header.height)
            let adjustedHeight = adjustedWidth / ratio
            return CGSize(width: adjustedWidth, height: adjustedHeight)
        }
        guard !self.tabs.isEmpty else {
            return CGSize.zero
        }
        let tab = self.tabs[indexPath.item - 2]
        if fill {
            return CGSize(width: view.frame.width / 2, height: availableHeight / CGFloat(tabsInColumn))
        }
        let adjustedWidth = view.frame.width / 2
        let ratio = CGFloat(tab.header.width) / CGFloat(tab.header.height == 0 ? 1 : tab.header.height)
        let adjustedHeight = adjustedWidth / ratio
        return CGSize(width: adjustedWidth, height: adjustedHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, columnNumberForCellAtIndexPath indexPath: IndexPath) -> Int {
        if indexPath.item == 0 {
            return 0
        }
        if indexPath.item == 1 {
            return 1
        }
        guard indexPath.item - 2 < self.tabs.count else {return 0}
        return self.tabs[indexPath.item - 2].index % 2 == 0 ? 0 : 1
    }
}

extension ACTabCollectionViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        actionToPop = nil
        guard let indexPath = collectionView?.indexPathForItem(at: location) else {return nil}
        guard let cell = collectionView?.cellForItem(at: indexPath) as? ACCollectionViewCell else {return nil}
        guard indexPath.item >= 1 else {return nil}
        if indexPath.item == 1 {
            previewingContext.sourceRect = cell.convert(cell.bounds, to: collectionView!)
            ACEventCollectionViewController.title = appearance?.events.title ?? "UPCOMING EVENTS"
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "evroot")
        } else {
            let tab = self.tabs[indexPath.item - 2]
            previewingContext.sourceRect = cell.convert(cell.bounds, to: collectionView!)
            guard let action = tab.action else {
                return ACTabViewController(tab: tab)
            }
            guard let resultViewController = action.resultViewController else {
                guard let image = cell.image.image else {return nil}
                actionToPop = action
                ACPeekImageViewController.image = image
                ACPeekImageViewController.title = tab.title
                let imageVc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "peek") as! ACPeekImageViewController
                imageVc.preferredContentSize = CGSize(width: 0, height: cell.frame.size.width * 2)
                return imageVc
            }
            return resultViewController
        }
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        guard let action = actionToPop else {
            AppDelegate.automaticPresent(viewController: viewControllerToCommit)
            return
        }
        action.invoke(viewController: self, origin: "pop")
    }
}
