//
// AppController.swift
// Espresso
// https://github.com/raphaelhanneken/espresso
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Raphael Hanneken
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

import Cocoa

/// Main Controller for Espresso.
class ApplicationController: NSObject {
  /// Holds a reference to the status bar item.
  var statusItem: NSStatusItem!
  /// Manages the caffeine task.
  var caffeine = CaffeineController()

  /// Holds a weak reference to the menu item.
  @IBOutlet weak var menu: NSMenu!

  /// Initialize the application controller.
  override init() {
    // Make sure everything is set up properly before
    // initializing the class specific properties.
    super.init()
    // Configure the status bar item.
    statusItem = configureStatusItem()
    // Listen for Caffeine notifications.
    NotificationCenter.default.addObserver(self, selector: #selector(ApplicationController.toggleButtonState),
                                           name: Notification.Name(caffeineTaskStatusChangedNotificationKey),
                                           object: nil)
  }

  /// Do some setup work when launching the app.
  override func awakeFromNib() {
    // Get user defaults.
    let prefs = PreferenceManager()
    // Check whether the user wants to launch caffeinate automatically.
    if prefs.activateOnLaunch {
      toggleStatus()
    }
  }

  /// Toggles the status bar button's appearsDisabled property.
  func toggleButtonState() {
    guard let btn = statusItem.button else {
      return
    }
    if caffeine.active {
      btn.appearsDisabled = false
    } else {
      btn.appearsDisabled = true
    }
  }

  /// Configure the status bar item.
  func configureStatusItem() -> NSStatusItem? {
    // Get a status bar item of variable length.
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    // Get the status item's button.
    guard let btn = statusItem.button else {
      return nil
    }
    // Set the button's image.
    btn.image = NSImage(named: "Cup")
    btn.image?.isTemplate = true

    // Set the button's properties.
    btn.target = self
    btn.action = #selector(ApplicationController.toggleStatus)
    btn.appearsDisabled = true

    // Set the statusItem property.
    return statusItem
  }

  /// Display the app menu.
  ///
  /// - parameter sender: Status bar button that sends the action.
  func displayMenu(_ sender: NSStatusBarButton) {
    guard let itm = statusItem else {
      return
    }
    // Highlight the status bar item while the menu is open.
    sender.isHighlighted = true
    // Display the app menu.
    statusItem.popUpMenu(menu)
    // Set highlighted to false when the application menu closes.
    sender.isHighlighted = false
  }

  /// Either terminates or launches a caffeinate task, depending
  /// on whether a task is already running.
  func toggleStatus() {
    if caffeine.active {
      caffeine.decaffeinate()
    } else {
      caffeine.caffeinate()
    }
  }

  /// Terminates Espresso.
  ///
  /// - parameter sender: Object that wants Espresso to quit
  @IBAction func terminate(_ sender: AnyObject) {
    // Terminate the caffeinate task, in case we're running any.
    if caffeine.active {
      caffeine.decaffeinate()
    }
    // Send the terminate message.
    NSApplication.shared().terminate(self)
  }
}
