//
//  UIDevice.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 8/1/18.
//  Copyright © 2018 Greg Whatley. All rights reserved.
//

import Foundation
import UIKit

extension UIDevice {
    var deviceIdentifier: String {
        if let simulatorModel = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
            return simulatorModel
        }
        var systemInfo = utsname()
        uname(&systemInfo)
        return String(bytes: Data(bytes: &systemInfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
    }
    
    var isiPhoneX: Bool {
        switch deviceIdentifier {
        case "iPhone10,3", "iPhone10,6": return true
        default: return false
        }
    }
}
