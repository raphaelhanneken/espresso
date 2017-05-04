//
// CaffeinatedController.swift
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

/// The notification key for caffeine task updates.
let caffeineTaskStatusChangedNotificationKey = "io.raphaelhanneken.espresso.caffeinateTaskStatusChanged"

/// Manages the caffeinate task.
final class CaffeineController {
    /// Holds a reference to the caffeinate task.
    private var caffeine: Process?

    /// Checks whether a caffeinate task is currently running.
    var active: Bool {
        guard let status = caffeine?.isRunning else {
            return false
        }
        return status
    }

    /// Launches a new Caffeinate task.
    func caffeinate() {
        // Check that there isn't already a caffeine task running.
        if caffeine != nil {
            return
        }
        // Create and launch a new task.
        caffeine = caffeinateTask()
        // Post a notification, that a new task has been started.
        NotificationCenter.default.post(name: Notification.Name(rawValue: caffeineTaskStatusChangedNotificationKey),
                                        object: nil)
    }

    /// Terminates the currently running caffeinate task.
    func decaffeinate() {
        // Bail out in case there is no task running.
        guard let caffeine = caffeine else {
            return
        }
        // Terminate the caffeine task and wait for it to exit.
        caffeine.terminate()
        caffeine.waitUntilExit()
        // Reset.
        self.caffeine = nil
        // Post a notification, that the caffeinate task has been stopped.
        NotificationCenter.default.post(name: Notification.Name(rawValue: caffeineTaskStatusChangedNotificationKey),
                                        object: nil)
    }

    /// Creates and configures a caffeinate Task object.
    ///
    /// - returns: A configured and launched caffeinate task object.
    private func caffeinateTask() -> Process? {
        // Create a new task object.
        let caffeinate = Process()
        // Set the task's properties and launch it.
        caffeinate.launchPath = "/usr/bin/caffeinate"
        caffeinate.arguments  = ["-diu"]
        caffeinate.launch()
        // Assign the caffeinate property to the new caffeinate task.
        return caffeinate
    }
}
