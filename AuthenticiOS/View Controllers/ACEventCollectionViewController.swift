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
    
    static func present(withAppearance app: AuthenticAppearance.Events) {
        title = app.title
        AppDelegate.getTopmostViewController().present(UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "evroot"), animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = ACEventCollectionViewController.title
        self.collectionView!.register(UINib(nibName: "ACCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.delegate = self
        let btn = UIBarButtonItem(title: "Home", style: .plain, target: nil, action: nil)
        btn.tintColor = UIColor.white
        self.navigationItem.backBarButtonItem = btn
        Utilities.applyTintColor(to: self)
        self.collectionView!.register(UINib(nibName: "ACCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: reuseIdentifier)
        if #available(iOS 10.0, *) {
            self.collectionView?.refreshControl = UIRefreshControl()
            self.collectionView?.refreshControl?.attributedTitle = NSAttributedString(string: "PULL TO REFRESH", attributes: [
                .kern: 1.5,
                .font: UIFont(name: "Effra", size: 14)!,
                .foregroundColor: UIColor.white
                ])
            self.collectionView?.refreshControl?.tintColor = UIColor.white
            self.collectionView?.refreshControl?.addTarget(self, action: #selector(self.loadData), for: .valueChanged)
        }
        self.loadData()
    }
    
    fileprivate var complete = false
    fileprivate var events: [AuthenticEvent] = []
    
    @objc public func loadData() {
        self.events = []
        self.complete = false
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
                    self.complete = true
                    self.collectionView?.reloadData()
                    if #available(iOS 10.0, *) {
                        self.collectionView?.refreshControl?.endRefreshing()
                    }
                })
            }) { error in self.present(UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert), animated: true) }
    }

}

extension ACEventCollectionViewController : UICollectionViewDelegateFlowLayout {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.complete ? self.events.count : 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ACCollectionViewCell
        cell.initialize(forEvent: self.events[indexPath.item], withViewController: self)
        cell.layoutIfNeeded()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard indexPath.item < self.events.count else {
            return CGSize.zero
        }
        let event = self.events[indexPath.item]
        let adjustedWidth = CGFloat(view.frame.width)
        let ratio = CGFloat(event.header.width) / CGFloat(event.header.height)
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
        return 0
    }
}
