//
//  Reachability.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 8/1/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import Foundation

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
