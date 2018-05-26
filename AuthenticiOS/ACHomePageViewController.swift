//
//  ACHomePageViewController.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 5/24/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import Foundation
import UIKit

class ACHomePageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return 2
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = ACHomePageViewController.controllers.index(of: viewController) else {
            return nil
        }
        let previous = index - 1
        guard previous >= 0 else {
            return nil
        }
        guard ACHomePageViewController.controllers.count > previous else {
            return nil
        }
        return ACHomePageViewController.controllers[previous]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = ACHomePageViewController.controllers.index(of: viewController) else {
            return nil
        }
        let next = index + 1
        let count = ACHomePageViewController.controllers.count
        guard count != next else {
            return nil
        }
        guard count > next else {
            return nil
        }
        return ACHomePageViewController.controllers[next]
    }
    
    static public func returnToFirstViewController() {
        instance.view.subviews.forEach { view in
            if let scrollView = view as? UIScrollView {
                scrollView.isScrollEnabled = true
            }
        }
        instance.setViewControllers([controllers.first!], direction: .reverse, animated: true, completion: nil)
    }
    
    static private var instance: ACHomePageViewController!
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard previousViewControllers.count > 0 else { return }
        if completed && ACHomePageViewController.controllers.index(of: previousViewControllers.first!) == 0 {
            self.view.subviews.forEach { view in
                if let scrollView = view as? UIScrollView {
                    scrollView.isScrollEnabled = false
                }
            }
            ACHomePageViewController.controllers[1].view.setNeedsLayout()
        }
    }
    
    static private var controllers: [UIViewController]!
    
    override func viewDidLoad() {
        let stbd = UIStoryboard(name: "Main", bundle: nil)
        let main = stbd.instantiateViewController(withIdentifier: "main")
        let home = stbd.instantiateViewController(withIdentifier: "hmroot")
        if let nav = home as? UINavigationController {
            if let root = nav.viewControllers.first as? ACTabCollectionViewController {
                root.didStartFromSwipe = true
            }
        }
        ACHomePageViewController.controllers = [main, home]
        self.dataSource = self
        self.delegate = self
        self.setViewControllers([ACHomePageViewController.controllers.first!], direction: .forward, animated: false, completion: nil)
        ACHomePageViewController.instance = self
    }
}
