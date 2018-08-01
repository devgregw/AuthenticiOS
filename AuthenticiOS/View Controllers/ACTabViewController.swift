//
//  ACTabViewController.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 1/2/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class ACTabViewController: UIViewController {
    
    @IBOutlet weak var stackView: UIStackView!
    
    private let tab: AuthenticTab?
    
    private var wallpaperManager: ACWallpaperCollectionViewManager!
    
    private func clearViews() {
        guard self.stackView != nil else {
            return
        }
        while (self.stackView.arrangedSubviews.count > 1) {
            self.stackView.removeArrangedSubview(self.stackView.arrangedSubviews[1])
        }
    }
    
    public static func present(tab: AuthenticTab) {
        if tab.action != nil {
            tab.action!.invoke(viewController: AppDelegate.getTopmostViewController())
            return
        }
        AppDelegate.automaticPresent(viewController: ACTabViewController(tab: tab))
    }
    
    class ACWallpaperCollectionViewManager : NSObject, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
        private let elements: [AuthenticElement]
        private let t: AuthenticTab
        
        init(_ elements: [AuthenticElement], _ t: AuthenticTab) {
            self.elements = elements
            self.t = t
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return elements.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "wallpaper", for: indexPath) as! ACImageCollectionViewCell
            cell.setImage(ImageResource(dict: elements[indexPath.item].getProperty("image") as! NSDictionary), viewController: AppDelegate.getTopmostViewController())
            //let image = UIImageView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: collectionView.bounds.width / 2, height: collectionView.bounds.width / 2)))
            //image.contentMode = .scaleAspectFill
            /*image.sd_setImage(with: Storage.storage().reference().child(ImageResource(dict: elements[indexPath.item].getProperty("image") as! NSDictionary).imageName), placeholderImage: nil, completion: { (i, e, c, r) in
                UIView.animate(withDuration: 0.3, animations: {
                    image.alpha = 1
                })
            })
            cell.backgroundColor = UIColor.blue
            cell.subviews.forEach {v in v.removeFromSuperview()}
            cell.addSubview(image)
            cell.addConstraints([
                NSLayoutConstraint(item: image, attribute: .leading, relatedBy: .equal, toItem: cell, attribute: .leading, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: image, attribute: .trailing, relatedBy: .equal, toItem: cell, attribute: .trailing, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: image, attribute: .top, relatedBy: .equal, toItem: cell, attribute: .top, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: image, attribute: .bottom, relatedBy: .equal, toItem: cell, attribute: .bottom, multiplier: 1, constant: 0)
            ])*/
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
    
    private func initLayout(forSpecialType specialType: String) {
        switch (specialType) {
        case "wallpapers":
            view.subviews.forEach { v in
                v.removeFromSuperview()
            }
            let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: UICollectionViewFlowLayout())
            collectionView.backgroundColor = UIColor.white
            collectionView.register(UINib(nibName: "ACImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "wallpaper")
            wallpaperManager = ACWallpaperCollectionViewManager(self.tab!.elements, tab!)
            collectionView.dataSource = wallpaperManager
            collectionView.delegate = wallpaperManager
            view = collectionView
            collectionView.reloadData()
            collectionView.collectionViewLayout.invalidateLayout()
            collectionView.layoutSubviews()
        default: return
        }
    }
    
    private func initLayout() {
        self.clearViews()
        if (!self.tab!.hideHeader) {
            let i = UIImageView()
            i.contentMode = .scaleAspectFit
            Utilities.loadFirebase(image: self.tab!.header.imageName, into: i)
            self.stackView.addArrangedSubview(i)
        }
        if (self.tab!.specialType != nil) {
            initLayout(forSpecialType: self.tab!.specialType!)
        } else if (self.tab!.elements.count == 0) {
            let label = UILabel()
            label.textColor = UIColor.black
            label.text = "No content"
            label.textAlignment = .center
            self.stackView.addArrangedSubview(label)
        } else {
            self.tab!.elements.forEach({ element in
                self.stackView.addArrangedSubview(element.getView(viewController: self))
            })
            if !UIDevice.current.isiPhoneX {
                self.stackView.addArrangedSubview(AuthenticElement.createSeparator(visible: false))
            }
        }
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //initLayout()
    }
    
    init(tab: AuthenticTab) {
        self.tab = tab
        super.init(nibName: "ACTabViewController", bundle: Bundle.main)
        self.title = tab.title
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.tab = nil
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyDefaultSettings()
        initLayout()
    }
}
