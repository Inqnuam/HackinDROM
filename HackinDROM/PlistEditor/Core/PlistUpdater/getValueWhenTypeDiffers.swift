//
//  getValueWhenTypeDiffers.swift
//  HackinDROM
//
//  Created by lian on 28/02/2022.
//

import Foundation

func getValueWhenTypeDiffers(_ reference: HAPlistStruct, _ findIn: HAPlistStruct) -> HAPlistStruct {
    var returningItem = reference
    
    if reference.name == "GopPassThrough" && reference.ParentName == "Output" {
        if findIn.type == "bool" && findIn.BoolValue {
            returningItem.StringValue = "Enabled"
            
        } else {
            returningItem.StringValue = "Disabled"
        }
    }
    return returningItem
}
