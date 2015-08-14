//
//  CaffeinateController.swift
//  Espresso
//
//  Created by Raphael Hanneken on 14/08/15.
//  Copyright © 2015 Raphael Hanneken. All rights reserved.
//

import Foundation

class CaffeinateController: NSObject {
    var caffeinate: NSTask?
    var active: Bool?
    
    override init() {
        super.init()
    }
    
    func launch() {
        let caffeinate = NSTask()
        
        caffeinate.launchPath = "/usr/bin/caffeinate"
        caffeinate.arguments  = ["-dsiu"]
        caffeinate.launch()
        
        active = true
        
        self.caffeinate = caffeinate
    }
    
    func terminate() {
        guard let caffeinate = caffeinate else {
            exit(1)
        }
        
        caffeinate.terminate()
        active = false
    }
    
    func isActive() -> Bool {
        guard let active = self.active else {
            return false
        }
        
        return active
    }
}