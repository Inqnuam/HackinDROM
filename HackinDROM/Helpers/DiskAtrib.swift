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
    let mountediskid = String(cString: getDiskBSDNAME!) // #FIXME check if unmounting .dmg or netowrk disk is correctly handled
    
    if mountediskid != "nul" {
        
        nc.post(name: Notification.Name("JustRemoved"), object: nil, userInfo: ["JustRemoved": mountediskid])
    }
    
    return Unmanaged<DADissenter>.fromOpaque(Unmanaged.passRetained(dissenter).toOpaque()) // #FIXME check if this conflits with ereasedisk
    
}

func claimCallback(_ disk: DADisk, _ dissenter: DADissenter?, _ context: UnsafeMutableRawPointer?) {
    
    
    let nulvalue = "nul"
    let cstr = (nulvalue as NSString).utf8String
    let getDiskBSDNAME = DADiskGetBSDName(disk) ?? cstr
    let mountediskid = String(cString: getDiskBSDNAME!) // #FIXME check if unmounting .dmg or netowrk disk is correctly handled
    
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
    let mountediskid = String(cString: getDiskBSDNAME!) // #FIXME check if unmounting .dmg or netowrk disk is correctly handled
    
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
            
            if UserDefaults.standard.bool(forKey: "MountAutomaticly") {
                
                nc.post(name: Notification.Name("MountAutomaticly"), object: nil, userInfo: ["MountAutomaticly": mountediskid])
                
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
    
    let mountediskid = String(cString: getDiskBSDNAME!) // #FIXME check if unmounting .dmg or netowrk disk is correctly handled
    
    if mountediskid != "nul" && desc["DAMediaWhole"]! as! Int == 1 {
        DispatchQueue.main.async {
            nc.post(name: Notification.Name("ExternalRemoved"), object: nil, userInfo: ["ExternalRemoved": mountediskid])
        }
    }
}

func approveDiskMount(_ disk: DADisk, _ context: UnsafeMutableRawPointer?) -> Unmanaged<DADissenter>? {
    
    let iMustRename = UserDefaults.standard.bool(forKey: "Rename")
    
    let nulvalue = "nul"
    let cstr = (nulvalue as NSString).utf8String
    let getDiskBSDNAME = DADiskGetBSDName(disk) ?? cstr
    let mountediskid = String(cString: getDiskBSDNAME!) // #FIXME check if unmounting .dmg or netowrk disk is correctly handled
    
    if mountediskid != "nul" {
        
        let desc = DADiskCopyDescription(disk) as! [String: CFTypeRef]
        
        if  desc["DAMediaName"]! as! String == "EFI System Partition" {
            
            if desc["DAVolumeName"]! as! String != "EFI" {
                DispatchQueue.main.async {
                    nc.post(name: Notification.Name("JustMounted"), object: nil, userInfo: ["JustMounted": mountediskid])
                }
            } else {
                
                if   iMustRename {
                    let name = "EFI-\(String((desc["DADeviceModel"]! as! String).uppercased().trimmingCharacters(in: .whitespacesAndNewlines).removeWhitespace().prefix(5)))" + String(Int.random(in: 1..<99))
                    DADiskRename(disk, name as CFString, 0x00000000, PostAfterRename, nil)
                    
                }
            }
            UserDefaults.standard.setValue(true, forKey: "Rename")
        }
    }
    
    return nil
    
}

func approveDiskUnmount(_ disk: DADisk, _ context: UnsafeMutableRawPointer?) -> Unmanaged<DADissenter>? {
    
    
    let nulvalue = "nul"
    let cstr = (nulvalue as NSString).utf8String
    let getDiskBSDNAME = DADiskGetBSDName(disk) ?? cstr
    let mountediskid = String(cString: getDiskBSDNAME!) // #FIXME check if unmounting .dmg or netowrk disk is correctly handled
    
    if mountediskid != "nul" {
        let desc = DADiskCopyDescription(disk) as! [String: CFTypeRef]
        
        
        if  desc["DAMediaName"]! as! String == "EFI System Partition" {
            
            DispatchQueue.main.async {
                nc.post(name: Notification.Name("JustUnmounted"), object: nil, userInfo: ["JustUnmounted": mountediskid])
            }
            
        }
        
    }
    
    return nil
}

// func approveMount() -> Bool {
//    let localAuthenticationContext = LAContext()
//    var permission : Bool = false
//    localAuthenticationContext.localizedFallbackTitle = "Enter Password to unlock disk"
//    var error: NSError?
//    if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
//        let reason = "unlock disk"
//        localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason ) { success, error in
//            if success {
//                permission = true
//            } else {
//                print(error?.localizedDescription ?? "Failed to authenticate")
//            }
//        }
//    } else {
//        print(error?.localizedDescription ?? "Can't evaluate policy")
//    }
//    print("Returning value.")
//    return permission
// }

//
// func MounDisk(_ diskid: String) {
//    
//    
//    let disk = DADiskCreateFromBSDName(kCFAllocatorDefault, session!, diskid)!
//    
//    DADiskMount(disk, nil, DADiskMountOptions(kDADiskMountOptionDefault), DiskMountCallback, nil)
//    
// }
//
//
//
// func DiskMountCallback(_ diskRef: DADisk?, _ dissenter: DADissenter?, _ context: UnsafeMutableRawPointer?) {
//    
//    print("Disk Mounted")
//    
//    
// }

func mountEFI(UUID: String, NAME: String, user: String, pwd: String) -> String {
    UserDefaults.standard.setValue(false, forKey: "Rename")
    var mountedEFIName = ""
    let disk = DADiskCreateFromBSDName(kCFAllocatorDefault, session!, "/dev/\(UUID)")!
    
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
    
    //
    //    let nulvalue = "nul"
    //    let cstr = (nulvalue as NSString).utf8String
    //    let getDiskBSDNAME = DADiskGetBSDName(disk) ?? cstr
    //    let mountediskid = String(cString : getDiskBSDNAME!)
    DispatchQueue.main.async {
        nc.post(name: Notification.Name("JustMounted"), object: nil, userInfo: ["JustMounted": "nil"])
    }
    
}
