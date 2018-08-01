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
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let y = UIApplication.shared.statusBarFrame.size.height
        let f = view.frame
        view.frame = CGRect(x: 0, y: y, width: f.size.width, height: f.size.height)
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
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
        let y = UIApplication.shared.statusBarFrame.size.height
        let f = instance.view.frame
        instance.view.frame = CGRect(x: 0, y: y, width: f.size.width, height: f.size.height)
        instance.view.setNeedsLayout()
        instance.view.layoutIfNeeded()
    }
    
    static private var instance: ACHomePageViewController!
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard previousViewControllers.count > 0 else { return }
        // if the transition completed and the view controller we transitioned from is the first view controller
        if completed && ACHomePageViewController.controllers.index(of: previousViewControllers.first!) == 0 {
            self.view.subviews.forEach { view in
                if let scrollView = view as? UIScrollView {
                    // disable scrolling because it messes with the collection view
                    scrollView.isScrollEnabled = false
                }
            }
            let f = view.frame
            view.frame = CGRect(x: 0, y: 0, width: f.size.width, height: f.size.height)
            view.setNeedsLayout()
            view.layoutIfNeeded()
        }
    }
    
    static public var controllers: [UIViewController]!
    
    override func viewDidLoad() {
        let stbd = UIStoryboard(name: "Main", bundle: nil)
        let main = stbd.instantiateViewController(withIdentifier: "main")
        let home = stbd.instantiateViewController(withIdentifier: "hmroot")
        ACHomePageViewController.controllers = [main, home]
        self.dataSource = self
        self.delegate = self
        self.setViewControllers([ACHomePageViewController.controllers.first!], direction: .forward, animated: false, completion: nil)
        ACHomePageViewController.instance = self
    }
}
