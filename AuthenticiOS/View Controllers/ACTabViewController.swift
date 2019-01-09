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
    
    private let tab: ACTab?
    
    private var alreadyInitialized = false
    
    private var wallpaperManager: ACWallpaperCollectionViewManager!
    
    private func clearViews() {
        guard self.stackView != nil else {
            return
        }
        while (self.stackView.arrangedSubviews.count > 1) {
            self.stackView.removeArrangedSubview(self.stackView.arrangedSubviews[1])
        }
    }
    
    public static func present(tab: ACTab, origin: String, medium: String) {
        AnalyticsHelper.activatePage(tab: tab, origin: origin, medium: medium)
        if tab.action != nil {
            tab.action!.invoke(viewController: AppDelegate.topViewController, origin: origin, medium: medium)
            return
        }
        AppDelegate.automaticPresent(viewController: ACTabViewController(tab: tab))
    }
    
    class ACWallpaperCollectionViewManager : NSObject, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
        private let elements: [ACElement]
        private let t: ACTab
        
        init(_ elements: [ACElement], _ t: ACTab) {
            self.elements = elements
            self.t = t
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return elements.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "wallpaper", for: indexPath) as! ACImageCollectionViewCell
            cell.setImage(ACImageResource(dict: elements[indexPath.item].getProperty("image") as! NSDictionary), viewController: AppDelegate.getTopmostViewController())
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
    
    private var fullExpAction: NSDictionary!
    
    @objc public func runFullExpAction() {
        ACButtonAction(dict: self.fullExpAction).invoke(viewController: self, origin: "fullexp", medium: "controller")
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
            break
        case "fullexp":
            view.backgroundColor = UIColor.black
            let controllerElement = self.tab!.elements[0]
            self.fullExpAction = controllerElement.getProperty("action") as! NSDictionary
            let controllerView = controllerElement.getView(viewController: self, origin: "/tabs/\(self.tab!.id)")
            controllerView.isUserInteractionEnabled = true
            controllerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.runFullExpAction)))
            controllerView.clipsToBounds = true
            self.stackView.addArrangedSubview(controllerView)
            if let scroll = self.stackView.superview as? UIScrollView {
                scroll.isScrollEnabled = false
            }
            self.view.addConstraints([
                NSLayoutConstraint(item: controllerView, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: controllerView, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1, constant: 0)
            ])
            break
        default: return
        }
    }
    
    private func initLayout() {
        guard !self.alreadyInitialized else {return}
        self.alreadyInitialized = true
        self.clearViews()
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
                self.stackView.addArrangedSubview(element.getView(viewController: self, origin: "/tabs/\(self.tab!.id)"))
            })
            if !UIDevice.current.isiPhoneX {
                self.stackView.addArrangedSubview(ACElement.createSeparator(visible: false))
            }
        }
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initLayout()
    }
    
    init(tab: ACTab) {
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
    }
}
