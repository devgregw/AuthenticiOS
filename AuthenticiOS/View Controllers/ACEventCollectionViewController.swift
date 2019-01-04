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
    
    static public var title = ""
    
    private var eventsRef: DatabaseReference!
    
    static func present(withTitle: String) {
        title = withTitle
        AppDelegate.automaticPresent(viewController: UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "evroot"))
    }
    
    static func present(withAppearance app: ACAppearance.Events) {
        present(withTitle: app.title)
    }
    
    private func configureCollectionView() {
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: collectionView!)
        }
        collectionView?.register(UINib(nibName: "ACCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        collectionView?.register(UINib(nibName: "ACTextCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "none")
        self.collectionView?.refreshControl = UIRefreshControl()
        self.collectionView?.refreshControl?.attributedTitle = NSAttributedString(string: "PULL TO REFRESH", attributes: [
            .kern: 2.5,
            .font: UIFont(name: "Effra", size: 14)!,
            .foregroundColor: UIColor.black
            ])
        self.collectionView?.refreshControl?.tintColor = UIColor.black
        self.collectionView?.refreshControl?.addTarget(self, action: #selector(self.refreshData), for: .valueChanged)
        collectionView?.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyDefaultSettings()
        self.navigationItem.title = ACEventCollectionViewController.title
        self.navigationController?.navigationBar.titleTextAttributes = [
            .kern: 3.5,
            .font: UIFont(name: "Effra", size: 21)!,
            .foregroundColor: UIColor.white
        ]
        configureCollectionView()
        self.loadData(wasRefreshed: false)
    }
    
    private var complete = false
    private var events: [ACEvent] = []
    private var trace: Trace!
    private var actionToPop: ACButtonAction?
    
    @objc public func refreshData() {
        loadData(wasRefreshed: true)
    }
    
    private func listenForEventChange() {
        if eventsRef != nil {
            eventsRef.removeAllObservers()
        }
        eventsRef = Database.database().reference()
        if AppDelegate.useDevelopmentDatabase {
            eventsRef = eventsRef.child("dev")
        }
        eventsRef = eventsRef.child("events")
        eventsRef.observe(.value, with: self.onEventChange) { error in
            self.present(UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert), animated: true)
            self.trace?.stop()
        }
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
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
            self.collectionView?.collectionViewLayout.invalidateLayout()
            self.collectionView?.invalidateIntrinsicContentSize()
            if #available(iOS 10.0, *) {
                self.collectionView?.refreshControl?.endRefreshing()
            }
            self.trace?.stop()
        }
    }
    
    public func loadData(wasRefreshed: Bool) {
        self.events = []
        self.complete = false
        self.collectionView?.reloadData()
        trace = Performance.startTrace(name: "load events")
        if wasRefreshed {
            trace?.incrementMetric("refresh events", by: 1)
        }
        listenForEventChange()
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

extension ACEventCollectionViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        actionToPop = nil
        guard let indexPath = collectionView?.indexPathForItem(at: location) else {return nil}
        guard let cell = collectionView?.cellForItem(at: indexPath) as? ACCollectionViewCell else {return nil}
        let event = self.events[indexPath.item]
        previewingContext.sourceRect = cell.convert(cell.bounds, to: collectionView!)
        if let placeholder = event as? ACEventPlaceholder {
            guard let action = placeholder.action else {
                return ACEventViewController(event: placeholder)
            }
            guard let resultViewController = action.resultViewController else {
                guard let image = cell.image.image else {return nil}
                actionToPop = action
                ACPeekImageViewController.image = image
                ACPeekImageViewController.title = placeholder.title
                let imageVc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "peek") as! ACPeekImageViewController
                imageVc.preferredContentSize = cell.frame.size
                return imageVc
            }
            return resultViewController
        } else {
            return ACEventViewController(event: event)
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
