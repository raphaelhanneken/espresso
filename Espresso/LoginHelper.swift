//
//  LoginHelper.swift
//  Espresso
//
//  Created by Raphael Hanneken on 13/08/15.
//  Copyright © 2015 Raphael Hanneken. All rights reserved.
//

import Foundation

class LoginHelper {
    
    static func willLaunchAtLogin(itemURL : NSURL) -> Bool {
        return findItem(itemURL) != nil
    }
    
    static func setLaunchAtLogin(itemURL: NSURL, enabled: Bool) -> Bool {
        let loginItems_ = getLoginItems()
        if loginItems_ == nil {return false}
        let loginItems = loginItems_!
        
        let item = findItem(itemURL)
        if item != nil && enabled {return true}
        if item != nil && !enabled {
            LSSharedFileListItemRemove(loginItems, item)
            return true
        }
        
        LSSharedFileListInsertItemURL(loginItems, kLSSharedFileListItemBeforeFirst.takeUnretainedValue(), nil, nil, itemURL as CFURL, nil, nil)
        return true
    }
    
    private static func getLoginItems() -> LSSharedFileList? {
        let allocator   = CFAllocatorGetDefault().takeUnretainedValue()
        let kLoginItems = kLSSharedFileListSessionLoginItems.takeUnretainedValue()
        let loginItems_ = LSSharedFileListCreate(allocator, kLoginItems, nil)
        if loginItems_ == nil {
            return nil
        }
        let loginItems = loginItems_.takeRetainedValue()
        return loginItems
    }
    
    private static func findItem(itemURL : NSURL) -> LSSharedFileListItem? {
        let loginItems_ = getLoginItems()
        if loginItems_ == nil {
            return nil
        }
        let loginItems = loginItems_!
        
        var seed : UInt32 = 0
        let currentItems  = LSSharedFileListCopySnapshot(loginItems, &seed).takeRetainedValue() as Array
        
        for item in currentItems {
            let resolutionFlags : UInt32 = UInt32(kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes)
            let url = LSSharedFileListItemCopyResolvedURL(item as! LSSharedFileListItem, resolutionFlags, nil).takeRetainedValue() as NSURL
            if url.isEqual(itemURL) {
                let result = item as! LSSharedFileListItem
                return result
            }
        }
        
        return nil
    }
}