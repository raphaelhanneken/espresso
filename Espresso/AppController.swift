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
class AppController: NSObject {
  /// Holds the status bar item.
  var statusItem: NSStatusItem!
  /// Manages the caffeinate task.
  var caffeinate: CaffeinateController!

  /// Holds the menu item.
  @IBOutlet weak var menu: NSMenu!

  /// Menu item to launch Espresso at login
  @IBOutlet weak var launchAtLogin: NSMenuItem!
  /// Menu item to activate Espresso at launch
  @IBOutlet weak var activateOnLaunch: NSMenuItem!


  override init() {
    // Make sure everything is set up properly before
    // initializing the class specific properties.
    super.init()

    // Configure the status bar item.
    configureStatusItem()
    // Init the caffeinate controller.
    caffeinate = CaffeinateController()
  }

  /// Do some setup work when launching the app.
  override func awakeFromNib() {
    // Init the PreferenceManager to get the user defaults.
    let prefManager = PreferenceManager()
    // Set the menu items to the state, choosen by the user.
    activateOnLaunch.state = prefManager.activateOnLaunch

    if LoginHelper.willLaunchAtLogin(Bundle.main.bundleURL) {
      launchAtLogin.state = NSOnState
    } else {
      launchAtLogin.state = NSOffState
    }

    // If activate on launch is set, spawn a caffeinate task.
    if activateOnLaunch.state == NSOnState {
      if let button = statusItem.button {
        toggleStatus(button)
      }
    }
  }

  /// Configure the status bar item.
  func configureStatusItem() {
    // Get a status bar item of variable length.
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)

    // Set the status bar item image.
    statusItem.image = NSImage(named: "Cup")

    // Define the status bar item to represent a template, to
    // enable automatic switching between the black and white menu bar.
    if let img = statusItem.image {
      img.isTemplate = true
    }

    // Set the button properties of the status bar item.
    if let statusBtn = statusItem.button {
      // Define the target of the click actions.
      statusBtn.target = self
      // Define the left click action.
      statusBtn.action = #selector(AppController.toggleStatus(_:))
      // Set the status items button to appear disabled
      // (transculant appearance)
      statusBtn.appearsDisabled = true

      // Define a right click action.
      NSEvent.addLocalMonitorForEvents(matching: .rightMouseUp) {
        (incomingEvent: NSEvent) -> NSEvent? in
        // Call displayMenu: on right click.
        self.displayMenu(statusBtn)
        return incomingEvent
      }
    }

    // Set the statusItem property.
    self.statusItem = statusItem
  }

  /// Display the app menu.
  ///
  /// - parameter sender: Status bar button that sends the action.
  func displayMenu(_ sender: NSStatusBarButton) {
    // Highlight the status bar item while the menu is open.
    sender.isHighlighted = true
    // Unwrap the status bar item.
    if let statusItem = statusItem {
      // Display the app menu.
      statusItem.popUpMenu(menu)
    }
    // Disable the highlighting of the status bar item when
    // the app menu closes.
    sender.isHighlighted = false
  }

  /// Either terminates or launches a caffeinate task, depending
  /// on whether a task is already running.
  ///
  /// - parameter sender: Status bar button that sends the action.
  func toggleStatus(_ sender: NSStatusBarButton) {
    // Check wether a caffeinate task is already
    // running or not
    if caffeinate.running() {
      // Terminate the running caffeinate task.
      caffeinate.terminate()
      // Let the menu bar icon appear disabled.
      sender.appearsDisabled = true
    } else {
      // Launch a new caffeinate task.
      caffeinate.launch()
      // Let the menu bar icon appea enabled.
      sender.appearsDisabled = false
    }
  }

  /// Toggles the state of sender.
  ///
  /// - parameter sender: Menu item to toggle the state.
  func toggleMenuItemState(_ sender: NSMenuItem) {
    if sender.state == NSOnState {
      sender.state = NSOffState
    } else {
      sender.state = NSOnState
    }
  }

  /// Let Espresso launch when the user logs in.
  ///
  /// - parameter sender: Menu item that sends the action.
  @IBAction func launchAtLogin(_ sender: NSMenuItem) {
    // Get the bundle url.
    let bundleURL = Bundle.main.bundleURL
    do {
      // Toggle the launch at login state.
      try LoginHelper.toggleLaunchAtLogin(bundleURL)
      // Toggle the menu item state
      toggleMenuItemState(sender)
    } catch {
      print(error)
    }
  }

  /// Let Espresso spawn a new caffeinate task as soon as
  /// it launches.
  ///
  /// - parameter sender: Menu item that sends the action.
  @IBAction func activateOnLaunch(_ sender: NSMenuItem) {
    // Toggle the menu item state
    toggleMenuItemState(sender)
  }

  /// Terminates Espresso.
  ///
  /// - parameter sender: Object that wants Espresso to quit
  @IBAction func terminate(_ sender: AnyObject) {
    // Terminate the caffeinate task, in case we're running any.
    if let caffeinate = self.caffeinate {
      caffeinate.terminate()
    }

    // Init the PreferenceManager to save the user defaults.
    let prefManager = PreferenceManager()
    // Save the new state to the user defaults
    prefManager.activateOnLaunch = activateOnLaunch.state

    // Send the terminate message.
    NSApplication.shared().terminate(self)
  }
}
