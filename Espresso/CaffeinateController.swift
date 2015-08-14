//
// CaffeinatedController.swift
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