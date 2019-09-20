//
//  ACTabBarViewController.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 9/7/19.
//  Copyright © 2019 Greg Whatley. All rights reserved.
//

import UIKit
import Firebase

class ACTabBarViewController: UITabBarController {

    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    private var backgroundView: UIView!
    /*@IBAction func didRequestClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        ACHomePageViewController.returnToFirstViewController()
    }*/
    
    private var buildText: String!
    
    @IBAction func showMoreOptions(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: buildText, message: "This menu will not be visible to users.", preferredStyle: .actionSheet)
        alert.popoverPresentationController?.barButtonItem = sender
        alert.addAction(UIAlertAction(title: "Switch to \(AppDelegate.useDevelopmentDatabase ? "Production" : "Development") Database", style: .destructive, handler: {_ in
            AppDelegate.useDevelopmentDatabase = !AppDelegate.useDevelopmentDatabase
            self.loadData()
        }))
        alert.addAction(UIAlertAction(title: "Share FCM Registration Token", style: .default, handler: {_ in
            let activityController = UIActivityViewController(activityItems: [(Messaging.messaging().fcmToken ?? "<unavailable>") as NSString], applicationActivities: nil)
            activityController.popoverPresentationController?.barButtonItem = sender
            self.present(activityController, animated: true, completion: nil)
        }))
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = sender
        }
        alert.preferredAction = cancel
        present(alert, animated: true, completion: nil)
    }
    
    class MoreNavigationDelegate: NSObject, UINavigationControllerDelegate {
        private let nav: UINavigationController
        
        init(_ nav: UINavigationController) {
            self.nav = nav
        }
        
        func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
            guard String(describing: type(of: viewController)) != "UIMoreListController" else {
                viewController.navigationController?.setNavigationBarHidden(true, animated: false)
                return
            }
        }
    }
    
    class MoreTableViewDelegate: NSObject, UITableViewDelegate, UITableViewDataSource {
        private let nav: UINavigationController
        private let tabs: [ACTab]
        
        init(_ nav: UINavigationController, _ tabs: [ACTab]) {
            self.nav = nav
            self.tabs = tabs
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let t = self.tabs[indexPath.item]
            if let action = t.action {
                action.invoke(viewController: nav, origin: "/tabs/\(t.id)", medium: "more")
                return
            }
            nav.show(ACTabViewController.instantiateViewController(for: t), sender: nil)
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return section == 0 ? tabs.count : 0
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let t = self.tabs[indexPath.item]
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.selectionStyle = .none
            let vc = ACTabViewController(tab: t)
            vc.setTabBarItem(forId: t.id)
            cell.textLabel?.font = UIFont(name: "Alpenglow-ExpandedRegular", size: UIFont.labelFontSize - 2)!
            cell.imageView?.image = vc.tabBarItem.image
            cell.imageView?.tintColor = UIColor(red: 36/255, green: 137/255, blue: 248/255, alpha: 1)
            cell.textLabel?.text = self.tabs[indexPath.item].title.capitalized
            cell.accessoryType = .disclosureIndicator
            return cell
        }
    }
    
    private var tabs: [ACTab] = []
    lazy var moreDelegate: MoreNavigationDelegate = {
        return MoreNavigationDelegate(self.navigationController!)
    }()
    
    private var moreTableViewDelegate: MoreTableViewDelegate!
    
    override func viewDidAppear(_ animated: Bool) {
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch (AppDelegate.appMode) {
        case .Debug:
            UserDefaults.standard.set("Development", forKey: "sbMode")
            buildText = "DEBUG BUILD NOT FOR PRODUCTION\nVERSION \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String) BUILD \(Bundle.main.infoDictionary!["CFBundleVersion"] as! String)"
            break
        case .TestFlight:
            UserDefaults.standard.set("TestFlight", forKey: "sbMode")
            buildText = "TestFlight Beta Release\nVersion \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String) Build \(Bundle.main.infoDictionary!["CFBundleVersion"] as! String)"
            break
        default:
            UserDefaults.standard.set("Production", forKey: "sbMode")
            buildText = ""
            break
        }
        UserDefaults.standard.synchronize()
        backgroundView = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "loadingview").view!
        self.delegate = self
        imageWidthConstraint.constant = UIScreen.main.bounds.width - 120
        applyDefaultAppearance()
        loadData()
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
}

extension ACTabBarViewController {
    private func showLoader(completion: @escaping () -> Void) {
        backgroundView.alpha = 0
        view.addSubview(backgroundView)
        view.bringSubviewToFront(backgroundView)
        UIView.animate(withDuration: 0.1, animations: {self.backgroundView.alpha = 1}, completion: {_ in completion()})
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }

