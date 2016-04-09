//
//  SettingsManager.swift
//  TapB4UNap
//
//  Created by Ken Ko on 12/04/2015.
//  Copyright (c) 2015 Ken Ko. All rights reserved.
//

import Foundation

/**
 *  Manages shared user defaults.
 */
class SettingsManager {

    /**
     The NSUserDefaults for the app group which can be shared between the app and the today extension
     */
    static let sharedUserDefaults = NSUserDefaults(suiteName: "group.com.cweatureapps.TapB4UNap")!

    /**
     Loads the settings from Defaults.plist into the shared user defaults
     */
    class func registerDefaultsFromPlist() {
        let plistPath = NSBundle.mainBundle().pathForResource("Defaults", ofType: "plist")
        if let plistPath = plistPath {
            let defaultsDictionary:NSDictionary! = NSDictionary(contentsOfFile: plistPath)
            for (key, value) in defaultsDictionary {
                sharedUserDefaults.setValue(value, forKey: key as! String)
            }
            SettingsManager.sharedUserDefaults.synchronize()
        }
    }
    
    /**
     Returns string setting from Defaults.plist

     - parameter key: The key in the plist
     - returns: The string associated with the key, nil if it cannot be found.
     */
    class func stringForKey(key:Defaults) -> String? {
        return SettingsManager.sharedUserDefaults.stringForKey(key.rawValue)
    }

}

/// Represents all the defaults stored in the plist
enum Defaults: String {
    case PlaceholderSetting
}
    