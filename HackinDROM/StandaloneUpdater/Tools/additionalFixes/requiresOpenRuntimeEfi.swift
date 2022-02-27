//
//  requiresOpenRuntimeEfi.swift
//  HackinDROM
//
//  Created by lian on 27/02/2022.
//

import Foundation

let configRequiringOpenRuntimeEfi: [[String]] = [
    ["Booter", "Quirks", "ProvideCustomSlide"],
    ["Booter", "Quirks", "DisableVariableWrite"],
    ["Booter", "Quirks", "EnableWriteUnprotector"],
    ["UEFI", "Quirks", "RequestBootVarRouting"],
]

func requiresOpenRuntimeEfi(_ fixingPlist: HAPlistStruct)-> Bool {
    for config in configRequiringOpenRuntimeEfi {
       if let foundItem = fixingPlist.get(config) {
            if foundItem.BoolValue {
                return true
            }
        }
    }
    return false
}
