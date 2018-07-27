//
//  ACVideoViewController.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 7/26/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import UIKit
import WebKit

class ACVideoViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView!
    
    private func initLayout() {
        webView.load(URLRequest(url: URL(string: self.provider == "YouTube" ? "https://www.youtube.com/embed/\(self.id)" : "https://player.vimeo.com/video/\(self.id)")!))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.setNeedsLayout()
        view.layoutIfNeeded()
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initLayout()
    }
    
    private let provider: String
    private let id: String
    
    init(provider: String, id: String) {
        self.provider = provider
        self.id = id
        super.init(nibName: "ACVideoViewController", bundle: Bundle.main)
        self.title = "VIDEO"
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.provider = ""
        self.id = ""
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyDefaultSettings()
    }
}
