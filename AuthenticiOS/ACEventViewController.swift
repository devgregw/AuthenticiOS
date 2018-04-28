//
//  ACEventViewController.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 4/22/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorageUI

class ACEventViewController: UIViewController {
    
    @IBOutlet weak var stackView: UIStackView!
    
    private let event: AuthenticEvent?
    
    private func clearViews() {
        while (self.stackView.arrangedSubviews.count > 1) {
            self.stackView.removeArrangedSubview(self.stackView.arrangedSubviews[1])
        }
    }
    
    public static func present(event: AuthenticEvent, withViewController vc: UIViewController) {
        vc.show(ACEventViewController(event: event), sender: nil)
    }
    
    private func initLayout() {
        self.clearViews()
        let i = UIImageView()
        i.contentMode = .scaleAspectFit
        Utilities.loadFirebase(image: self.event!.header, into: i)
        self.stackView.addArrangedSubview(i)
        //self.event!.elements.forEach({ element in
            //self.stackView.addArrangedSubview(element.getView(viewController: self))
        //})
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initLayout()
    }
    
    init(event: AuthenticEvent) {
        self.event = event
        super.init(nibName: "ACEventViewController", bundle: Bundle.main)
        self.title = event.title
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.event = nil
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Utilities.applyTintColor(to: self)
    }
}
