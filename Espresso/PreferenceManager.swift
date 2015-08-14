//
//  PreferenceManager.swift
//  Espresso
//
//  Created by Raphael Hanneken on 13/08/15.
//  Copyright © 2015 Raphael Hanneken. All rights reserved.
//

import Foundation

private let launchAtLoginKey    = "LaunchAtLogin"
private let activateOnLaunchKey = "ActivateOnLaunch"

class PreferenceManager {
    private let userDefaults = NSUserDefaults.standardUserDefaults()
    
    var launchAtLogin: Int {
        get           { return userDefaults.integerForKey(launchAtLoginKey) }
        set(newValue) { userDefaults.setInteger(newValue, forKey: launchAtLoginKey) }
    }
    
    var activateOnLaunch: Int {
        get           { return userDefaults.integerForKey(activateOnLaunchKey) }
        set(newValue) { userDefaults.setInteger(newValue, forKey: activateOnLaunchKey) }
    }
    
    init() {
        registerDefaultPreferences()
    }
    
    private func registerDefaultPreferences() {
        var defaults = [activateOnLaunchKey: 0]
        if LoginHelper.willLaunchAtLogin(NSBundle.mainBundle().bundleURL) {
            defaults[launchAtLoginKey] = 1
        } else {
            defaults[launchAtLoginKey] = 0
        }
        
        userDefaults.registerDefaults(defaults)
    }
}