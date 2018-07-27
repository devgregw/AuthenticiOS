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
        print("UN willPresent: \(notification.request.content.title)")
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        print("UN didReceive: \(response.notification.request.content.title)::\(response.actionIdentifier)")
        self.application(UIApplication.shared, didReceiveRemoteNotification: response.notification.request.content.userInfo)
        AppDelegate.invokeNotificationAction(withViewController: UIApplication.shared.keyWindow!.rootViewController!)
        completionHandler()
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        AppDelegate.updateDevSubscription()
    }
    
    public static func updateDevSubscription() {
        let devNotifications = UserDefaults.standard.bool(forKey: "devNotifications")
        if devNotifications {
            Messaging.messaging().subscribe(toTopic: "dev")
        } else {
            Messaging.messaging().unsubscribe(fromTopic: "dev")
        }
    }
    
    private var launchedItem: UIApplicationShortcutItem?
    private static var notificationAction: AuthenticButtonAction? = nil
    
    var window: UIWindow?

    public static func invokeNotificationAction(withViewController vc: UIViewController) {
        notificationAction?.invoke(viewController: vc)
        notificationAction = nil
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        print("didReceiveRemoteNotification")
        let dict = NSDictionary(dictionary: userInfo.filter({ (arg) -> Bool in
            let (key, _) = arg
            return key as! String != "aps"
        }))
        guard dict.contains(where: { (k, _) -> Bool in
            return String(describing: k) == "type"
        }) else {
            AppDelegate.notificationAction = nil
            return
        }
        AppDelegate.notificationAction = AuthenticButtonAction(dict: dict)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("didReceiveRemoteNotification completionHandler")
        self.application(application, didReceiveRemoteNotification: userInfo)
        completionHandler(.newData)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        Database.database().isPersistenceEnabled = true
        UserDefaults.standard.set(VersionInfo.FullVersion, forKey: "sbVersion")
        UserDefaults.standard.synchronize()
        application.applicationIconBadgeNumber = 0
        do {
            try AVAudioSession.sharedInstance().setCategory("playback")
        } catch let error as NSError {
            print(error)
        }
        UIBarButtonItem.appearance().setTitleTextAttributes([.font : UIFont(name: "Proxima Nova", size: 18) ?? UIFont.systemFont(ofSize: 18)], for: .normal)
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: {_, _ in })
        } else {
            application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil))
        }
        application.registerForRemoteNotifications()
        if let shortcut = launchOptions?[.shortcutItem] as? UIApplicationShortcutItem {
            self.launchedItem = shortcut
            _ = respondToShortcut()
            self.launchedItem = nil
            return false
        }
        return true
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNS token received: \(deviceToken)")
        Messaging.messaging().subscribe(toTopic: "main")
        //Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        self.launchedItem = shortcutItem
        completionHandler(respondToShortcut())
        self.launchedItem = nil
    }
    
    public static func getTopmostViewController() -> UIViewController {
        var vc = UIApplication.shared.keyWindow!.rootViewController!
        while (vc.presentedViewController != nil) {
            vc = vc.presentedViewController!
        }
        return vc
    }
    
    public static func automaticPresent(viewController newVC: UIViewController) {
        let vc = getTopmostViewController()
        if let hp = vc as? ACHomePageViewController {
            let index = ACHomePageViewController.controllers.index(of: hp.viewControllers!.first!)
            if index == 0 {
                let nvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "hmroot")
                vc.present(nvc, animated: true, completion: {
                    nvc.show(newVC, sender: nil)
                })
            } else {
                hp.viewControllers!.first!.show(newVC, sender: nil)
            }
            return
        }
        vc.show(newVC, sender: nil)
    }
    
    public func respondToShortcut() -> Bool {
        var handled = false
        if let item = self.launchedItem {
            switch (item.type) {
            case "upcoming_events":
                Database.database().reference().child("appearance").observeSingleEvent(of: .value, with: { appearanceSnapshot in
                    let appearance = AuthenticAppearance(dict: appearanceSnapshot.value as! NSDictionary)
                    ACEventCollectionViewController.present(withAppearance: appearance.events)
                })
                handled = true
                break
            case "tab":
                let tabId = item.userInfo!["id"] as! String
                Database.database().reference().child("tabs/\(tabId)").observeSingleEvent(of: .value, with: {snapshot in
                    let val = snapshot.value as! NSDictionary
                    ACTabViewController.present(tab: AuthenticTab(dict: val))
                    /*if vc is ACHomePageViewController {
                        let nvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "hmroot")
                        vc.present(nvc, animated: true, completion: {
                            nvc.show(ACTabViewController(tab: AuthenticTab(dict: val)), sender: nil)
                        })
                    } else {
                        vc.show(ACTabViewController(tab: AuthenticTab(dict: val)), sender: nil)
                    }*/
                }) { error in AppDelegate.getTopmostViewController().present(UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert), animated: true) }
                handled = true
                break
            default:
                break
            }
        }
        return handled
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        AppDelegate.updateDevSubscription()
        _ = respondToShortcut()
        self.launchedItem = nil
    }
}
