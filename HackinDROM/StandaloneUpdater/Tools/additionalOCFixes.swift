//
//  additionalOCFixes.swift
//  HackinDROM
//
//  Created by lian on 23/02/2022.
//  Copyright © 2022 Inqnuam. All rights reserved.
//

import Foundation

let possibleExtraItems:[[String]] = [
    ["PlatformInfo", "PlatformNVRAM"],
    ["PlatformInfo", "Memory"],
    ["PlatformInfo", "SMBIOS"],
    ["PlatformInfo", "DataHub"]
]

func additionalOCFixes(fixingPlist: HAPlistStruct, refPlist: HAPlistStruct)-> HAPlistStruct {
    var fixingPlist = fixingPlist
    
    for item in possibleExtraItems {
        if refPlist.get(item) == nil {
            fixingPlist.remove(item)
        }
    }
    
    // Fix for duplicated UIScale value
    if refPlist.get(["NVRAM", "Add", "4D1EDE05-38C7-4A6A-9CC6-4BCCA8B38C14", "UIScale"]) != nil{
        fixingPlist.set(HAPlistStruct(name:"UIScale", StringValue: "-1", type: "int"), to: ["UEFI", "Output", "UIScale"])
    }
    
    if let booterQuirks = fixingPlist.get(["Booter", "Quirks"]) {
        
        if let enableSafeModeSlide = booterQuirks.get(["EnableSafeModeSlide"]) {
            
            if enableSafeModeSlide.BoolValue {
                fixingPlist.set(HAPlistStruct(BoolValue: true), to: ["Booter", "Quirks", "ProvideCustomSlide"])
            }
        }
    }
    
    if let keySupport = fixingPlist.get(["UEFI", "Input", "KeySupport"]) {
        
        if keySupport.BoolValue {
            
            if let allDrivers = fixingPlist.get(["UEFI", "Drivers"]) {
                
               
                if let openUsbKbDxeParentIndex = allDrivers.Childs.firstIndex(where: { par in
                    par.Childs.firstIndex(where: {$0.StringValue == "OpenUsbKbDxe.efi" }) != nil
                    
                }) {
                    fixingPlist.set(HAPlistStruct(BoolValue: false), to: ["UEFI", "Drivers", openUsbKbDxeParentIndex, "Enabled"])
                    
                    
                }
            }
        }
    }
    
    fixOCFilePathErrors()
    return fixingPlist
}


func fixOCFilePathErrors() {
    
    if let allKextFiles = try? fileManager.contentsOfDirectory(atPath: standaloneUpdateDir + "/EFI/OC/Kexts") {
        
        
        for kext in allKextFiles {
            
            if kext.contains(",") || kext.contains(" ") {
                
                do {
                    try fileManager.moveItem(atPath: standaloneUpdateDir + "/EFI/OC/Kexts/\(kext)", toPath: standaloneUpdateDir + "/EFI/OC/Kexts/\(kext.removeWhitespace().replacingOccurrences(of: ",", with: "_"))")
                } catch {
                    print(error)
                }
            }
        }
    }
    
    
    if let allAMLFiles = try? fileManager.contentsOfDirectory(atPath: standaloneUpdateDir + "/EFI/OC/ACPI") {
        
        
        for aml in allAMLFiles {
            
            if aml.contains(",") || aml.contains(" ") {
                
                do {
                    try fileManager.moveItem(atPath: standaloneUpdateDir + "/EFI/OC/ACPI/\(aml)", toPath: standaloneUpdateDir + "/EFI/OC/ACPI/\(aml.removeWhitespace().replacingOccurrences(of: ",", with: "_"))")
                } catch {
                    print(error)
                }
            }
        }
    }
    
    
    if let allDriversFiles = try? fileManager.contentsOfDirectory(atPath: standaloneUpdateDir + "/EFI/OC/Drivers") {
        
        
        for driver in allDriversFiles {
            
            if driver.contains(",") || driver.contains(" ") {
                
                do {
                    try fileManager.moveItem(atPath: standaloneUpdateDir + "/EFI/OC/Drivers/\(driver)", toPath: standaloneUpdateDir + "/EFI/OC/Drivers/\(driver.removeWhitespace().replacingOccurrences(of: ",", with: "_"))")
                } catch {
                    print(error)
                }
            }
        }
    }
    
}
