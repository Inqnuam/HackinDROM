//
//  StatusBarController.swift
//  Ambar
//
//  Created by Inqnuam on 12/11/19.
//  Copyright © 2021 HackinDROM. All rights reserved.
//

import AppKit
import SwiftUI

class EventMonitor {
    private var monitor: Any?
    private let mask: NSEvent.EventTypeMask
    private let handler: (NSEvent?) -> Void

    public init(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent?) -> Void) {
      self.mask = mask
      self.handler = handler
    }

    deinit {
      stop()
    }

    public func start() {
        monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler) as! NSObject
    }

    public func stop() {
      if monitor != nil {
        NSEvent.removeMonitor(monitor!)
        monitor = nil
      }
    }
}
class StatusBarController {
    @AppStorageCompat("HideWindow") var HideWindow = false
    var statusBar: NSStatusBar
    var statusItem: NSStatusItem
    public var AuthWinIsOpened: Bool = false
    private var popover: NSPopover
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
            statusBarButton.appearsDisabled = false
        }
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown], handler: mouseEventHandler)
    }
    
    func showPopover() {
        if let statusBarButton = statusItem.button {
            
            statusItem.button?.appearsDisabled = false
            popover.show(relativeTo: statusBarButton.bounds, of: statusBarButton, preferredEdge: NSRectEdge.maxY)
            popover.contentViewController?.view.window?.level = NSWindow.Level(rawValue: 16)
            popover.contentViewController?.view.window?.makeKeyAndOrderFront(nil)
            eventMonitor?.start()
            
        }
    }
   
    func hidePopover(_ sender: AnyObject) {
        
        nc.post(name: Notification.Name("CloseSheet"), object: nil)
        statusItem.button?.appearsDisabled = true
        popover.performClose(sender)
        eventMonitor?.stop()
        
    }

    @objc func togglePopover(sender: AnyObject) {
        
        if !AuthWinIsOpened {
            if popover.isShown {
                
                hidePopover(sender)
                
            } else {
                showPopover()
            }
            
        }
    }
    
    
    
    
    func mouseEventHandler(_ event: NSEvent?) {
            if(popover.isShown) && HideWindow {

                hidePopover(event!)
            }

        }

}
