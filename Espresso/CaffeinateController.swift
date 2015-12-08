//
// CaffeinatedController.swift
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

import Foundation

/// Manages the caffeinate task.
class CaffeinateController: NSObject {
    /// Holds the caffeinate task.
    private var caffeinate: NSTask?
    
    /// Reference to wether the caffeinate task
    /// is currently running or not.
    private var active: Bool?
    
    /// Launches a new Caffeinate task.
    func launch() {
        // Create a new task.
        let caffeinate = NSTask()
        
        // Set the task properties.
        caffeinate.launchPath = "/usr/bin/caffeinate"
        caffeinate.arguments  = ["-diu"]
        
        // Launch the caffeinate task and set active to true.
        caffeinate.launch()
        active = true
        
        // Assign the caffeinate property to out caffeinate task.
        self.caffeinate = caffeinate
    }
    
    /// Terminates the currently running caffeinate task.
    func terminate() {
        // Unwrap the active caffeinate task...
        guard let caffeinate = caffeinate else {
            // In case caffeinate is nil, we don't have any
            // task running so just bail out.
            return
        }
        
        // Terminate the active caffeinate task.
        caffeinate.terminate()
        // Set the active indicator to false.
        active = false
    }
    
    // Check if there's already a caffeinate task running.
    func running() -> Bool {
        // Unwrap the active property; When nil return false.
        guard let active = self.active else {
            return false
        }
        
        // Return the unwrapped active property.
        return active
    }
}