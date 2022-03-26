//
//  getValueWhenTypeDiffers.swift
//  HackinDROM
//
//  Created by lian on 28/02/2022.
//

import Foundation

func getValueWhenTypeDiffers(_ reference: HAPlistStruct, _ findIn: HAPlistStruct) -> HAPlistStruct {
    var returningItem = reference
    
    if reference.name == "GopPassThrough" && reference.parentName == "Output" {
        if findIn.type == "bool" && findIn.boolValue {
            returningItem.stringValue = "Enabled"
            
        } else {
            returningItem.stringValue = "Disabled"
        }
    }
    return returningItem
}
