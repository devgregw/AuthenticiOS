//
//  ACImageResource.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 6/18/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import SDWebImage

class ACImageResource {
    static var urlCache: [String: String] = [:]
    
    public let imageName: String
    
    public let width: Int
    
    public let height: Int
    
    init(dict: NSDictionary) {
        self.imageName = dict.value(forKey: "name", default: "unknown.png")
        self.width = dict.value(forKey: "width", default: 720)
        self.height = dict.value(forKey: "height", default: 1080)
    }
    
    convenience init() {
        self.init(dict: NSDictionary())
    }
    
    convenience init(imageName: String, width: Int, height: Int) {
        self.init(dict: NSDictionary(dictionary: ["name": imageName, "width": width, "height": height]))
    }
    
    private func getDownloadURL(completion: @escaping (URL?) -> Void) {
        if let url = ACImageResource.urlCache[imageName] {
            completion(URL(string: url)!)
        } else {
            var ref = Storage.storage().reference()
            /*if (AppDelegate.useDevelopmentDatabase) {
                ref = ref.child("dev")
            }*/
            ref.child(imageName).downloadURL(completion: {url, _ in
                if url != nil {
                    ACImageResource.urlCache[self.imageName] = url!.absoluteString
                }
                completion(url)
            })
        }
    }
    
    func calculateHeight(fromWidth width: CGFloat) -> CGFloat {
        return width * CGFloat(self.height) / CGFloat(self.width == 0 ? 1 : self.width)
    }
    
    func calculateHeight(usingFullScreenWidth fullWidth: Bool) -> CGFloat {
        return calculateHeight(fromWidth: UIScreen.main.bounds.width / (fullWidth ? 1 : 2))
    }
    
    func load(intoImageView view: UIImageView, fadeIn fade: Bool, setSize: Bool, scaleDownLargeImages scale: Bool = true, completion: @escaping () -> Void = {}) {
        if fade {
            view.alpha = 0
        }
        if setSize {
            view.addConstraint(NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: calculateHeight(usingFullScreenWidth: true)))
        }
        getDownloadURL(completion: { url in
            guard url != nil else {
                view.image = UIImage(named: "unknown")
                completion()
                if fade {
                    UIView.animate(withDuration: 0.3, animations: {
                        view.alpha = 1
                    })
                }
                return
            }
            view.sd_setImage(with: url, placeholderImage: nil, options: scale ? SDWebImageOptions.scaleDownLargeImages : SDWebImageOptions(), progress: nil, completed: { _, _, _, _ in
                completion()
                if fade {
                    UIView.animate(withDuration: 0.3, animations: {
                        view.alpha = 1
                    })
                }
             })
        })
    }
}
