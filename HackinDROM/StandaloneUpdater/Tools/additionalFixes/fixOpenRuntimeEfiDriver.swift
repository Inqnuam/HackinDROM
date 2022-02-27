//
//  fixOpenRuntimeEfiDriver.swift
//  HackinDROM
//
//  Created by lian on 27/02/2022.
//

import Foundation


func fixOpenRuntimeEfiDriver(_ fixingPlist: HAPlistStruct)-> HAPlistStruct? {
    guard var allDrivers = fixingPlist.get(["UEFI", "Drivers"]) else {return nil}
    if let openRuntimeDriverIndex = allDrivers.Childs.firstIndex(where: { drive in
        drive.Childs.first(where: {$0.name == "Path" && $0.StringValue.lowercased() == "openruntime.efi"}) != nil
    }) {
        
        allDrivers.set(HAPlistStruct(BoolValue: true), to: [openRuntimeDriverIndex, "Enabled"])
        allDrivers.set(HAPlistStruct(StringValue: "OpenRuntime.efi"), to: [openRuntimeDriverIndex, "Path"])
        
    } else {
        allDrivers.Childs.append(generateNewDriverStructType(driverPath: "OpenRuntime.efi"))
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
