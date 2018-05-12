//
//  AppDelegate.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 12/28/17.
//  Copyright © 2017 Greg Whatley. All rights reserved.
//

import UIKit
import Firebase
import Foundation
import AVKit
import UserNotifications

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //let userInfo = notification.request.content.userInfo
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    private var launchedItem: UIApplicationShortcutItem?
    private static var notificationAction: AuthenticButtonAction? = nil
    
    var window: UIWindow?

    public static func invokeNotificationAction(withViewController vc: UIViewController) {
        notificationAction?.invoke(viewController: vc)
        notificationAction = nil
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        AppDelegate.notificationAction = AuthenticButtonAction(dict: NSDictionary(dictionary: userInfo.filter({ (arg) -> Bool in
            let (key, _) = arg
            return key as! String != "aps"
        })))
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        self.application(application, didReceiveRemoteNotification: userInfo)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        application.applicationIconBadgeNumber = 0
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch let error as NSError {
            print(error)
        }
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font : UIFont(name: "Proxima Nova", size: 18) ?? UIFont.systemFont(ofSize: 18)], for: .normal)
        Messaging.messaging().subscribe(toTopic: "main")
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: {_, _ in })
        } else {
            application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil))
        }
        if let shortcut = launchOptions?[.shortcutItem] as? UIApplicationShortcutItem {
            self.launchedItem = shortcut
            _ = respondToShortcut()
            self.launchedItem = nil
            return false
        }
        return true
    }

    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        self.launchedItem = shortcutItem
        completionHandler(respondToShortcut())
        self.launchedItem = nil
    }
    
    public func respondToShortcut() -> Bool {
        var handled = false
        if let item = self.launchedItem {
            var vc = self.window!.rootViewController!
            while (vc.presentedViewController != nil) {
                vc = vc.presentedViewController!
            }
            switch (item.type) {
            case "upcoming_events":
                Database.database().reference().child("appearance").observeSingleEvent(of: .value, with: { appearanceSnapshot in
                    let appearance = AuthenticAppearance(dict: appearanceSnapshot.value as! NSDictionary)
                    ACEventListController.present(withAppearance: appearance.events, viewController: vc)
                })
                handled = true
                break
            case "tab":
                let tabId = item.userInfo!["id"] as! String
                Database.database().reference().child("tabs/\(tabId)").observeSingleEvent(of: .value, with: {snapshot in
                    let val = snapshot.value as! NSDictionary
                    if vc is ACHomeViewController {
                        let nvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "hmroot")
                        vc.present(nvc, animated: true, completion: {
                            nvc.show(ACTabViewController(tab: AuthenticTab(dict: val)), sender: nil)
                        })
                    } else {
                        vc.show(ACTabViewController(tab: AuthenticTab(dict: val)), sender: nil)
                    }
                }) { error in vc.present(UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert), animated: true) }
                handled = true
                break
            default:
                break
            }
        }
        return handled
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        _ = respondToShortcut()
        self.launchedItem = nil
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

