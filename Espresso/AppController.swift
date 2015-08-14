//
//  AppController.swift
//  Espresso
//
//  Created by Raphael Hanneken on 14/08/15.
//  Copyright © 2015 Raphael Hanneken. All rights reserved.
//

import Cocoa


class AppController : NSObject {
    
    var statusItem: NSStatusItem!
    var prefManager: PreferenceManager!
    var caffeinate: CaffeinateController!
    
    @IBOutlet weak var menu: NSMenu!
    
    @IBOutlet weak var launchAtLogin: NSMenuItem!
    @IBOutlet weak var activateOnLaunch: NSMenuItem!
    
    
    override init() {
        super.init()
        
        self.configureStatusItem()
        self.prefManager = PreferenceManager()
        self.caffeinate  = CaffeinateController()
    }
    
    override func awakeFromNib() {
        self.launchAtLogin.state    = prefManager.launchAtLogin
        self.activateOnLaunch.state = prefManager.activateOnLaunch
        
        if self.activateOnLaunch.state == NSOnState {
            if let button = self.statusItem.button {
                self.toggleStatus(button)
            }
        }
    }
    
    func configureStatusItem() {
        let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
        
        statusItem.image = NSImage(named: "Cup")
        
        if let img = statusItem.image {
            img.template = true
        }
        
        if let statusBtn = statusItem.button {
            statusBtn.target = self
            statusBtn.action = Selector("toggleStatus:")
            
            statusBtn.appearsDisabled = true
            
            NSEvent.addLocalMonitorForEventsMatchingMask(.RightMouseUpMask) { (incomingEvent: NSEvent) -> NSEvent? in
                self.displayMenu(statusBtn)
                return incomingEvent
            }
        }
        
        self.statusItem = statusItem
    }
    
    func displayMenu(sender: NSStatusBarButton) {
        if let statusItem = self.statusItem {
            sender.highlighted = true
            statusItem.popUpStatusItemMenu(self.menu)
            sender.highlighted = false
        }
    }
    
    func toggleStatus(sender: NSStatusBarButton) {
        if caffeinate.isActive() {
            caffeinate.terminate()
            sender.appearsDisabled = true
        } else {
            caffeinate.launch()
            sender.appearsDisabled = false
        }
    }
    
    @IBAction func launchAtLogin(sender: NSMenuItem) {
        let bundleURL = NSBundle.mainBundle().bundleURL
        if self.launchAtLogin.state == NSOnState {
            self.launchAtLogin.state = NSOffState
            LoginHelper.setLaunchAtLogin(bundleURL, enabled: false)
        } else {
            self.launchAtLogin.state = NSOnState
            LoginHelper.setLaunchAtLogin(bundleURL, enabled: true)
        }
        
        // Save the new state
        self.prefManager.launchAtLogin = self.launchAtLogin.state
    }
    
    @IBAction func activateOnLaunch(sender: NSMenuItem) {
        if self.activateOnLaunch.state == NSOnState {
            self.activateOnLaunch.state = NSOffState
        } else {
            self.activateOnLaunch.state = NSOnState
        }
        
        // Save the new state to the user defaults
        self.prefManager.activateOnLaunch = self.activateOnLaunch.state
    }
    
    @IBAction func terminate(sender: AnyObject) {
        caffeinate.terminate()
        NSApplication.sharedApplication().terminate(self)
    }
}
