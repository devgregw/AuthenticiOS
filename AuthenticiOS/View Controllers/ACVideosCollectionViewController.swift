//
//  SermonsCollectionViewController.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 10/5/19.
//  Copyright © 2019 Greg Whatley. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "ACTileCollectionViewCell"

class ACVideosCollectionViewController: UICollectionViewController {
    var latestVideoProvider: String!
    var latestVideoId: String!
    var latestVideoImage: String!
    var watchTab: ACTab!
    var playlistTabs: [ACTab]!
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setupRefreshControl(selector: #selector(self.refreshData))
    }
    
    @objc private func refreshData() {
        if !(collectionView.refreshControl?.isRefreshing ?? false) {
            collectionView.refreshControl?.beginRefreshing()
        }
        playlistTabs?.removeAll()
        self.collectionView.reloadSections(IndexSet(arrayLiteral: 0))
        DatabaseHelper.loadAllTabs(keepSynced: true, completion: {result in
            self.watchTab = result.first(where: {t in t.id == "OPQ26R4SRP"})!
            self.playlistTabs = self.watchTab.elements.map({element in (element.type == "tile" ? ACButtonAction(dict: element.getProperty("action") as! NSDictionary) : ACButtonInfo(dict: element.getProperty("_buttonInfo") as! NSDictionary).action).getProperty(withName: "tabId") as! String}).map({id in result.first(where: {t in t.id == id})!})
            let videoInfo = self.playlistTabs.first(where: {t in !t.title.lowercased().contains("worship")})!.elements[0].getProperty("videoInfo") as! NSDictionary
            self.latestVideoImage = (videoInfo.object(forKey: "thumbnail") as! String)
            self.latestVideoProvider = (videoInfo.object(forKey: "provider") as! String)
            self.latestVideoId = (videoInfo.object(forKey: "id") as! String)
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(125), execute: {
                self.collectionView.refreshControl?.endRefreshing()
                self.collectionView.reloadSections(IndexSet(arrayLiteral: 0))
            })
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView!.indicatorStyle = .default
        self.collectionView!.register(UINib(nibName: "ACTileCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.collectionViewLayout = UICollectionViewFlowLayout()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.collectionViewLayout.invalidateLayout()
        refreshData()
        setupRefreshControl(selector: #selector(self.refreshData))
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let count = playlistTabs?.count else {return 0}
        guard count > 0 else {return 0}
        return 1 + count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ACTileCollectionViewCell
        if indexPath.item == 0 {
            cell.initialize(imageResource: ACImageResource(imageName: self.latestVideoImage, width: 1920, height: 1080), width: collectionView.frame.width, action: {
                StoryboardHelper.instantiateVideoViewController(with: self.latestVideoProvider, id: self.latestVideoId).presentSelf(sender: nil)
            })
        } else {
            let index = indexPath.item - 1
            cell.initialize(imageResource: playlistTabs[index].header, width: (collectionView.frame.width / 2) - 5, action: {
                ACButtonAction(type: "OpenTabAction", paramGroup: 1, params: ["tabId": self.playlistTabs[index].id]).invoke(viewController: self, origin: "watch/playlist", medium: "collectionView")
            })
        }
        return cell
    }

}

extension ACVideosCollectionViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item == 0 {
            return CGSize(width: collectionView.frame.width, height: ACImageResource(imageName: "", width: 1920, height: 1080).calculateHeight(fromWidth: collectionView.frame.width))
        } else {
            return CGSize(width: (collectionView.frame.width / 2) - 5, height: ACImageResource(imageName: "", width: 1920, height: 1080).calculateHeight(fromWidth: (collectionView.frame.width / 2) - 5))
        }
    }
}
