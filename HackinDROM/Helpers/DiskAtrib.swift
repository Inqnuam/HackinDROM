//
//  DiskArbitration.swift
//  iArbitrate
//
//  Created by Inqnuam on 18/10/2018.
//  Copyright © 2021 HackinDROM. All rights reserved.
//

import Foundation
import DiskArbitration
import LocalAuthentication
let nc = NotificationCenter.default
var dissenter = DADissenterCreate(kCFAllocatorDefault, DAReturn(kDAReturnExclusiveAccess), "Mount denied" as CFString)
var session = DASessionCreate(kCFAllocatorDefault)

func releaseCallback(_ disk: DADisk, _ context: UnsafeMutableRawPointer?) -> Unmanaged<DADissenter>? {
    let nulvalue = "nul"
    let cstr = (nulvalue as NSString).utf8String
    let getDiskBSDNAME = DADiskGetBSDName(disk) ?? cstr
    let mountediskid = String(cString: getDiskBSDNAME!) // #FIXME: check if unmounting .dmg or netowrk disk is correctly handled
    
    defer {
        if mountediskid != "nul" {
            
            nc.post(name: Notification.Name("JustRemoved"), object: nil, userInfo: ["JustRemoved": mountediskid])
        }
    }
    
    return Unmanaged<DADissenter>.fromOpaque(Unmanaged.passRetained(dissenter).toOpaque()) // #FIXME: check if this conflits with ereasedisk
    
}

func claimCallback(_ disk: DADisk, _ dissenter: DADissenter?, _ context: UnsafeMutableRawPointer?) {
    
    
    let nulvalue = "nul"
    let cstr = (nulvalue as NSString).utf8String
    let getDiskBSDNAME = DADiskGetBSDName(disk) ?? cstr
    let mountediskid = String(cString: getDiskBSDNAME!) // #FIXME: check if unmounting .dmg or netowrk disk is correctly handled
    
    if mountediskid != "nul" {
        let desc = DADiskCopyDescription(disk) as! [String: CFTypeRef]
        
        if  desc["DAMediaName"]! as! String == "EFI System Partition" {
            
            if desc["DAVolumeName"]! as! String != "EFI" {
                //     nc.post(name: Notification.Name("JustMounted"), object: nil, userInfo: ["JustMounted":mountediskid])
            } else {
                // let name = "EFI-\(String((desc["DADeviceModel"]! as! String).uppercased().trimmingCharacters(in: .whitespacesAndNewlines).removeWhitespace().prefix(5)))" + String(Int.random(in: 1..<99))
                // DADiskRename(disk, name as CFString, 0x00000000 ,PostAfterRename ,nil)
            }
            
        }
    }
}

func diskAppeard(_ disk: DADisk, _ context: UnsafeMutableRawPointer?) {
    
    let desc = DADiskCopyDescription(disk) as! [String: CFTypeRef]
    
    let nulvalue = "nul"
    let cstr = (nulvalue as NSString).utf8String
    let getDiskBSDNAME = DADiskGetBSDName(disk) ?? cstr
    let mountediskid = String(cString: getDiskBSDNAME!) // #FIXME: check if unmounting .dmg or netowrk disk is correctly handled
    
    if mountediskid != "nul" {
        if  desc["DAMediaName"]! as! String == "EFI System Partition" {
            
            if desc["DAVolumeName"]! as! String != "EFI" {
                DispatchQueue.main.async {
                    nc.post(name: Notification.Name("JustMounted"), object: nil, userInfo: ["JustMounted": mountediskid])
                }
            } else {
                //  let name = "EFI-\(String((desc["DADeviceModel"]! as! String).uppercased().trimmingCharacters(in: .whitespacesAndNewlines).removeWhitespace().prefix(5)))" + String(Int.random(in: 1..<99))
                //   DADiskRename(disk, name as CFString, 0x00000000 ,PostAfterRename ,nil)
            }
            
            
        } else if desc["DAMediaWhole"]! as! Int == 1 &&  desc["DABusName"]! as! String != "/"   &&  desc["DAMediaName"]! as! String != "AppleAPFSMedia"{
            
            DispatchQueue.main.async {
                nc.post(name: Notification.Name("ExternalAdded"), object: nil, userInfo: ["ExternalAdded": GetExtDisk(disk)])
            }
            
        }
    }
    
    DADiskClaim(disk, DADiskClaimOptions(kDADiskClaimOptionDefault), releaseCallback, nil, claimCallback, nil)
}

func diskDisappeard(_ disk: DADisk, _ context: UnsafeMutableRawPointer?) {
    
    let desc = DADiskCopyDescription(disk) as! [String: CFTypeRef]
    
    let nulvalue = "nul"
    let cstr = (nulvalue as NSString).utf8String
    let getDiskBSDNAME = DADiskGetBSDName(disk) ?? cstr
    
    let mountediskid = String(cString: getDiskBSDNAME!) // #FIXME: check if unmounting .dmg or netowrk disk is correctly handled
    
    if mountediskid != "nul" && desc["DAMediaWhole"]! as! Int == 1 {
        DispatchQueue.main.async {
            nc.post(name: Notification.Name("ExternalRemoved"), object: nil, userInfo: ["ExternalRemoved": mountediskid])
        }
    }
}

