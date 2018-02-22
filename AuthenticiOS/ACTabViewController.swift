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
        //vc.navigationController?.present(ACTabViewController(tab: tab), animated: true, completion: nil)
        //let x = vc.presentingViewController
        //if (x != nil) {
            //vc.dismiss(animated: false, completion: nil)
        //}
        //let controller = UINavigationController(rootViewController: ACTabViewController(tab: tab))
        //controller.navigationBar.barStyle = .blackTranslucent
        //vc.dismiss(animated: true, completion: nil)
        vc.show(ACTabViewController(tab: tab), sender: nil)
        //vc.present(controller, animated: true, completion: nil)
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
        NotificationCenter.default.addObserver(forName: .UIDeviceOrientationDidChange, object: nil, queue: .main, using: { notification in self.initLayout() })
        self.title = tab.title
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.tab = nil
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Utilities.applyTintColor(to: self)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
