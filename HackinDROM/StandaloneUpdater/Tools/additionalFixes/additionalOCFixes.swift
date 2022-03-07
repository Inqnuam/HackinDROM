//
//  additionalOCFixes.swift
//  HackinDROM
//
//  Created by lian on 23/02/2022.
//  Copyright © 2022 Inqnuam. All rights reserved.
//

import Foundation

// fixingPlist = updated config.plist based on user's old config.plist
// refPlist = user's old config.plist which is used for additional tweaks
func additionalOCFixes(fixingPlist: HAPlistStruct, refPlist: HAPlistStruct)-> HAPlistStruct {
    var fixingPlist = fixingPlist
    
    
    // by defaut SampleCustom.plist (config.plist) provides PlatformNVRAM, Memory, SMBIOS, DataHub etc.
    // there are user who use them but others don't
    // we check and remove when they are not used
    fixPossibleExtraItems(&fixingPlist, refPlist)
    
    // Fix for duplicated UIScale value
    // if UIScale is set as NVRAM variable then we disable UIScale in UEFI > Output
    if refPlist.get(["NVRAM", "Add", "4D1EDE05-38C7-4A6A-9CC6-4BCCA8B38C14", "UIScale"]) != nil{
        fixingPlist.set(HAPlistStruct(name:"UIScale", StringValue: "-1", type: "int"), to: ["UEFI", "Output", "UIScale"])
    }
    
    // Fix NVRAM Add fields for csr-active-config and nvda_drv when they are set without values
    if let nvramAdd = fixingPlist.get(["NVRAM", "Add", "7C436110-AB2A-4BBB-A880-FE41995C9F82"]) {
       for item in nvramAdd.Childs {
            if item.type == "data" {
                if item.name == "csr-active-config" {
                    if item.StringValue.isEmpty {
                        fixingPlist.set(HAPlistStruct(StringValue:"00000000"), to: ["NVRAM", "Add", "7C436110-AB2A-4BBB-A880-FE41995C9F82", "csr-active-config"])
                    }
                } else if item.name == "nvda_drv" {
                    if item.StringValue.isEmpty {
                       fixingPlist.remove(["NVRAM", "Add", "7C436110-AB2A-4BBB-A880-FE41995C9F82", "nvda_drv"])
                    }
                }
            }
        }
    }
    
    // EnableSafeModeSlide must be used with ProvideCustomSlide
    // if EnableSafeModeSlide is enabled we check and enable ProvideCustomSlide
    if let booterQuirks = fixingPlist.get(["Booter", "Quirks"]) {
        if let enableSafeModeSlide = booterQuirks.get(["EnableSafeModeSlide"]) {
            if enableSafeModeSlide.BoolValue {
                fixingPlist.set(HAPlistStruct(BoolValue: true), to: ["Booter", "Quirks", "ProvideCustomSlide"])
            }
        }
    }
    
    
    fixKeySupport(&fixingPlist)
    
    
    // Enable and import OpenRuntime.efi if it is required
    if requiresOpenRuntimeEfi(fixingPlist) {
        if let fixedDrivers = fixOpenRuntimeEfiDriver(fixingPlist) {
            fixingPlist.set(fixedDrivers, to: ["UEFI", "Drivers"])
        }
    }
   

    // TODO: ask to the community about this
    // check config.plist file entires for AMLs, Kexts, Drivers and Tools
    // if no file is present in EFI folder then remove these entries from config.plist
    // or if they are enabled then download them
    // END
    
    
    
    // When plist loads into the app white spaces and ',' are removed from 'Path' fields
    // Here we remove them too from real file names
    // otherwise an error will be thrown by ocvalidate
    fixOCFilePathErrors()
    return fixingPlist
}

