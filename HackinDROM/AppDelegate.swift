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
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @ObservedObject var sharedData = HASharedData()
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
            
            UNUserNotificationCenter.current().getNotificationSettings(){ (settings) in
                
                if settings.authorizationStatus != .authorized {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                        if success {
                            // print("All set!")
                        } else if let error = error {
                            print(error.localizedDescription)
                        }
                        
                    }
                }
            }
            
        }
        _ = MarkdownDocumentController()
        
        
        let myRootView = StartView(EFIs: getEFIList())
        self.popover.contentViewController = NSViewController()
        self.popover.contentViewController?.view = NSHostingView(rootView: myRootView.environmentObject(self.sharedData))
        self.popover.contentViewController?.view.window?.level = NSWindow.Level(rawValue: 16)
       
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
        self.sharedData.getOCLastSamples()
        
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
    
    
    
    //    @objc private func sleepListener(_ aNotification: Notification) {
    //
    //        if aNotification.name == NSWorkspace.willSleepNotification {
    //           // disableScreenSleep()
    //            print("Going to sleep")
    //
    //            umount("disk2")
    //            shell("caffeinate -d ") { req, _ in
    //
    //                print(req)
    //            }
    //            shell("diskutil eject disk3") {_,_ in}
    //
    //        } else if aNotification.name == NSWorkspace.didWakeNotification {
    //            print("Woke up")
    //        } else {
    //            print("Some other event other than the first two")
    //        }
    //    }
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

//////////////
// var assertionID: IOPMAssertionID = 0
// var sleepDisabled = false
// func disableScreenSleep(reason: String = "Disabling Screen Sleep") {
//    print(IOPMAssertionCreateWithName(kIOPMAssertionTypeNoDisplaySleep as CFString, IOPMAssertionLevel(kIOPMAssertionLevelOn), reason as CFString, &assertionID))
//
// }
// func enableScreenSleep() {
//
//    print(  IOPMAssertionRelease(assertionID))
//
//
// }
//

@objc(MarkdownDocument)
class MarkdownDocument: NSDocument {}
class MarkdownDocumentController: NSDocumentController {
    // ...
    override var defaultType: String? {
        return "com.apple.property-list"
    }
    
    override func documentClass(forType typeName: String) -> AnyClass? {
        return MarkdownDocument.self
    }
}



//    func Screensho() {
//        let viewToCapture = popover.contentViewController!.view.window!.contentView!
//        let rep = viewToCapture.bitmapImageRepForCachingDisplay(in: viewToCapture.bounds)!
//        viewToCapture.cacheDisplay(in: viewToCapture.bounds, to: rep)
//
//        let img = NSImage(size: viewToCapture.bounds.size)
//        img.addRepresentation(rep)
//
//
//
//
//        let pngData = rep.representation(using: .png, properties: [:])
//           try!  pngData!.write(to: URL(fileURLWithPath: "/Users/lian/Desktop/hellloooooosdffissd.png"))
//
//    }
