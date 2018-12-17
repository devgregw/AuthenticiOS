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
    @IBAction public func close(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    static private var title = ""
    
    private var eventsRef: DatabaseReference!
    
    static func present(withTitle: String) {
        title = withTitle
        AppDelegate.automaticPresent(viewController: UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "evroot"))
    }
    
    static func present(withAppearance app: ACAppearance.Events) {
        present(withTitle: app.title)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = ACEventCollectionViewController.title
        self.collectionView!.register(UINib(nibName: "ACCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.register(UINib(nibName: "ACTextCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "none")
        self.collectionView!.delegate = self
        applyDefaultSettings()
        self.collectionView!.register(UINib(nibName: "ACCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: reuseIdentifier)
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
    
    fileprivate var complete = false
    fileprivate var events: [ACEvent] = []
    
    @objc public func refreshData() {
        loadData(wasRefreshed: true)
    }
    
    public func loadData(wasRefreshed: Bool) {
        self.events = []
        self.complete = false
        self.collectionView?.reloadData()
        let trace = Performance.startTrace(name: "load events")
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
        //eventsRef.observeSingleEvent(of: .value, with: {snapshot in
        eventsRef.observe(.value, with: {snapshot in
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
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
                self.collectionView?.collectionViewLayout.invalidateLayout()
                self.collectionView?.invalidateIntrinsicContentSize()
                if #available(iOS 10.0, *) {
                    self.collectionView?.refreshControl?.endRefreshing()
                }
                trace?.stop()
            }
        }) { error in
            self.present(UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert), animated: true)
            trace?.stop()
        }
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
