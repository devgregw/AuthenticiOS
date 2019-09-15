//
//  ACTestAnimViewController.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 9/9/19.
//  Copyright © 2019 Greg Whatley. All rights reserved.
//

import UIKit

class ACTestAnimViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let backgroundView = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "loadingview").view!
        //let rootView = UIApplication.shared.keyWindow!.rootViewController!.view!
        //rootView.addSubview(backgroundView)
        view.addSubview(backgroundView)
        view.bringSubviewToFront(backgroundView)
        view.setNeedsLayout()
        UIView.animate(withDuration: 0.1, delay: 5, options: .curveLinear, animations: {backgroundView.alpha = 0}, completion: {_ in backgroundView.removeFromSuperview()})
    }
}
