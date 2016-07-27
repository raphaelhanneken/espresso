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

let caffeineTaskStatusChangedNotificationKey = "io.raphaelhanneken.espresso.caffeinateTaskStatusChanged"

/// Manages the caffeinate task.
class CaffeineController {
  /// Holds a reference to the caffeinate task.
  private var caffeine: Task?

  /// Checks if the caffeinate task is currently running.
  var active: Bool {
    guard let status = caffeine?.isRunning else {
      return false
    }
    return status
  }

  /// Launches a new Caffeinate task.
  func caffeinate() {
    // Set the caffeinate task.
    caffeine = caffeinateTask()
    // Post a notification, that a new task has been started.
    NotificationCenter.default.post(name: Notification.Name(rawValue: caffeineTaskStatusChangedNotificationKey),
                                    object: nil)
  }

  /// Terminates the currently running caffeinate task.
  func decaffeinate() {
    // Bail out in case there isn't any caffeinate task.
    guard let caffeinate = caffeine else {
      return
    }
    // Terminate the active caffeinate task.
    caffeinate.terminate()
    // Post a notification, that the caffeinate task has been stopped.
    NotificationCenter.default.post(name: Notification.Name(rawValue: caffeineTaskStatusChangedNotificationKey),
                                    object: nil)
  }

  /// Toggle the caffeinate task status.
  func toggle() {
    if active {
      decaffeinate()
    } else {
      caffeinate()
    }
  }

  /// Creates and configures a caffeinate Task.
  ///
  /// - returns: A new, configured and launched caffeinate task.
  private func caffeinateTask() -> Task? {
    // Create a new task object.
    let caffeinate = Task()
    // Set the task's properties and launch it.
    caffeinate.launchPath = "/usr/bin/caffeinate"
    caffeinate.arguments  = ["-diu"]
    caffeinate.launch()
    // Assign the caffeinate property to out caffeinate task.
    return caffeinate
  }
}
