//
//  AppDelegate.swift
//  Ambar
//
//  Created by Inqnuam on 12/11/19.
//  Copyright © 2021 HackinDROM. All rights reserved.
//


import SwiftUI
import DiskArbitration
import LaunchAtLogin
import UserNotifications
import Version
class AppDelegate: NSObject, NSApplicationDelegate {
    @ObservedObject var sharedData: HASharedData = HASharedData()
    var statusBar: StatusBarController?
    var popover: NSPopover = {
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 500, height: 560)
        popover.animates = false
        popover.contentViewController?.view.window?.level = NSWindow.Level(rawValue: 16)
        popover.contentViewController?.view.window?.makeKey()
        return popover
    }()
    
    
    let queue = DispatchQueue(label: "Arbitration")
    var matching: CFDictionary?
    static var mount: Bool = true
    
    
    func register() {
        DARegisterDiskPeekCallback(session!, self.matching, 0, diskAppeard, nil)
        DARegisterDiskDisappearedCallback(session!, self.matching, diskDisappeard, nil)
        DARegisterDiskMountApprovalCallback(session!, self.matching, approveDiskMount, nil)
        DARegisterDiskUnmountApprovalCallback(session!, self.matching, approveDiskUnmount, nil)
    }
    
    func unregister() {
        // Unregister callback
    }
    func applicationDidFinishLaunching(_ aNotification: Notification)   {
        self.register()
        DASessionSetDispatchQueue(session!, queue)
        
        
        if sharedData.FirstOpen {
            
            Task {
                let notifCenter = UNUserNotificationCenter.current()
                let settings =  await notifCenter.notificationSettings()
                print(settings)
                let authorizationOptions: UNAuthorizationOptions = [.alert, .sound, .badge]
                if settings.authorizationStatus != .authorized {
                    let authorizationGranted = try await notifCenter.requestAuthorization(options: authorizationOptions)
                    if authorizationGranted {
                        print("All set!")
                    }
                    
                    
                }
            }
            
        }
        _ = PlistDocumentController()
        
       
        
        // MARK: SwiftUI Bridge
        let myRootView = StartView(EFIs: getEFIList()).environmentObject(self.sharedData)
        self.popover.contentViewController = NSViewController()
        self.popover.contentViewController?.view = NSHostingView(rootView: myRootView)
        
        // as SwiftUI isn't very stable i'm going to try to switch to AppKit (without StoryBoard),
        // also the app will be compatible with older versions of macOS too
        // MARK: AppKit Bridge
        // Uncomment next line to see AppKit side progress
        //  self.popover.contentViewController = PopoverContentController(sharedData: sharedData)
        // self.popover.contentViewController?.view.window?.level = NSWindow.Level(rawValue: 16)
        
        
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(self.ChangePopoversScreen),
            name: NSWorkspace.activeSpaceDidChangeNotification,
            object: nil
        )
        NSApplication.shared.activate(ignoringOtherApps: true)
        NSApplication.shared.setActivationPolicy(.accessory)
        nc.addObserver(self, selector: #selector(self.OpenPopover(_:)), name: NSNotification.Name(rawValue: "OpenPopover"), object: nil)
        nc.addObserver(self, selector: #selector(self.ClosePopover(_:)), name: NSNotification.Name(rawValue: "ClosePopover"), object: nil)
        
        self.statusBar = StatusBarController(self.popover)
         
    }
    
    func application(_ sender: NSApplication, openFile filename: String, open url: URL) -> Bool {
        
        //        if !sharedData.isSaved {
        //            sharedData.editorIsAlerting = true
        //            return false
        //        } else {
        //            sharedData.isShowingSheet = false
        //            sharedData.ocTemplateName = ""
        //            sharedData.savingFilePath = filename
        //            if sharedData.currentview == 10 {
        //                nc.post(name: Notification.Name("loadplist"), object: nil)
        //
        //            } else {
        //                sharedData.currentview = 10
        //            }
        //            if !self.popover.isShown {
        //                nc.post(name: Notification.Name("OpenPopover"), object: nil)
        //            }
        //            return URL(fileURLWithPath: filename).pathExtension == "plist" ? true : false
        //        }
        
        // Process the URL.
        print(url)
        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
              let urlPath = components.path,
              let params = components.queryItems else {
                  print("Invalid URL or album path missing")
                  return false
              }
        
        print("urlPath", urlPath)
        print("params", params)
        return true
        
        
        
    }
    
    
    
    func applicationDidBecomeActive(_ notification: Notification) {
        // Return focus to the last active application if the shouldReturnFocus flag is set
        // This is used when the app's service is called
        //  popover.contentViewController?.view.window?.makeKey()
        //  popover.contentViewController?.view.window?.level = NSWindow.Level(rawValue: 3)
        
        // print("applicationDidBecomeActive")
        
        //        DispatchQueue.main.async {
        //          nc.post(name: Notification.Name("OpenPopover"), object: nil)
        //        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        
    }
    func showPO() {
        self.popover.show(relativeTo: (statusBar?.statusItem.button?.bounds)!, of: (statusBar?.statusItem.button!)!, preferredEdge: NSRectEdge.maxY)
        self.popover.contentViewController?.view.window?.level = NSWindow.Level(rawValue: 16)
        self.popover.contentViewController?.view.window?.makeKeyAndOrderFront(nil)
    }
    @objc func OpenPopover(_ notification: Notification) {
        
        showPO()
        
    }
    @objc func ClosePopover(_ notification: Notification) {
        if popover.isShown {
            
            popover.close()
        }
        
    }
    @objc func ChangePopoversScreen(_ notification: Notification) {
        
        if popover.isShown {
            // popover.close()
            showPO()
        }
        
    }
    
    
}


@objc(PlistDocument)
class PlistDocument: NSDocument {}
class PlistDocumentController: NSDocumentController {
    // ...
    override var defaultType: String? {
        return "com.apple.property-list"
    }
    
    override func documentClass(forType typeName: String) -> AnyClass? {
        return PlistDocument.self
    }
}
