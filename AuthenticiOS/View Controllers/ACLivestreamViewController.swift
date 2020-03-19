//
//  ACLivestreamViewController.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 10/26/19.
//  Copyright © 2019 Greg Whatley. All rights reserved.
//

import UIKit
import WebKit

class ACLivestreamViewController: UIViewController {
    @IBOutlet weak var placeholderImageView: UIImageView!
    @IBOutlet weak var placeholderView: UIView!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var loadingView: UIVisualEffectView!
    
    var state = false
    
    func showLoader(completion: @escaping () -> Void) {
        loadingView.alpha = 0
        loadingView.isHidden = false
        UIView.animate(withDuration: 0.5, animations: {
            self.loadingView.alpha = 1
        }, completion: {_ in completion()})
    }
    
    func hideLoader() {
        hideLoader {}
    }
    
    func hideLoader(completion: @escaping () -> Void) {
        DispatchQueue.main.sync {
            UIView.animate(withDuration: 0.5, animations: {
                self.loadingView.alpha = 0
            }, completion: { _ in
                self.loadingView.isHidden = true
                completion()
            })
        }
    }
    
    public func update() {
        let components = Calendar.current.dateComponents(in: TimeZone(abbreviation: "CST")!, from: Date())
        if AppDelegate.appMode == .Debug || (components.weekday ?? 0) == 1 {
            showLoader {
                let url = URL(string: "https://us-central1-authentic-city-church.cloudfunctions.net/videos")!
                var request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10)
                request.httpMethod = "GET"
                let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                    guard error == nil else {
                        print("YouTube error: \(error!.localizedDescription)")
                        self.hideLoader()
                        return
                    }
                    guard let jsonData = data else {
                        print("Livestream: data is nil")
                        self.hideLoader()
                        return
                    }
                    do {
                        URLCache.shared.removeAllCachedResponses()
                        let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as! NSDictionary
                        guard dictionary.count > 0 else {
                            print("Livestream: no data")
                            self.hideLoader()
                            return
                        }
                        guard let livestreamId = dictionary.value(forKey: "livestream") as? String else {
                            print("Livestream: not live")
                            self.hideLoader()
                            return
                        }
                        print("Livestream: \(livestreamId)")
                        self.hideLoader {
                            self.show(id: livestreamId)
                        }
                    } catch let parseError {
                        print("Livestream: Parse error: \(parseError.localizedDescription)")
                        self.hideLoader()
                    }
                }
                task.resume()
            }
        } else {
            print("Livestream: skipping check")
            hide()
        }
    }
    
    public func hide() {
        guard state else {return}
        state = false
        let transitionOptions: UIView.AnimationOptions = [.transitionFlipFromRight, .showHideTransitionViews, .curveEaseInOut]
        UIView.transition(from: webView, to: placeholderView, duration: 0.625, options: transitionOptions, completion: { _ in
            self.webView.loadHTMLString("", baseURL: nil)
        })
    }
    
    func show(id: String) {
        guard !state else {return}
        state = true
        let transitionOptions: UIView.AnimationOptions = [.transitionFlipFromRight, .showHideTransitionViews, .curveEaseInOut]
        UIView.transition(from: placeholderView, to: webView, duration: 0.625, options: transitionOptions, completion: { _ in
            self.webView.load(URLRequest(url: URL(string: "https://www.youtube.com/watch?v=\(id)")!))
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingView.layer.cornerRadius = 16
        loadingView.layer.masksToBounds = true
        // Do any additional setup after loading the view.
    }
}
