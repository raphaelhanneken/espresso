//
// PreferenceManager.swift
// Espresso
// https://github.com/raphaelhanneken/espresso
//
// The MIT License (MIT)
//
// Copyright (c) 2015 - 2017 Raphael Hanneken
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

/// Key for the LaunchAtLogin preference.
private let launchAtLoginKey    = "LaunchAtLogin"
/// Key for the ActivateOnLaunch preference.
private let activateOnLaunchKey = "ActivateOnLaunch"

/// Manages the user defaults for Espresso.
final class PreferenceManager {
    /// Holds a reference to the user defaults.
    private let userDefaults = UserDefaults.standard

    /// Determines wether to activate a caffeinate task at launch.
    var activateOnLaunch: Bool {
        return userDefaults.bool(forKey: activateOnLaunchKey)
    }

    /// Initialize a PreferenceManager object.
    init() {
        registerDefaultPreferences()
    }

    /// Register the default preferences.
    private func registerDefaultPreferences() {
        // Disable activateOnLaunch by default.
        userDefaults.register(defaults: [activateOnLaunchKey: false])
    }
}
