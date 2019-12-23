//
//  ACWallpaperCollectionViewController.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 1/14/19.
//  Copyright © 2019 Greg Whatley. All rights reserved.
//

import UIKit

private let reuseIdentifier = "ACImageCollectionViewCell"

class ACWallpaperCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    var wallpapers: [ACImageResource]!
    
    public func initialize() {
        self.title = "Wallpapers"
        self.tabBarItem.title = "WALLPAPERS"
        applyDefaultAppearance()
    }
    
    @objc public func refreshData() {
        wallpapers?.removeAll()
        if !(collectionView.refreshControl?.isRefreshing ?? false) {
            collectionView.refreshControl?.beginRefreshing()
        }
        collectionView.reloadSections(IndexSet(arrayLiteral: 0))
        DatabaseHelper.loadTab(id: "ME6HV83IM0", keepSynced: false, completion: {result in
            guard let tab = result else {return}
            self.wallpapers = tab.elements.filter({element in element.type == "image"}).map({element in ACImageResource(dict: element.getProperty("image") as! NSDictionary)})
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(125), execute: {
                self.collectionView.reloadSections(IndexSet(arrayLiteral: 0))
                self.collectionView.refreshControl?.endRefreshing()
            })
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.indicatorStyle = .black
        collectionView?.register(UINib(nibName: "ACImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.reloadData()
        collectionView?.collectionViewLayout.invalidateLayout()
        refreshData()
        setupRefreshControl(selector: #selector(self.refreshData))
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wallpapers?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ACImageCollectionViewCell
        cell.setImage(wallpapers[indexPath.item], viewController: AppDelegate.topViewController)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.bounds.width / 2
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

}
