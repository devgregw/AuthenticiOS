//
//  ACLivestreamCollectionViewCell.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 5/28/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import UIKit
import Foundation
import Firebase

class ACLivestreamCollectionViewCell: UICollectionViewCell {
    static let cellHeight = CGFloat(80)
    
    @IBOutlet weak var watchLabel: UILabel!
    @IBOutlet weak var sundaysLabel: UILabel!
    @IBOutlet weak var servicesLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var videoId: String!
    private var vc: UIViewController!
    
    @objc public func openStream() {
        ACButtonAction(type: "OpenYouTubeAction", paramGroup: 0, params: [
            "videoId": self.videoId,
            "watchUrl": "https://youtube.com/watch?v=\(self.videoId!)",
            "youtubeUri": "youtube://\(self.videoId!)"
        ]).invoke(viewController: vc, origin: "livestreamTile")
    }
    
    private func displayText(isLive: Bool) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, animations: {
                self.watchLabel.alpha = isLive ? 1 : 0
                self.stackView.alpha = isLive ? 0 : 1
                self.activityIndicator.alpha = 0
            }, completion: { _ in
                self.activityIndicator.stopAnimating()
            })
            if isLive {
                self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.openStream)))
            }
        }
    }
    
    private func applyFontStyle(to label: UILabel, withFontSize fontSize: CGFloat) {
        label.attributedText = NSAttributedString(string: label.text!, attributes: [
            .kern: 2.5,
            .foregroundColor: UIColor.black,
            .font: UIFont(name: "Effra", size: fontSize)!
            ])
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
    }
    
    public func initialize(withViewController vc: UIViewController) {
        self.vc = vc
        applyFontStyle(to: watchLabel, withFontSize: CGFloat(22))
        applyFontStyle(to: sundaysLabel, withFontSize: CGFloat(22))
        applyFontStyle(to: servicesLabel, withFontSize: CGFloat(18))
        let url = URL(string: "https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=UCxrYck_z50n5It7ifj1LCjA&type=video&eventType=live&key=AIzaSyB4w3GIY9AUi6cApXAkB76vlG6K6J4d8XE")!
        let trace = Performance.startTrace(name: "check livestream")
        
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            trace?.stop()
            if error != nil {
                print("YouTube error: \(error!.localizedDescription)")
                self.displayText(isLive: false)
                return
            }
            guard let jsonData = data else {
                print("Livestream: data is nil")
                self.displayText(isLive: false)
                return
            }
            do {
                URLCache.shared.removeAllCachedResponses()
                let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as! NSDictionary
                let items = dictionary.value(forKey: "items") as! NSArray
                if items.count == 0 {
                    self.displayText(isLive: false)
                    return
                }
                let result = items[0] as! NSDictionary
                let videoId = (result.value(forKey: "id") as! NSDictionary).value(forKey: "videoId") as! String
                let thumbnail = (((result.value(forKey: "snippet") as! NSDictionary).value(forKey: "thumbnails") as! NSDictionary).value(forKey: "high") as! NSDictionary).value(forKey: "url") as! String
                /*do {
                    let data = try Data(contentsOf: URL(string: thumbnail)!)
                    DispatchQueue.main.async {
                        self.imageView.image = UIImage(data: data)
                    }
                } catch {
                    print("Unable to load thumbnail")
                }*/
                print("id: \(videoId), thumbnail: \(thumbnail)")
                self.videoId = videoId
                self.displayText(isLive: true)
            } catch let parseError {
                print("Parse error: \(parseError.localizedDescription)")
                self.displayText(isLive: false)
            }
        }
        task.resume()
        self.backgroundColor = UIColor.white
        self.setNeedsLayout()
    }
}
