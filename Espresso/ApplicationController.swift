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
final class ApplicationController: NSObject {
  /// Holds a reference to the status bar item.
  var statusItem: NSStatusItem!
  /// Manages the caffeine task.
  var caffeine = CaffeineController()

  /// Holds a weak reference to the menu item.
  @IBOutlet weak var menu: NSMenu!

  // MARK: - Methods

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

  /// Do some setup work while the application launches.
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

  /// Either terminates or launches a caffeinate task, depending
  /// on whether a task is already running.
  func toggleStatus() {
    if caffeine.active {
      caffeine.decaffeinate()
    } else {
      caffeine.caffeinate()
    }
  }

  // MARK: - Private

  /// Configures the status bar item.
  ///
  /// returns: The configured status bar item.
  private func configureStatusItem() -> NSStatusItem? {
    // Get a status bar item of variable length.
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    // Get the status item's button.
    guard let btn = statusItem.button else {
      return nil
    }
    // Set the button's image.
    btn.image = NSImage(named: "Cup")

    // Set the button's properties.
    btn.target = self
    btn.action = #selector(ApplicationController.toggleStatus)
    btn.appearsDisabled = true

    // Listen for right click events to open the application menu.
    NSEvent.addLocalMonitorForEvents(matching: .rightMouseUp, handler: { (incomingEvent: NSEvent) -> NSEvent? in
      self.displayMenu(btn)
      return incomingEvent
    })
    return statusItem
  }

  /// Displays the application menu.
  ///
  /// - parameter sender: Status bar button that sent the action.
  private func displayMenu(_ sender: NSStatusBarButton) {
    // Highlight the status bar item while the menu is open.
    sender.isHighlighted = true
    // Display the app menu.
    statusItem?.popUpMenu(menu)
    // Set highlighted to false when the application menu closes.
    sender.isHighlighted = false
  }

  // MARK: - Actions

  /// Terminates Espresso.
  ///
  /// - parameter sender: Object that sent the message.
  @IBAction func terminate(_ sender: AnyObject) {
    // Terminate the caffeinate task, in case we're running any.
    if caffeine.active {
      caffeine.decaffeinate()
    }
    // Send the terminate message.
    NSApplication.shared().terminate(self)
  }
}
