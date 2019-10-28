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
    
    private var buildText: String!
    static public var shortcutTabId: String?
    
    @IBAction func showMoreOptions(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: buildText, message: "This menu will not be visible to users.", preferredStyle: .actionSheet)
        alert.popoverPresentationController?.barButtonItem = sender
        alert.addAction(UIAlertAction(title: "Switch to \(AppDelegate.useDevelopmentDatabase ? "Production" : "Development") Database", style: .destructive, handler: {_ in
            AppDelegate.useDevelopmentDatabase = !AppDelegate.useDevelopmentDatabase
            self.loadData(first: true)
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
    
    private var tabs: [ACTab] = []
    
    override func viewDidAppear(_ animated: Bool) {
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.clipsToBounds = true
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
            navigationItem.rightBarButtonItem = nil
            UserDefaults.standard.set("Production", forKey: "sbMode")
            buildText = ""
            break
        }
        UserDefaults.standard.synchronize()
        backgroundView = UIStoryboard(name: "LaunchScreen", bundle: Bundle.main).instantiateInitialViewController()!.view
        backgroundView.frame = navigationController!.view.bounds
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView.alpha = 1
        navigationController?.view.addSubview(backgroundView)
        navigationController?.view.bringSubviewToFront(backgroundView)
        backgroundView.subviews[0].center = navigationController!.view.center
        backgroundView.setNeedsLayout()
        backgroundView.layoutIfNeeded()
        imageWidthConstraint.constant = UIScreen.main.bounds.width - 120
        applyDefaultAppearance()
        loadData(first: true)
        self.view.setNeedsLayout()
        
        self.view.layoutIfNeeded()
    }
    
    private var isLoaderVisible = true
}

extension ACTabBarViewController {
    private func showLoader(_ first: Bool, completion: @escaping () -> Void) {
        if #available(iOS 13.0, *) {
        } else {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        guard !isLoaderVisible && first else {
            completion()
            return
        }
        isLoaderVisible = true
        self.navigationController?.view.bringSubviewToFront(backgroundView)
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
            self.backgroundView.alpha = 1
        }, completion: {_ in completion()})
    }

    private func hideLoader() {
        if #available(iOS 13.0, *) {
        } else {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        guard isLoaderVisible else {return}
        isLoaderVisible = false
        UIView.animate(withDuration: 0.3, delay: 1, options: .curveEaseInOut, animations: {
            self.backgroundView.alpha = 0
        }, completion: {_ in self.navigationController?.view.sendSubviewToBack(self.backgroundView)})
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
    
    public func loadData(first: Bool) {
        self.showLoader(first) {
            self.checkForUpdate {
                var ref = Database.database().reference()
                if AppDelegate.useDevelopmentDatabase {
                    ref = ref.child("dev")
                }
                ref.keepSynced(true)
                ref.child("tabs").observeSingleEvent(of: .value, with: {snap in
                    let val = snap.value as? NSDictionary
                    var playlists: [ACTab] = []
                    self.tabs.removeAll()
                    val?.forEach({(key, value) in
                        let tab = ACTab(dict: value as! NSDictionary)
                        if tab.specialType == "watchPlaylist" {
                            playlists.append(tab)
                        }
                        if (tab.isVisible()) {
                            self.tabs.append(tab)
                        }
                    })
                    self.tabs.sort(by: { (a, b) in a.index < b.index })
                    self.tabBar.tintColor = UIColor.white
                    self.tabBar.unselectedItemTintColor = UIColor.lightText
                    let wallpaperVc = StoryboardHelper.instantiateWallpaperCollectionViewController()
                    wallpaperVc.initialize(withTab: self.tabs.first(where: {tab in tab.id == "ME6HV83IM0"})!)
                    let eventsVc = StoryboardHelper.instantiateEventCollectionViewController()
                    var tabVcs: [UIViewController] = [eventsVc, wallpaperVc]
                    self.tabs.forEach({tab in
                        if tab.title == "WATCH" {
                            tabVcs.append(StoryboardHelper.instantiateWatchViewController(with: tab, playlists: playlists))
                        }
                        else if tab.id != "ME6HV83IM0" {
                            let vc = ACTabViewController.instantiateViewController(for: tab) as! ACTabViewController
                            vc.tabBarItem.title = tab.title.capitalized
                            tabVcs.append(vc)
                        }
                    })
                    
                    if !AppDelegate.useDevelopmentDatabase {
                        var shortcuts = [UIApplicationShortcutItem(type: "upcoming_events", localizedTitle: "Upcoming Events", localizedSubtitle: nil, icon: .init(type: .date), userInfo: nil)]
                        self.tabs.prefix(3).forEach({tab in
                            shortcuts.append(UIApplicationShortcutItem(type: "tab", localizedTitle: tab.title.capitalized, localizedSubtitle: nil, icon: nil, userInfo: ["id": tab.id as NSSecureCoding]))
                        })
                        UIApplication.shared.shortcutItems = shortcuts
                    }
                    
                    var tabBarVcs: [UIViewController] = []
                    if tabVcs.count > 5 {
                        tabBarVcs.append(contentsOf: tabVcs.prefix(4))
                        tabBarVcs.append(StoryboardHelper.instantiateMoreTableViewController(with: Array(self.tabs.suffix(from: 3)), navigationController: self.navigationController!))
                    } else {
                        tabBarVcs = tabVcs
                    }
                    self.setViewControllers(tabBarVcs, animated: false)
                    if let tabIndex = self.tabs.map({t in t.id}).firstIndex(of: ACTabBarViewController.shortcutTabId ?? "") {
                        self.selectedIndex = tabIndex
                        ACTabBarViewController.shortcutTabId = nil
                    }
                    self.tabBar.items?.forEach({i in
                        i.image = nil
                        i.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -16)
                    })
                    self.customizableViewControllers = nil
                    self.hideLoader()
                })
            }
        }
    }
}
