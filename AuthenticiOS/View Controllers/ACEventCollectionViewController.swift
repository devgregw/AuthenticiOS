//
//  ACEventCollectionViewController.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 6/19/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "accvcell"

class ACEventCollectionViewController: UICollectionViewController {
    static public var title = "UPCOMING EVENTS"
    
    private var eventsRef: DatabaseReference!
    
    static func present(withTitle: String) {
        title = withTitle
        StoryboardHelper.instantiateEventCollectionViewController().presentSelf(sender: nil)
    }
    
    static func present(withAppearance app: ACAppearance.Events) {
        present(withTitle: app.title)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setupRefreshControl(selector: #selector(self.refreshData))
    }
    
    private func configureCollectionView() {
        collectionView?.indicatorStyle = .default
        collectionView?.register(UINib(nibName: "ACCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        collectionView?.register(UINib(nibName: "ACTextCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "none")
        setupRefreshControl(selector: #selector(self.refreshData))
        collectionView?.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyDefaultAppearance()
        self.title = ACEventCollectionViewController.title
        self.navigationItem.title = ACEventCollectionViewController.title
        self.tabBarItem.title = "EVENTS"
        self.navigationController?.navigationBar.titleTextAttributes = [
            //.kern: 3.5,
            .font: UIFont(name: "Alpenglow-ExpandedRegular", size: 19)!,
            .foregroundColor: UIColor.white
        ]
        configureCollectionView()
        self.loadData(wasRefreshed: false)
    }
    
    private var complete = false
    private var events: [ACEvent] = []
    private var trace: Trace!
    
    @objc public func refreshData() {
        //(tabBarController as? ACTabBarViewController)?.loadData(first: false)
        loadData(wasRefreshed: true)
    }
    
    private func onEventChange(_ snapshot: DataSnapshot) {
        let val = snapshot.value as? NSDictionary
        var placeholders = [ACEventPlaceholder]()
        var regularEvents = [ACEvent]()
        val?.forEach({(key, value) in
            let dict = value as! NSDictionary
            if (dict.allKeys.contains(where: { (key) -> Bool in
                String(describing: key) == "index"
            })) {
                let placeholder = ACEventPlaceholder(dict: dict)
                if (placeholder.isVisible()) {
                    placeholders.append(placeholder)
                }
            } else {
                let event = ACEvent(dict: dict)
                if (event.isVisible()) {
                    regularEvents.append(event)
                }
            }
        })
        placeholders.sort(by: { (a, b) in a.index < b.index })
        regularEvents.sort(by: { (a, b) in a.getNextOccurrence().startDate < b.getNextOccurrence().startDate })
        self.events.removeAll()
        self.events.append(contentsOf: placeholders)
        self.events.append(contentsOf: regularEvents)
        self.complete = true
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(125), execute: {
            self.collectionView?.reloadSections(IndexSet(arrayLiteral: 0))
            self.collectionView?.collectionViewLayout.invalidateLayout()
            self.collectionView?.invalidateIntrinsicContentSize()
            self.collectionView?.refreshControl?.endRefreshing()
            self.trace?.stop()
        })
    }
    
    public func loadData(wasRefreshed: Bool) {
        self.events = []
        self.complete = false
        self.collectionView?.reloadSections(IndexSet(arrayLiteral: 0))
        trace = Performance.startTrace(name: "load events")
        if wasRefreshed {
            trace?.incrementMetric("refresh events", by: 1)
        }
        if eventsRef != nil {
            eventsRef.removeAllObservers()
        }
        eventsRef = Database.database().reference()
        if AppDelegate.useDevelopmentDatabase {
            eventsRef = eventsRef.child("dev")
        }
        eventsRef = eventsRef.child("events")
        
        eventsRef.observeSingleEvent(of: .value, with: self.onEventChange, withCancel: {error in
            self.present(UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert), animated: true)
            self.trace?.stop()
        })
    }

}

extension ACEventCollectionViewController : UICollectionViewDelegateFlowLayout {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.complete ? max(1, self.events.count) : 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 && self.events.count == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "none", for: indexPath) as! ACTextCollectionViewCell
            cell.setText("There are no upcoming events.")
            cell.layoutIfNeeded()
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ACCollectionViewCell
        cell.initialize(forEvent: self.events[indexPath.item], withViewController: self)
        cell.layoutIfNeeded()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item == 0 && self.events.count == 0 {
            return CGSize(width: view.frame.width, height: view.frame.width / 3)
        }
        guard indexPath.item < self.events.count else {
            return CGSize.zero
        }
        let event = self.events[indexPath.item]
        let adjustedWidth = CGFloat(view.frame.width)
        let ratio = CGFloat(event.header.width) / CGFloat(event.header.height == 0 ? 1 : event.header.height)
        let adjustedHeight = adjustedWidth / ratio
        return CGSize(width: adjustedWidth, height: adjustedHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}
