//
//  ViewController.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 12/28/17.
//  Copyright © 2017 Greg Whatley. All rights reserved.
//

import UIKit
import Firebase

class ACHomeViewController: UIViewController {
    
    @IBOutlet weak var buttonConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonOffsetConstraint: NSLayoutConstraint!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var modeLabel: UILabel!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func upButtonClick(_ sender: UIButton) {
        ACHomePageViewController.goToSecondViewController()
    }
    
    private func displayMainUI() {
        self.logo.isUserInteractionEnabled = true
        AppDelegate.invokeNotificationAction(withViewController: self)
        UIView.animate(withDuration: 0.25, delay: 0.1, options: .curveEaseInOut, animations: {
            self.indicator.alpha = 0
            self.logo.alpha = 1
        }) { b in
            UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseInOut, animations: {
                self.buttonConstraint.constant = 75
                self.view.layoutIfNeeded()
            }) { b in
                UIView.animate(withDuration: 0.25, animations: {
                    self.button.alpha = 1
                })
            }
        }
    }
    
    private func checkForUpdate() {
        let versionRef = Database.database().reference(withPath: "versions/ios")
        versionRef.keepSynced(true)
        versionRef.observeSingleEvent(of: .value, with: { snapshot in
            let value = snapshot.value as! Int
            let buildNumber = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
            print("LOCAL UPDATE CODE: \(buildNumber)")
            print("REMOTE UPDATE CODE: \(value)")
            if value > Int(buildNumber)! {
                let alert = UIAlertController(title: "Update Available", message: "An update is available for the Authentic City Church app.  We highly recommend that you update to avoid missing out on new features.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Not Now", style: .default, handler: { _ in self.displayMainUI() }))
                alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { _ in UIApplication.shared.open(URL(string: "itms-apps://itunes.apple.com/app/id1402645724")!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                    self.displayMainUI()
                }))
                self.present(alert, animated: true, completion: nil)
            } else {
                self.displayMainUI()
            }
        })
    }
    
    private func displayCheckForUpdate() {
        UIView.animate(withDuration: 0.25, delay: 0.1, options: .curveEaseInOut, animations: {
            self.indicator.alpha = 1
        }) { b in
            Reachability.getConnectionStatus(completionHandler: { connected in
                print("CONNECTED TO NETWORK: \(connected)")
                if connected {
                    self.checkForUpdate()
                } else {
                    self.displayMainUI()
                }
            })
        }
    }
    
    private func preInitialize() {
        self.button.alpha = 0
        self.logo.alpha = 0
        self.indicator.alpha = 0
        switch (AppDelegate.appMode) {
        case .Debug:
            UserDefaults.standard.set("Development", forKey: "sbMode")
            modeLabel.text = "DEBUG BUILD NOT FOR PRODUCTION\nVERSION \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String) BUILD \(Bundle.main.infoDictionary!["CFBundleVersion"] as! String)"
            break
        case .TestFlight:
            UserDefaults.standard.set("TestFlight", forKey: "sbMode")
            modeLabel.text = "TestFlight Beta Release\nVersion \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String) Build \(Bundle.main.infoDictionary!["CFBundleVersion"] as! String)"
            UIView.animate(withDuration: 3, delay: 5, options: .curveLinear, animations: { self.modeLabel.alpha = 0 }, completion: nil)
            break
        default:
            UserDefaults.standard.set("Production", forKey: "sbMode")
            modeLabel.text = ""
            break
        }
        UserDefaults.standard.synchronize()
    }
    
    private var alreadyCheckedForUpdates = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.buttonOffsetConstraint.constant = UIApplication.shared.statusBarFrame.size.height + UIApplication.shared.windows[0].safeAreaInsets.bottom
        if alreadyCheckedForUpdates {
            return
        }
        UIView.animate(withDuration: 0.001, delay: 0.1, animations: {
            self.view.layoutIfNeeded()
        }) { b in
            self.displayCheckForUpdate()
        }
        alreadyCheckedForUpdates = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preInitialize()
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
