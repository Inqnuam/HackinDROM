//
//  fixKeySupport.swift
//  HackinDROM
//
//  Created by lian on 02/03/2022.
//

import Foundation

func fixKeySupport(_ fixingPlist: inout HAPlistStruct){
    guard  let allDrivers = fixingPlist.get(["UEFI", "Drivers"]), let keySupport = fixingPlist.get(["UEFI", "Input", "KeySupport"])  else {return}
    
    let openUsbKbDxeIndex = allDrivers.Childs.firstIndex(where: { par in
        par.Childs.firstIndex(where: {$0.StringValue == "OpenUsbKbDxe.efi" }) != nil
        
    })
    
    
    let ps2KeyboardDxeIndex = allDrivers.Childs.firstIndex(where: { par in
        par.Childs.firstIndex(where: {$0.StringValue == "Ps2KeyboardDxe.efi" }) != nil
        
    })
    
    var ps2KeyboardIsEnabled: Bool {
        if ps2KeyboardDxeIndex != nil {
            if let enabled = allDrivers.get([ps2KeyboardDxeIndex!, "Enabled"]) {
                return enabled.BoolValue
            }
        }
        return false
    }
    
    var openUsbKbDxeIsEnabled: Bool {
        if openUsbKbDxeIndex != nil {
            if let enabled = allDrivers.get([openUsbKbDxeIndex!, "Enabled"]) {
                return enabled.BoolValue
            }
        }
        return false
    }
    
    // if KeySupport is Enabled but Ps2KeyboardDxe is not and user has OpenUsbKbDxe in Drivers list
    // then we ensure that OpenUsbKbDxe is Disabled as they should never be used together
    if keySupport.BoolValue && !ps2KeyboardIsEnabled {
        if openUsbKbDxeIndex != nil {
            fixingPlist.set(HAPlistStruct(BoolValue: false), to: ["UEFI", "Drivers", openUsbKbDxeIndex!, "Enabled"])
        }
        
    } else if !keySupport.BoolValue && ps2KeyboardIsEnabled {
        // if Ps2KeyboardDxe is Enabled but KeySupport is not
        if openUsbKbDxeIsEnabled {
            // then disable Ps2Keyboard
            if ps2KeyboardDxeIndex != nil {
                fixingPlist.set(HAPlistStruct(BoolValue: false), to: ["UEFI", "Drivers", ps2KeyboardDxeIndex!, "Enabled"])
            }
        } else {
            // Ps2KeyboardDxe should be used with KeySupport so we enable it
            fixingPlist.set(HAPlistStruct(BoolValue: true), to: ["UEFI", "Input", "KeySupport"])
        }
    }
}
