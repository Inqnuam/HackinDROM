//
//  StatusBarController.swift
//  Ambar
//
//  Created by Anagh Sharma on 12/11/19.
//  Copyright © 2019 Anagh Sharma. All rights reserved.
//

import AppKit
import SwiftUI
class AskPasswordPopOver {

    private var statusBar: NSStatusBar
    private var statusItem: NSStatusItem
    private var popover: NSPopover
 //   let pub = NotificationCenter.default
         //     .publisher(for: NSNotification.Name("YourNameHere"))

  //  @EnvironmentObject var efis: DeviceDetector

    private var eventMonitor: EventMonitor?

    init(_ popover: NSPopover) {
        self.popover = popover
        statusBar = NSStatusBar.init()
        statusItem = statusBar.statusItem(withLength: 28.0)

        if let statusBarButton = statusItem.button {
            statusBarButton.image = #imageLiteral(resourceName: "StatusBarIcon")
            statusBarButton.image?.size = NSSize(width: 18.0, height: 18.0)
            statusBarButton.image?.isTemplate = true

            statusBarButton.action = #selector(togglePopover(sender:))
            statusBarButton.target = self
        }

        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown], handler: mouseEventHandler)
    }

    @objc func togglePopover(sender: AnyObject) {
        if popover.isShown {
            hidePopover(sender)

        } else {
            showPopover(sender)
        }
    }

    func showPopover(_ sender: AnyObject) {
        if let statusBarButton = statusItem.button {
            popover.show(relativeTo: statusBarButton.bounds, of: statusBarButton, preferredEdge: NSRectEdge.maxY)
            popover.contentViewController?.view.window?.makeKey()
            eventMonitor?.start()

        }
    }

    func hidePopover(_ sender: AnyObject) {
        popover.performClose(sender)
        eventMonitor?.stop()
     //   popover.contentViewController?.view.window?.resignKey()

    }

    func mouseEventHandler(_ event: NSEvent?) {
        if popover.isShown {
            hidePopover(event!)

        } else {

            popover.contentViewController?.view.window?.resignKey()
        }
    }
}
