//
// AppController.swift
// Espresso
// https://github.com/behoernchen/Espresso
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
class AppController : NSObject {
    /// Holds the status bar item.
    var statusItem: NSStatusItem!
    /// Manages the user preferences.
    var prefManager: PreferenceManager!
    /// Manages the caffeinate task.
    var caffeinate: CaffeinateController!
    
    /// Holds the menu item.
    @IBOutlet weak var menu: NSMenu!
    
    /// Menu item to launch Espresso at login
    @IBOutlet weak var launchAtLogin: NSMenuItem!
    /// Menu item to activate Espresso at launch
    @IBOutlet weak var activateOnLaunch: NSMenuItem!
    
    /// Initializes an instance of AppController
    ///
    /// - returns: Initialized object of AppController
    override init() {
        // Make sure everything is set up properly before
        // initializing the class specific properties.
        super.init()
        
        // Configure the status bar item.
        self.configureStatusItem()
        // Init the PreferenceManager for the user defaults.
        self.prefManager = PreferenceManager()
        // Init the Controller for the Caffeinate task.
        self.caffeinate  = CaffeinateController()
    }
    
    /// Do some setup work when launching the app.
    override func awakeFromNib() {
        // Set the menu items to the state, choosen by the user.
        self.activateOnLaunch.state = prefManager.activateOnLaunch
        
        if LoginHelper.willLaunchAtLogin(NSBundle.mainBundle().bundleURL) {
            self.launchAtLogin.state = NSOnState
        } else {
            self.launchAtLogin.state = NSOffState
        }
        
        // If activate on launch is set, spawn a caffeinate task.
        if self.activateOnLaunch.state == NSOnState {
            if let button = self.statusItem.button {
                self.toggleStatus(button)
            }
        }
    }
    
    /// Configure the status bar item.
    func configureStatusItem() {
        // Get a status bar item of variable length.
        let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
        
        // Set the status bar item image.
        statusItem.image = NSImage(named: "Cup")
        
        // Define the status bar item to represent a template, to
        // enable automatic switching between the black and white menu bar.
        if let img = statusItem.image {
            img.template = true
        }
        
        // Set the button properties of the status bar item.
        if let statusBtn = statusItem.button {
            // Define the target of the click actions.
            statusBtn.target = self
            // Define the left click action.
            statusBtn.action = Selector("toggleStatus:")
            // Set the status items button to appear disabled
            // (transculant appearance)
            statusBtn.appearsDisabled = true
            
            // Define a right click action.
            NSEvent.addLocalMonitorForEventsMatchingMask(.RightMouseUpMask) { (incomingEvent: NSEvent) -> NSEvent? in
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
    func displayMenu(sender: NSStatusBarButton) {
        // Highlight the status bar item while the menu is open.
        sender.highlighted = true
        // Unwrap the status bar item.
        if let statusItem = self.statusItem {
            // Display the app menu.
            statusItem.popUpStatusItemMenu(self.menu)
        }
        // Disable the highlighting of the status bar item when
        // the app menu closes.
        sender.highlighted = false
    }
    
    /// Either terminates or launches a caffeinate task, depending
    /// on whether a task is already running.
    ///
    /// - parameter sender: Status bar button that sends the action.
    func toggleStatus(sender: NSStatusBarButton) {
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
    func toggleMenuItemState(sender: NSMenuItem) {
        if sender.state == NSOnState {
            sender.state = NSOffState
        } else {
            sender.state = NSOnState
        }
    }
    
    /// Let Espresso launch when the user logs in.
    ///
    /// - parameter sender: Menu item that sends the action.
    @IBAction func launchAtLogin(sender: NSMenuItem) {
        // Get the bundle url.
        let bundleURL = NSBundle.mainBundle().bundleURL
        
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
    @IBAction func activateOnLaunch(sender: NSMenuItem) {
        // Toggle the menu item state
        toggleMenuItemState(sender)
        
        // Save the new state to the user defaults
        self.prefManager.activateOnLaunch = self.activateOnLaunch.state
    }
    
    /// Terminates Espresso.
    ///
    /// - parameter sender: Object that wants Espresso to quit :(
    @IBAction func terminate(sender: AnyObject) {
        // Terminate the caffeinate task, in case we're running any.
        // Somehow Swift doesn't manage this itself. Dunno why.
        caffeinate.terminate()
        // Send the terminate message.
        NSApplication.sharedApplication().terminate(self)
    }
}
