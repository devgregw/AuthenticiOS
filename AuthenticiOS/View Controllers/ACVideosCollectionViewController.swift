//
//  SermonsCollectionViewController.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 10/5/19.
//  Copyright © 2019 Greg Whatley. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class ACVideosCollectionViewController: UICollectionViewController {
    var mainTab: ACTab!
    var playlistTabs: [ACTab]!
    var playlistImages: [ACImageResource] = []
    var playlistIds: [String] = []
    var latestImage: ACImageResource!
    var latestVideo: String!

    
    public func initialize(main: ACTab, playlists: [ACTab]) {
        self.mainTab = main
        self.playlistTabs = playlists
        mainTab.elements.forEach({element in
            playlistImages.append(ACImageResource(dict: element.type == "tile" ? element.getProperty("header") as! NSDictionary : element.getProperty("thumbnail") as! NSDictionary))
            playlistIds.append((element.type == "tile" ? ACButtonAction(dict: element.getProperty("action") as! NSDictionary) : ACButtonInfo(dict: element.getProperty("_buttonInfo") as! NSDictionary).action).getProperty(withName: "tabId") as! String)
        })
        let latestVideoElement = playlistTabs.first(where: {tab in tab.id == playlistIds[1]})!.elements[0]
        let videoInfo = latestVideoElement.getProperty("videoInfo") as! NSDictionary
        latestImage = ACImageResource(imageName: videoInfo.object(forKey: "thumbnail") as! String, width: 1920, height: 1080)
        latestVideo = videoInfo.object(forKey: "provider") as! String + "\\" + (videoInfo.object(forKey: "id") as! String)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        // Register cell classes
        self.collectionView!.indicatorStyle = .default
        self.collectionView!.register(UINib(nibName: "ACTileCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: reuseIdentifier)
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: 1, height: 1)
        self.collectionView!.collectionViewLayout = layout
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.reloadData()
        self.collectionView.collectionViewLayout.invalidateLayout()
        // Do any additional setup after loading the view.
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1 + mainTab.elements.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ACTileCollectionViewCell
        if indexPath.item == 0 {
            cell.initialize(imageResource: latestImage, width: collectionView.frame.width, action: {
                let split = self.latestVideo.split(separator: "\\")
                StoryboardHelper.instantiateVideoViewController(with: String(split[0]), id: String(split[1])).presentSelf(sender: nil)
            })
        } else {
            let index = indexPath.item - 1
            cell.initialize(imageResource: playlistImages[index], width: (collectionView.frame.width / 2) - 5, action: {
                ACButtonAction(type: "OpenTabAction", paramGroup: 1, params: ["tabId": self.playlistIds[index]]).invoke(viewController: self, origin: "watch/playlist", medium: "collectionView")
            })
        }
        return cell
    }

}

extension ACVideosCollectionViewController: UICollectionViewDelegateFlowLayout {
    /*func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let template = ACImageResource(imageName: "", width: 1920, height: 1080)
        if indexPath.item == 0 {
            print("latest video tile \(indexPath.item) \(collectionView.frame.width) \(template.calculateHeight(fromWidth: collectionView.frame.width - 20) + 20)")
            return CGSize(width: collectionView.frame.width, height: template.calculateHeight(fromWidth: collectionView.frame.width - 20) + 20)
        } else {
            let width = (collectionView.frame.width / 2) - 5
            print("playlist tile \(indexPath.item) \(width) \(template.calculateHeight(fromWidth: width - 20) + 20)")
            return CGSize(width: width, height: template.calculateHeight(fromWidth: width - 20) + 20)
        }
    }*/
}
