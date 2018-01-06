//
//  ACTabViewController.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 1/2/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import UIKit

class ACTabViewController: UIViewController {
    
    private let tab: AuthenticTab?
    
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
    
    @IBAction func click(_ sender: Any) {
        tab!.bundles[0].button?.action.invoke(viewController: self)
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
