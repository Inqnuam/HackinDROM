//
//  EFI.swift
//  HackinDROM
//
//  Created by lian on 15/12/2021.
//  Copyright © 2021 Golden Chopper. All rights reserved.
//

import Foundation
struct EFI:Identifiable, Equatable {
    let id:String = Foundation.UUID().uuidString
    var location: String = ""
    var Name: String = ""
    var mounted: String = ""
    var type: String = ""
    var Where: String = ""
    var SSD: String = ""
    var UUID: String = ""
    var OC: Bool = false
    var OCv: String = ""
    var Parent: String = ""
    var FreeSpace: Int = 0
    var BackUpSize: Int = 0
    var plists: [String] = []
    
     func mount() -> String {
        UserDefaults.standard.setValue(false, forKey: "Rename")
        var mountedEFIName = ""
        let disk = DADiskCreateFromBSDName(kCFAllocatorDefault, session!, "/dev/\(location)")!
        
        let IODetPar =  DADiskCopyWholeDisk(disk)
        
        var name = ""
        
        var prename = ""
        if IODetPar != nil {
            let ReqDADATAPar = DADiskCopyDescription(IODetPar!)
            let desc2 = ReqDADATAPar as! [String: CFTypeRef]
            
            let DeviceModel = desc2["DADeviceModel"]
            let VendorName = desc2["DADeviceVendor"]
            
            let DevicePath = desc2["DADevicePath"]
            
            if DeviceModel != nil {
                
                prename = (DeviceModel as! String).removeWhitespace()
            }
            if VendorName != nil {
                
                prename.insert(contentsOf: (VendorName as! String).removeWhitespace() + " ", at: String.Index(utf16Offset: 0, in: prename)) // =
            }
            
            if DevicePath != nil {
                
                let serialLast3 = GetStorageSerialNumber((DevicePath as! String)).suffix(3)
                if !serialLast3.isEmpty {
                    name = "EFI-\(String(prename.uppercased().removeWhitespace().prefix(3)))-\(serialLast3)"
                } else {
                    name = "EFI-\(String(prename.uppercased().removeWhitespace().prefix(3)))-" + String(Int.random(in: 100..<999))
                }
                
            } else {
                
                name = "EFI-\(String(prename.uppercased().removeWhitespace().prefix(3)))-" + String(Int.random(in: 100..<999))
                
            }
        }
       
     
      
        var output:NSString?
        if launchCommandAsAdmin(location, &output) {
            if output != nil && output!.contains("\(location) mounted") {
                DADiskRename(disk, name as CFString, 0x00000000, PostAfterRename, nil)
                mountedEFIName = "/Volumes/\(name)"
                shell("rm -rf '/Volumes/\(name)/.Trashes'") {_, _ in}
            }
        } else {
            mountedEFIName = "nul"
        }
        
       
        
        return mountedEFIName
        
    }
    
    func unmount(_ forceUnmount: Bool) {
        let disk = DADiskCreateFromBSDName(kCFAllocatorDefault, session!, "/dev/\(location)")!
        
        DADiskRename(disk, "EFI" as CFString, 0x00000000, nil, nil)
            DADiskUnmount(disk, DADiskUnmountOptions(forceUnmount ? kDADiskUnmountOptionForce : kDADiskUnmountOptionDefault), PostAfterRename, nil)
        
        
    }
}
