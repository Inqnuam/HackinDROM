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
        if let openCanopy = allDrivers.Childs.first(where: { par in
            par.Childs.firstIndex(where: {$0.StringValue == "OpenCanopy.efi" }) != nil
            
        }) {
            if let enabled = openCanopy.get(["Enabled"]) {
                return enabled.BoolValue
            } else {return false}
        } else {return false}
    }
    
    if openCanopyIsUsed && pickerMode.StringValue != "External" {
        fixingPlist.set(HAPlistStruct(StringValue: "External"), to: ["Misc", "Boot", "PickerMode"])
    }
}
