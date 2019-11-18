//
//  ACWatchViewController.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 10/5/19.
//  Copyright © 2019 Greg Whatley. All rights reserved.
//

import UIKit

class ACWatchViewController: UIPageViewController {
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    private var videosViewController: ACVideosCollectionViewController!
    private var liveViewController: ACLivestreamViewController!
    private var mainTab: ACTab!
    private var playlistTabs: [ACTab]!
    private let liveDisabled = true
    
    @IBAction func selectionChanged(_ sender: Any) {
        if !liveDisabled {
            if segmentedControl.selectedSegmentIndex == 0 {
                setViewControllers([videosViewController], direction: .reverse, animated: true, completion: { _ in
                    self.liveViewController.hide()
                })
            } else {
                setViewControllers([liveViewController], direction: .forward, animated: true, completion: { _ in
                    self.liveViewController.update()
                })
            }
        }
    }
    
    public func initialize(main: ACTab, playlists: [ACTab]) {
        self.mainTab = main
        self.playlistTabs = playlists
        videosViewController = StoryboardHelper.instantiateVideosCollectionViewController(with: main, playlists: playlists)
        if !liveDisabled {
            liveViewController = StoryboardHelper.instantiateLivestreamViewController()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(liveDisabled, animated: false)
        
        segmentedControl.tintColor = UIColor.white
        segmentedControl.setTitleTextAttributes([
            .font: UIFont(name: "Alpenglow-ExpandedRegular", size: 12)!
        ], for: .normal)
        segmentedControl.setContentOffset(CGSize(width: 0, height: 2), forSegmentAt: 0)
        segmentedControl.setContentOffset(CGSize(width: 0, height: 2), forSegmentAt: 1)
        dataSource = self
        delegate = self
        setViewControllers([videosViewController], direction: .forward, animated: false, completion: nil)
    }
}

extension ACWatchViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard !liveDisabled else {return nil}
        return String(describing: type(of: viewController)) == "ACVideosCollectionViewController" ? liveViewController : videosViewController
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard !liveDisabled else {return nil}
        return String(describing: type(of: viewController)) == "ACVideosCollectionViewController" ? liveViewController : videosViewController
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard !liveDisabled || completed else {return}
        segmentedControl.selectedSegmentIndex = 1 - ([videosViewController, liveViewController].firstIndex(of: previousViewControllers[0]) ?? 0)
        if segmentedControl.selectedSegmentIndex == 0 {
            liveViewController.hide()
        } else {
            liveViewController.update()
        }
    }
}
