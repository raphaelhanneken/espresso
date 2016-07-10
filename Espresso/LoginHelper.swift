//
// LoginHelper.swift
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

/// Manages Launch at Login
class LoginHelper {

  ///  Checks whether the supplied bundle will launch at login.
  ///
  ///  - parameter itemURL: Bundle url.
  ///  - returns: true, when the supplied bundle launes at login otherwise false.
  static func willLaunchAtLogin(_ itemURL: URL) -> Bool {
    return (findItem(itemURL) != nil)
  }

  ///  Removes or add the given bundle from/to the login items list.
  ///
  ///  - parameter itemURL: Bundle url.
  ///  - throws: A LoginHelperError with further description.
  static func toggleLaunchAtLogin(_ itemURL: URL) throws {
    guard let loginItems = getLoginItems() else {
      throw LoginHelperError.gettingLoginItemsFailed
    }

    if let item = findItem(itemURL) {
      LSSharedFileListItemRemove(loginItems, item)
    } else {
      LSSharedFileListInsertItemURL(loginItems,
        kLSSharedFileListItemBeforeFirst.takeUnretainedValue(),
        nil,
        nil,
        itemURL as CFURL,
        nil,
        nil)
    }
  }

  /// Gets the login items of the current user.
  ///
  /// - returns: The login items of the current user.
  private static func getLoginItems() -> LSSharedFileList? {
    let allocator   = CFAllocatorGetDefault().takeUnretainedValue()
    let kLoginItems = kLSSharedFileListSessionLoginItems.takeUnretainedValue()

    guard let loginItems = LSSharedFileListCreate(allocator, kLoginItems, nil) else {
      return nil
    }

    return loginItems.takeRetainedValue()
  }

  /// Looks wether or not the given bundle is part of the login item list of the current user.
  ///
  /// - parameter itemURL: Bundle url.
  /// - returns: The list item of the given bundle if found, otherwise nil.
  private static func findItem(_ itemURL: URL) -> LSSharedFileListItem? {
    guard let loginItems = getLoginItems() else {
      return nil
    }

    var seed: UInt32 = 0
    let currentItems  = LSSharedFileListCopySnapshot(loginItems, &seed)
      .takeRetainedValue() as? Array<LSSharedFileListItem>

    guard let items = currentItems where items.isEmpty == false else {
      return nil
    }

    for item in items {
      let resolutionFlags: UInt32 = UInt32(kLSSharedFileListNoUserInteraction
        | kLSSharedFileListDoNotMountVolumes)
      let url = LSSharedFileListItemCopyResolvedURL(item, resolutionFlags, nil)
        .takeRetainedValue() as URL

      if url == itemURL {
        return item
      }
    }
  }
}

/// Error types for the LoginHelper class.
enum LoginHelperError: ErrorProtocol {
  case gettingLoginItemsFailed
}
