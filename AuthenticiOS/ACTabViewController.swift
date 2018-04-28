//
//  ACTabViewController.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 1/2/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorageUI

class ACTabViewController: UIViewController {
    
    @IBOutlet weak var stackView: UIStackView!
    
    private let tab: AuthenticTab?
    
    private func clearViews() {
        while (self.stackView.arrangedSubviews.count > 1) {
            self.stackView.removeArrangedSubview(self.stackView.arrangedSubviews[1])
        }
    }
    
    public static func present(tab: AuthenticTab, withViewController vc: UIViewController) {
        vc.show(ACTabViewController(tab: tab), sender: nil)
    }
    
    private func initLayout() {
        self.clearViews()
        if (!self.tab!.hideHeader) {
            let i = UIImageView()
            i.contentMode = .scaleAspectFit
            Utilities.loadFirebase(image: self.tab!.header, into: i)
            self.stackView.addArrangedSubview(i)
        }
        if (self.tab!.elements.count == 0) {
            let label = UILabel()
            label.textColor = UIColor.black
            label.text = "No content"
            label.textAlignment = .center
            self.stackView.addArrangedSubview(label)
        } else {
            self.tab!.elements.forEach({ element in
                self.stackView.addArrangedSubview(element.getView(viewController: self))
            })
        }
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initLayout()
    }
    
    init(tab: AuthenticTab) {
        self.tab = tab
        super.init(nibName: "ACTabViewController", bundle: Bundle.main)
        self.title = tab.title
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.tab = nil
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Utilities.applyTintColor(to: self)
    }
}