func approveDiskMount(_ disk: DADisk, _ context: UnsafeMutableRawPointer?) -> Unmanaged<DADissenter>? {
    
    let nulvalue = "nul"
    let cstr = (nulvalue as NSString).utf8String
    let getDiskBSDNAME = DADiskGetBSDName(disk) ?? cstr
    let mountediskid = String(cString: getDiskBSDNAME!) //FIXME: check if unmounting .dmg or netowrk disk is correctly handled
    
    guard mountediskid != "nul"  else {return nil}
    
    let desc = DADiskCopyDescription(disk) as! [String: CFTypeRef]
    
    guard  desc["DAMediaName"]! as! String == "EFI System Partition" else {return nil}
    
    guard desc["DAVolumeName"] != nil  else { return nil}
    defer {
        DispatchQueue.main.async {
            nc.post(name: Notification.Name("JustMounted"), object: nil, userInfo: ["JustMounted": mountediskid])
        }
    }
    return nil
}



func approveDiskUnmount(_ disk: DADisk, _ context: UnsafeMutableRawPointer?) -> Unmanaged<DADissenter>? {
    
    
    let nulvalue = "nul"
    let cstr = (nulvalue as NSString).utf8String
    let getDiskBSDNAME = DADiskGetBSDName(disk) ?? cstr
    let mountediskid = String(cString: getDiskBSDNAME!) // #FIXME: check if unmounting .dmg or netowrk disk is correctly handled
    
    guard mountediskid != "nul" else {return nil}
    let desc = DADiskCopyDescription(disk) as! [String: CFTypeRef]
    
    
    
    guard desc["DAMediaName"]! as! String == "EFI System Partition" else {return nil}
    
    guard let volName = desc["DAVolumeName"] as? String else {return nil}
    if volName.hasPrefix("EFI-")  {
        
        defer {
            
            DADiskRename(disk, "EFI" as CFString, 0x00000000, nil, nil)
            DADiskUnmount(disk, DADiskUnmountOptions(kDADiskUnmountOptionDefault), PostAfterRename, nil)
        }
        
        
        return Unmanaged.passRetained(DADissenterCreate(kCFAllocatorDefault, DAReturn(kDAReturnBusy), "Renaming to EFI" as CFString))
        
    } else {
        defer {
            DispatchQueue.main.async {
                nc.post(name: Notification.Name("JustUnmounted"), object: nil, userInfo: ["JustUnmounted": mountediskid])
            }
        }
        return nil
    }
    
}


func mountEFI(UUID: String, NAME: String, user: String, pwd: String) -> String {
    
    var mountedEFIName = ""
    let disk = DADiskCreateFromBSDName(kCFAllocatorDefault, session!, "/dev/\(UUID)")!
    let IODetPar =  DADiskCopyWholeDisk(disk)
    
    var name = ""
    if IODetPar != nil {
        let ReqDADATAPar = DADiskCopyDescription(IODetPar!)
        let desc2 = ReqDADATAPar as! [String: CFTypeRef]
        name = generateEFIName(desc2)
    }
    
    var output:NSString?
    if launchCommandAsAdmin(UUID, &output) {
        if output != nil && output!.contains("\(UUID) mounted") {
            DADiskRename(disk, name as CFString, 0x00000000, PostAfterRename, nil)
            mountedEFIName = "/Volumes/\(name)"
            shell("rm -rf '/Volumes/\(name)/.Trashes'") {_, _ in}
        }
    } else {
        mountedEFIName = "nul"
    }
    return mountedEFIName
    
}


func generateEFIName(_ desc2: [String: CFTypeRef])-> String {
    var name: String = ""
    var prename = ""
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
    return name
}

func umount(_ UUID: String, _ force: Bool) {
    let disk = DADiskCreateFromBSDName(kCFAllocatorDefault, session!, "/dev/\(UUID)")!
    DADiskRename(disk, "EFI" as CFString, 0x00000000, nil, nil)
    
    if force {
        DADiskUnmount(disk, DADiskUnmountOptions(kDADiskUnmountOptionForce), PostAfterRename, nil)
    } else {
        DADiskUnmount(disk, DADiskUnmountOptions(kDADiskUnmountOptionDefault), PostAfterRename, nil)
    }
    
}

func PostAfterRename(disk: DADisk, dissenter: DADissenter?, context: UnsafeMutableRawPointer?) {
    DispatchQueue.main.async {
        nc.post(name: Notification.Name("JustMounted"), object: nil, userInfo: ["JustMounted": "nil"])
    }
    
}
