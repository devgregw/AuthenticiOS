//
//  CalendarInterface.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 1/2/19.
//  Copyright © 2019 Greg Whatley. All rights reserved.
//

import Foundation
import EventKit
import EventKitUI

class CalendarInterface {
    class EventEditViewController: EKEventEditViewController, EKEventEditViewDelegate, UINavigationControllerDelegate {
        func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
            if let left = viewController.navigationItem.leftBarButtonItem {
                left.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: UIFont.labelFontSize), .foregroundColor: UIColor.init(red: 252/255, green: 71/255, blue: 65/255, alpha: 1)], for: .normal)
            }
            if let right = viewController.navigationItem.rightBarButtonItem {
                right.setTitleTextAttributes([.font: UIFont.boldSystemFont(ofSize: UIFont.labelFontSize), .foregroundColor: UIColor.init(red: 252/255, green: 71/255, blue: 65/255, alpha: 1)], for: .normal)
            }
        }
        
        func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
            controller.dismiss(animated: true, completion: nil)
        }
        
        override var preferredStatusBarStyle: UIStatusBarStyle {
            return .default
        }
        
        init(event: EKEvent, store: EKEventStore) {
            super.init(nibName: nil, bundle: nil)
            self.event = event
            self.eventStore = store
            self.editViewDelegate = self
            self.delegate = self
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
    }
    
    static func add(eventToCalendar event: EKEvent, withEventStore store: EKEventStore, withViewController vc: UIViewController) {
        DispatchQueue.main.async {
            vc.present(EventEditViewController(event: event, store: store), animated: true, completion: nil)
        }
    }
}
