//
//  fixPossibleExtraItems.swift
//  HackinDROM
//
//  Created by lian on 27/02/2022.
//

import Foundation
let possibleExtraItems:[[String]] = [
    ["PlatformInfo", "PlatformNVRAM"],
    ["PlatformInfo", "Memory"],
    ["PlatformInfo", "SMBIOS"],
    ["PlatformInfo", "DataHub"]
]


func fixPossibleExtraItems(_ fixingPlist: inout HAPlistStruct, _ refPlist: HAPlistStruct) {
    for item in possibleExtraItems {
        if refPlist.get(item) == nil {
            fixingPlist.remove(item)
        }
    }
}
