//
//  fixPickerMode.swift
//  HackinDROM
//
//  Created by lian on 07/03/2022.
//

import Foundation

func fixPickerMode(_ fixingPlist: inout HAPlistStruct) {
    guard let allDrivers = fixingPlist.get(["UEFI", "Drivers"]), let pickerMode = fixingPlist.get(["Misc", "Boot", "PickerMode"])  else {return}
    
    var openCanopyIsUsed: Bool {
        if let openCanopy = allDrivers.childs.first(where: { par in
            par.childs.firstIndex(where: {$0.stringValue == "OpenCanopy.efi" }) != nil
            
        }) {
            if let enabled = openCanopy.get(["Enabled"]) {
                return enabled.boolValue
            } else {return false}
        } else {return false}
    }
    
    if openCanopyIsUsed && pickerMode.stringValue != "External" {
        fixingPlist.set(HAPlistStruct(stringValue: "External"), to: ["Misc", "Boot", "PickerMode"])
    }
}
