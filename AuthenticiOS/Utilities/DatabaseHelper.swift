//
//  DatabaseHelper.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 12/10/19.
//  Copyright © 2019 Greg Whatley. All rights reserved.
//

import Foundation
import Firebase

class DatabaseHelper {
    static func getRootReference() -> DatabaseReference {
        if AppDelegate.useDevelopmentDatabase {
            return Database.database().reference().child("dev")
        } else {
            return Database.database().reference()
        }
    }
    
    static func observeSingleEvent(of ref: DatabaseReference, with completion: @escaping (DataSnapshot) -> Void) {
        ref.observeSingleEvent(of: .value, with: completion)
    }
    
    static func setKeepSynced(_ value: Bool, _ ref: DatabaseReference) -> DatabaseReference {
        ref.keepSynced(false)
        return ref
    }
    
    static func loadAppearance(completion: @escaping (ACAppearance) -> Void) {
        observeSingleEvent(of: setKeepSynced(true, getRootReference().child("appearance")), with: { snap in
            completion(ACAppearance(dict: snap.value as! NSDictionary))
        })
    }
    
    static func loadAllTabs(keepSynced: Bool, completion: @escaping ([ACTab]) -> Void) {
        observeSingleEvent(of: setKeepSynced(keepSynced, getRootReference().child("tabs")), with: { snap in
            if let val = snap.value as? NSDictionary {
                completion(val.allValues.map({obj in obj as? NSDictionary}).filter({dict in dict != nil}).map({dict in ACTab(dict: dict!)}))
            } else {
                completion([])
            }
        })
    }
    
    static func loadTab(id: String, keepSynced: Bool, completion: @escaping (ACTab?) -> Void) {
        observeSingleEvent(of: setKeepSynced(keepSynced, getRootReference().child("tabs").child(id)), with: { snap in
            if let val = snap.value as? NSDictionary {
                completion(ACTab(dict: val))
            } else {
                completion(nil)
            }
        })
    }
}
