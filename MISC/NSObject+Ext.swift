//
//  NSObject+Ext.swift
//  ShakeItPhoto
//
//  Created by Cricket on 10/26/22.
//

import Foundation

// MARK: - Debugging Utils
extension NSObject {
    // DEBUGGING UTILS
    static var debugUtilsEnabled = ShakeItPhotoApp.debugUtilsEnabled
    
    static func printUtil(_ msgs: [String: Any]) {
        if debugUtilsEnabled {
            for (label,msg) in msgs {
                print("###--->\(label): \(msg)")
            }
        }
    }
}