    private func hideLoader() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        UIView.animate(withDuration: 0.1, delay: 1, options: .curveLinear, animations: {self.backgroundView.alpha = 0}, completion: {_ in self.backgroundView.removeFromSuperview()})
    }
}

extension ACTabBarViewController {
    fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
        return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
    }
    
    private func checkForUpdate(completion: @escaping () -> Void) {
        let versionRef = Database.database().reference(withPath: "versions/ios")
        versionRef.keepSynced(true)
        versionRef.observeSingleEvent(of: .value, with: { snapshot in
            let value = snapshot.value as! Int
            let buildNumber = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
            print("LOCAL UPDATE CODE: \(buildNumber)")
            print("REMOTE UPDATE CODE: \(value)")
            if value > Int(buildNumber)! {
                let alert = UIAlertController(title: "Update Available", message: "An update is available for the Authentic City Church app.  We highly recommend that you update to avoid missing out on new features.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Not Now", style: .default, handler: { _ in completion() }))
                alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { _ in UIApplication.shared.open(URL(string: "itms-apps://itunes.apple.com/app/id1402645724")!, options: self.convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: {_ in completion()})
                }))
                self.present(alert, animated: true, completion: nil)
            } else {
                completion()
            }
        })
    }
    
    public func loadData() {
        self.showLoader {
            self.checkForUpdate {
                var ref = Database.database().reference()
                if AppDelegate.useDevelopmentDatabase {
                    ref = ref.child("dev")
                }
                ref.keepSynced(true)
                ref.child("tabs").observeSingleEvent(of: .value, with: {snap in
                    let val = snap.value as? NSDictionary
                    self.tabs.removeAll()
                    val?.forEach({(key, value) in
                        let tab = ACTab(dict: value as! NSDictionary)
                        if (tab.isVisible()) {
                            self.tabs.append(tab)
                        }
                    })
                    self.tabs.sort(by: { (a, b) in a.index < b.index })
                    self.tabBar.tintColor = UIColor.white
                    self.tabBar.unselectedItemTintColor = UIColor.lightText
                    let wallpaperVc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "wallpapersCollectionViewController") as! ACWallpaperCollectionViewController
                    wallpaperVc.initialize(withTab: self.tabs.first(where: {tab in tab.id == "ME6HV83IM0"})!)
                    let eventsVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "evroot") as! ACEventCollectionViewController
                    var tabVcs: [UIViewController] = [eventsVc, wallpaperVc]
                    /*if self.tabs.count > 4 {
                     tabVcs.append(contentsOf: self.tabs.suffix(from: 1).prefix(2).map({tab in
                     let vc = ACTabViewController.instantiateViewController(for: tab) as! ACTabViewController
                     vc.setTabBarItem(forId: tab.id)
                     return vc
                     }))
                     let moreVc = UIViewController(nibName: nil, bundle: nil)
                     moreVc.title = "__MORE__"
                     moreVc.tabBarItem = UITabBarItem(title: "More", image: UIImage(named: "outline_more_horiz_white_24pt"), selectedImage: nil)
                     tabVcs.append(moreVc)
                     } else {*/
                    self.tabs.forEach({tab in
                        if tab.id != "ME6HV83IM0" {
                            let vc = ACTabViewController.instantiateViewController(for: tab) as! ACTabViewController
                            vc.setTabBarItem(forId: tab.id)
                            tabVcs.append(vc)
                        }
                    })
                    self.moreTableViewDelegate = MoreTableViewDelegate(self.navigationController!, Array(self.tabs.suffix(from: 3)))
                    //}
                    
                    self.moreNavigationController.delegate = self.moreDelegate
                    (self.moreNavigationController.topViewController!.view as! UITableView).dataSource = self.moreTableViewDelegate
                    (self.moreNavigationController.topViewController!.view as! UITableView).delegate = self.moreTableViewDelegate
                    
                    self.setViewControllers(tabVcs, animated: false)
                    self.customizableViewControllers = nil
                    self.hideLoader()
                })
            }
        }
    }
}

extension ACTabBarViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        /*guard viewController.title == "__MORE__" else { return true }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let moreTabs = self.tabs.suffix(from: 3)
        moreTabs.forEach({tab in
            alert.addAction(UIAlertAction(title: tab.title, style: .default, handler: {_ in ACTabViewController.instantiateViewController(for: tab).presentSelf(sender: nil)}))
        })
        present(alert, animated: true, completion: nil)
        return false*/
        return true
    }
}
