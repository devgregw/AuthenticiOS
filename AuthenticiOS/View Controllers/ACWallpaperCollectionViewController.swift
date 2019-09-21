//
//  ACWallpaperCollectionViewController.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 1/14/19.
//  Copyright © 2019 Greg Whatley. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class ACWallpaperCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    private var elements: [ACElement]!
    private var tab: ACTab!
    
    public func initialize(withTab tab: ACTab) {
        self.tab = tab
        self.elements = self.tab.elements.filter({element in element.type == "image"})
        self.title = tab.title
        self.tabBarItem.title = "Wallpapers"
        applyDefaultAppearance()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.indicatorStyle = .black
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(UINib(nibName: "ACImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "wallpaper")
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.reloadData()
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return elements.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "wallpaper", for: indexPath) as! ACImageCollectionViewCell
        cell.setImage(ACImageResource(dict: elements[indexPath.item].getProperty("image") as! NSDictionary), viewController: AppDelegate.topViewController)
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
