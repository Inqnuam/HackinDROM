//
//  EFI.swift
//  HackinDROM
//
//  Created by Inqnuam on 15/12/2021.
//  Copyright © 2021 HackitALL. All rights reserved.
//

import Foundation
import Version


struct EFI: Identifiable, Equatable {
    let id:String = Foundation.UUID().uuidString
    var path: String = ""
    var name: String = ""
    var mounted: String = ""
    var type: String = ""
    var location: String = ""
    var SSD: String = ""
    var UUID: String = ""
    var OC: Bool = false
    var OCv: String = ""
    var parent: String = ""
    var FreeSpace: Int = 0
    var BackUpSize: Int = 0
    var plists: [String] = []
    var isUpdating:Bool = false
    var updateProgress:Double = 0.0
    
    
    func mount() -> String {
       
        var mountedEFIName = ""
        let disk = DADiskCreateFromBSDName(kCFAllocatorDefault, session!, "/dev/\(path)")!
        let IODetPar =  DADiskCopyWholeDisk(disk)
        
        var name = ""
        if IODetPar != nil {
            let ReqDADATAPar = DADiskCopyDescription(IODetPar!)
            let desc2 = ReqDADATAPar as! [String: CFTypeRef]
            name = generateEFIName(desc2)
        }
        
        var output:NSString?
        if launchCommandAsAdmin(path, &output) {
            if output != nil && output!.contains("\(path) mounted") {
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
        let disk = DADiskCreateFromBSDName(kCFAllocatorDefault, session!, "/dev/\(path)")!
        DADiskRename(disk, "EFI" as CFString, 0x00000000, nil, nil)
        DADiskUnmount(disk, DADiskUnmountOptions(forceUnmount ? kDADiskUnmountOptionForce : kDADiskUnmountOptionDefault), PostAfterRename, nil)
    }
    
}

