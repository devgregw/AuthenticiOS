//
//  ACLivestreamCollectionViewCell.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 5/28/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import UIKit
import Foundation

class ACLivestreamCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var videoId: String!
    private var vc: UIViewController!
    
    @objc public func openStream() {
        var components = URLComponents(string: "https://www.youtube.com/watch")!
        components.queryItems = [URLQueryItem(name: "v", value: self.videoId)]
        UIApplication.shared.openURL(components.url!)
    }
    
    private func displayText(isLive: Bool) {
        DispatchQueue.main.async {
            let label = (AuthenticElement.createTitle(text: isLive ? "WATCH LIVE ON YOUTUBE" : "SUNDAYS AT 6:30 PM", alignment: "center", border: false, size: 22, color: UIColor.white) as! UIStackView).arrangedSubviews[0]
            label.alpha = 0
            self.addSubview(label)
            self.addConstraints([
                NSLayoutConstraint(item: label, attribute: .height, relatedBy: .lessThanOrEqual, toItem: self, attribute: .height, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: label, attribute: .width, relatedBy: .lessThanOrEqual, toItem: self, attribute: .width, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
                ])
            UIView.animate(withDuration: 0.3, animations: {
                label.alpha = 1
                self.activityIndicator.alpha = 0
            }, completion: { _ in
                self.activityIndicator.stopAnimating()
            })
            if isLive {
                self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.openStream)))
            }
        }
    }
    
    public func initialize(withViewController vc: UIViewController) {
        self.vc = vc
        let url = URL(string: "https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=UCxrYck_z50n5It7ifj1LCjA&type=video&eventType=live&key=AIzaSyB4w3GIY9AUi6cApXAkB76vlG6K6J4d8XE")!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print("YouTube error: \(error!.localizedDescription)")
                self.displayText(isLive: false)
                return
            }
            URLCache.shared.removeAllCachedResponses()
            guard let jsonData = data else {
                print("Livestream: data is nil")
                self.displayText(isLive: false)
                return
            }
            do {
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
        self.backgroundColor = UIColor.black
        self.setNeedsLayout()
    }
}
