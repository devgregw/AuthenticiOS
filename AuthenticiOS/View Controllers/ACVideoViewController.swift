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
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    private var didLoad = false
    private var html = ""
    
    private func initLayout() {
        webView.configuration.mediaTypesRequiringUserActionForPlayback = []
        webView.configuration.allowsInlineMediaPlayback = true
        if (provider == "YouTube") {
        html = """
        <!DOCTYPE html>
        <html>
        <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width,initial-scale=1,shrink-to-fit=no">
        <style type=\"text/css\">
        *
        {
        margin:0;padding:0;
        }
        html,body
        {
        height:100%;
        width:100%;
        }
        body
        {
        display:table;
        }
        div
        {
        width: 100%;
        display:table-row;
        
        }
        
        iframe {
        width: 100%;
        height: 100%;
        }
        </style>
        </head>
        <body style=\"height: 100%;\">
        <!-- 1. The <iframe> (and video player) will replace this <div> tag. -->
        <div/>
        <div id="player"></div>
        
        <script>
        var tag = document.createElement('script');
        
        tag.src = "https://www.youtube.com/iframe_api";
        var firstScriptTag = document.getElementsByTagName('script')[0];
        firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
        
        var player;
        function onYouTubeIframeAPIReady() {
        player = new YT.Player('player', {
        height: '\(webView.frame.height)',
        width: '\(webView.frame.width)',
        videoId: '\(self.id)',
        events: {
        'onReady': onPlayerReady
        }
        });
        }
        
        function onPlayerReady(event) {
        event.target.playVideo();
        }
        </script>
        </body>
        </html>
        """
        }
        else {
            didLoad = true
            indicator.stopAnimating()
            webView.load(URLRequest(url: URL(string: "https://player.vimeo.com/video/\(self.id)?autoplay=1")!))
            
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !didLoad {
            webView.loadHTMLString(html, baseURL: nil)
            didLoad = true
            indicator.stopAnimating()
        }
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
    
    @objc public func share() {
        var components = URLComponents(string: self.provider == "YouTube" ? "https://youtube.com/watch" : "https://vimeo.com/\(self.id)")!
        if (self.provider == "YouTube") {
            components.queryItems = [URLQueryItem(name: "v", value: self.id)]
        }
        present(UIActivityViewController(activityItems: [components.url! as NSURL], applicationActivities: nil), animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyDefaultAppearance()
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.share))
        shareButton.tintColor = UIColor.white
        navigationItem.setRightBarButton(shareButton, animated: true)
    }
}
