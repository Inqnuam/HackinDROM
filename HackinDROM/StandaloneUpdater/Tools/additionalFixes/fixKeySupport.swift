//
//  fixKeySupport.swift
//  HackinDROM
//
//  Created by lian on 02/03/2022.
//

import Foundation

func fixKeySupport(_ fixingPlist: inout HAPlistStruct){
    guard  let allDrivers = fixingPlist.get(["UEFI", "Drivers"]), let keySupport = fixingPlist.get(["UEFI", "Input", "KeySupport"])  else {return}
    
    let openUsbKbDxeIndex = allDrivers.childs.firstIndex(where: { par in
        par.childs.firstIndex(where: {$0.stringValue == "OpenUsbKbDxe.efi" }) != nil
        
    })
    
    
    let ps2KeyboardDxeIndex = allDrivers.childs.firstIndex(where: { par in
        par.childs.firstIndex(where: {$0.stringValue == "Ps2KeyboardDxe.efi" }) != nil
        
    })
    
    var ps2KeyboardIsEnabled: Bool {
        if ps2KeyboardDxeIndex != nil {
            if let enabled = allDrivers.get([ps2KeyboardDxeIndex!, "Enabled"]) {
                return enabled.boolValue
            }
        }
        return false
    }
    
    var openUsbKbDxeIsEnabled: Bool {
        if openUsbKbDxeIndex != nil {
            if let enabled = allDrivers.get([openUsbKbDxeIndex!, "Enabled"]) {
                return enabled.boolValue
            }
        }
        return false
    }
    
    // if KeySupport is Enabled but Ps2KeyboardDxe is not and user has OpenUsbKbDxe in Drivers list
    // then we ensure that OpenUsbKbDxe is Disabled as they should never be used together
    if keySupport.boolValue && !ps2KeyboardIsEnabled {
        if openUsbKbDxeIndex != nil {
            fixingPlist.set(HAPlistStruct(boolValue: false), to: ["UEFI", "Drivers", openUsbKbDxeIndex!, "Enabled"])
        }
        
    } else if !keySupport.boolValue && ps2KeyboardIsEnabled {
        // if Ps2KeyboardDxe is Enabled but KeySupport is not
        if openUsbKbDxeIsEnabled {
            // then disable Ps2Keyboard
            if ps2KeyboardDxeIndex != nil {
                fixingPlist.set(HAPlistStruct(boolValue: false), to: ["UEFI", "Drivers", ps2KeyboardDxeIndex!, "Enabled"])
            }
        } else {
            // Ps2KeyboardDxe should be used with KeySupport so we enable it
            fixingPlist.set(HAPlistStruct(boolValue: true), to: ["UEFI", "Input", "KeySupport"])
        }
    }
}
