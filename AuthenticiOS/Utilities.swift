//
//  Utilities.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 2/7/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorageUI

extension Date {
    
    static func parseISO8601(string: String) -> Date {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.autoupdatingCurrent
        formatter.locale = Locale.autoupdatingCurrent
        formatter.timeZone = TimeZone(abbreviation: "GMT")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return formatter.date(from: string)!
    }
    
    func formatISO8601() -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.autoupdatingCurrent
        formatter.locale = Locale.autoupdatingCurrent
        formatter.timeZone = TimeZone(abbreviation: "GMT")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return formatter.string(from: self)
    }
    
    func format(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.autoupdatingCurrent
        formatter.locale = Locale.autoupdatingCurrent
        formatter.timeZone = TimeZone.autoupdatingCurrent
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        return formatter.string(from: self)
    }
}

extension UIView {
    public func embedInStackViewWithInsets(top t: CGFloat, left l: CGFloat, bottom b: CGFloat, right r: CGFloat) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [self])
        stack.layoutMargins = UIEdgeInsets.init(top: t, left: l, bottom: b, right: r)
        stack.sizeToFit()
        stack.layoutIfNeeded()
        return stack
    }
}

extension String {
    public static func isNilOrEmpty(_ str: String?) -> Bool {
        return (str?.count ?? 0) == 0
    }
}

extension NSDictionary {
    public func value<T>(forKey key: String, default def: T) -> T {
        if let value = self[key] as? T {
            return value
        }
        return def
    }
}

class VersionInfo {
    static let Version = "1.0"
    static let Update = 7
    static let FullVersion = "\(Version) build \(Update)"
}

class Reachability {
    static func getConnectionStatus(completionHandler: @escaping (Bool) -> Void) {
        let address = "https://example.com"
        let url = URL(string: address)!
        let request = URLRequest(url: url)
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            if (error != nil || response == nil) {
                DispatchQueue.main.async {
                    completionHandler(false)
                }
            } else {
                DispatchQueue.main.async {
                    completionHandler(true)
                }
            }
        })
        task.resume()
    }
}

class ACEnlargableImageView: UIImageView {
    private var imageName: String
    private var vc: UIViewController
    private var loadingAlert: UIAlertController
    
    init(imageName: String, viewController vc: UIViewController) {
        self.imageName = imageName
        self.vc = vc
        loadingAlert = UIAlertController(title: nil, message: "Saving image...", preferredStyle: .alert)
        let indicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        indicator.hidesWhenStopped = true
        indicator.activityIndicatorViewStyle = .gray
        indicator.startAnimating()
        loadingAlert.view.addSubview(indicator)
        super.init(image: nil)
        Utilities.loadFirebase(image: imageName, into: self)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.expand)))
        self.isUserInteractionEnabled = true
    }
    
    @objc public func saveCompletion(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeMutableRawPointer?) {
        loadingAlert.dismiss(animated: true, completion: {
            guard error == nil else {
                let alert = UIAlertController(title: "Error", message: "An error occurred while saving the image.\n\n\(error!.localizedDescription)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                self.vc.present(alert, animated: true, completion: nil)
                return
            }
            let alert = UIAlertController(title: "Image Saved", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            self.vc.present(alert, animated: true, completion: nil)
        })
    }
    
    @objc public func expand() {
        vc.present(loadingAlert, animated: true, completion: {
            UIImageWriteToSavedPhotosAlbum(self.image!, self, #selector(self.saveCompletion(_:didFinishSavingWithError:contextInfo:)), nil)
        })
        
        //AuthenticButtonAction(type: "OpenURLAction", paramGroup: 0, params: ["url":"https://accams.devgregw.com/meta/storage/\(imageName)"]).invoke(viewController: vc)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ACInsetLabel: UILabel {
    override var alignmentRectInsets: UIEdgeInsets {
        return UIEdgeInsets.init(top: -5, left: -5, bottom: -5, right: -5)
    }
    
    private let insets = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
    
    override var intrinsicContentSize: CGSize {
        let superSize = super.intrinsicContentSize
        let w = superSize.width + insets.left + insets.right
        let h = superSize.height + insets.top + insets.bottom
        return CGSize(width: w, height: h)
    }
}

class Utilities {
    class MapInterface {
        static func isGoogleMapsAvailable() -> Bool {
            return UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!)
        }
        
        static func getDirections(toAddress address: String) {
            if isGoogleMapsAvailable() {
                UIApplication.shared.open(URL(string: "https://www.google.com/maps/dir/?api=1&destination=\(address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)")!, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.open(URL(string: "http://maps.apple.com/?daddr=\(address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)")!, options: [:], completionHandler: nil)
            }
        }
        
        static func search(forPlace location: String) {
            if isGoogleMapsAvailable() {
                UIApplication.shared.open(URL(string: "https://www.google.com/maps/search/?api=1&query=\(location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)")!, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.open(URL(string: "http://maps.apple.com/?q=\(location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)")!, options: [:], completionHandler: nil)
            }
        }
    }
    
    static func applyTintColor(to vc: UIViewController) {
        vc.navigationController?.navigationBar.barTintColor = UIColor.black
        vc.navigationController?.navigationBar.isTranslucent = false
    }
    
    static func defaultDateTimeDictionary() -> NSDictionary {
        return NSDictionary(objects: [Date().formatISO8601(), Date().addingTimeInterval(24*3600).formatISO8601()], forKeys: ["start" as NSCopying, "end" as NSCopying])
    }
    
    static func literalToNSDictionary(_ literal: [(key: Any, value: Any)]) -> NSDictionary {
        var k: [NSCopying] = []
        var v: [Any] = []
        literal.forEach({ e in k.append(e.key as! NSCopying); v.append(e.value) })
        return NSDictionary(objects: v, forKeys: k)
    }
    
    static func loadFirebase(image: String, into: UIImageView) {
        into.sd_setImage(with: Storage.storage().reference().child(image), placeholderImage: nil, completion: { (i, e, c, r) in
            if (e != nil) {
                print("Image \(image) failed to load with error \(e!.localizedDescription)")
                return
            }
            if (i == nil) {
                print("Image \(image) returned nil")
                return
            }
            print("Image \(image) finished loading from Firebase")
            let newHeight = (i!.size.height / i!.size.width) * (UIScreen.main.bounds.width)
            into.addConstraint(NSLayoutConstraint(item: into, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: newHeight))
        })
    }
}
