//
//  fixOpenRuntimeEfiDriver.swift
//  HackinDROM
//
//  Created by lian on 27/02/2022.
//

import Foundation


func fixOpenRuntimeEfiDriver(_ fixingPlist: HAPlistStruct)-> HAPlistStruct? {
    guard var allDrivers = fixingPlist.get(["UEFI", "Drivers"]) else {return nil}
    if let openRuntimeDriverIndex = allDrivers.childs.firstIndex(where: { drive in
        drive.childs.first(where: {$0.name == "Path" && $0.stringValue.lowercased() == "openruntime.efi"}) != nil
    }) {
        
        allDrivers.set(HAPlistStruct(boolValue: true), to: [openRuntimeDriverIndex, "Enabled"])
        allDrivers.set(HAPlistStruct(stringValue: "OpenRuntime.efi"), to: [openRuntimeDriverIndex, "Path"])
        
    } else {
        allDrivers.childs.append(generateNewDriverStructType(driverPath: "OpenRuntime.efi"))
    }
    
    let fileDir = standaloneUpdateDir + "/EFI/OC/Drivers/OpenRuntime.efi"
    if !fileManager.fileExists(atPath: fileDir) {
        
        do {
            try fileManager.copyItem(atPath:  latestOCFolder + "/X64/EFI/OC/Drivers/OpenRuntime.efi", toPath: fileDir)
        } catch {
            print(error)
        }
    }
    return allDrivers
}
