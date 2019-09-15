//
//  ACWebViewController.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 9/8/19.
//  Copyright © 2019 Greg Whatley. All rights reserved.
//

import UIKit
import WebKit

class ACWebViewController: UIViewController, WKNavigationDelegate {
    @IBOutlet weak var webView: WKWebView!
    private var url: String = "https://apple.com"
    private var titleView: UIView?
    
    public static func instantiate(withUrl url: String) -> ACWebViewController {
        let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "webView") as! ACWebViewController
        vc.url = url
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleView = navigationItem.titleView
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.load(URLRequest(url: URL(string: url)!))
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        //title = "LOADING"
        navigationItem.titleView = UIActivityIndicatorView(style: .white)
        (navigationItem.titleView as? UIActivityIndicatorView)?.startAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        navigationItem.titleView = titleView
        title = webView.title
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        navigationItem.titleView = titleView
        title = webView.title ?? "ERROR"
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
