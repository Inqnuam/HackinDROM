//
//  AppDelegate.swift
//  Ambar
//
//  Created by Inqnuam on 12/11/19.
//  Copyright © 2021 HackinDROM. All rights reserved.
//


import SwiftUI
import DiskArbitration
import UserNotifications
import Version

class AppDelegate: NSObject, NSApplicationDelegate {
    @ObservedObject var sharedData: HASharedData = HASharedData()
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    let queue = DispatchQueue(label: "Arbitration")
    var matching: CFDictionary?
    
    func register() {
            DARegisterDiskPeekCallback(session!, self.matching, 0, diskAppeard, nil)
            DARegisterDiskDisappearedCallback(session!, self.matching, diskDisappeard, nil)
            DARegisterDiskMountApprovalCallback(session!, self.matching, approveDiskMount, nil)
            DARegisterDiskUnmountApprovalCallback(session!, self.matching, approveDiskUnmount, nil)
        }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        self.register()
        DASessionSetDispatchQueue(session!, queue)

        let contentView = StartView(EFIs: getEFIList()).environmentObject(self.sharedData)

        popover = NSPopover()
        popover?.animates = false
        popover?.contentSize = NSSize(width: 500, height: 200)
        popover?.behavior = .semitransient
        popover?.contentViewController = NSHostingController(rootView: contentView)

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem?.button {
            button.image = #imageLiteral(resourceName: "StatusBarIcon")
            button.image?.size = NSSize(width: 18.0, height: 18.0)
            button.image?.isTemplate = true
            button.action = #selector(togglePopover(_:))
        }
        
    }

    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = statusItem?.button {
            if let popover = popover, popover.isShown {
                popover.performClose(sender)
            } else {
                popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                popover?.contentViewController?.view.window?.makeKey()
                popover?.contentViewController?.view.window?.makeFirstResponder(nil)
            }
        }
    }
  
}
