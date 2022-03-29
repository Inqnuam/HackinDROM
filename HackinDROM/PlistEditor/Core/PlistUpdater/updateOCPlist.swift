//
//  updateOCPlist.swift
//  updateOCPlist
//
//  Created by Inqnuam on 13/08/2021.
//  Copyright © 2021 HackitALL. All rights reserved.
//

import Foundation


// Character Set is faster than regex
let ocValidCharacters: Set<Character> = .init("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_./\\")
// reference = SampleCustom.plist
// findIn = user's config.plist
func updateOCPlist(_ reference: HAPlistStruct, _ findIn: HAPlistStruct) -> HAPlistStruct {
    
    var returningItem = HAPlistStruct()
    
    if reference.type == "string" || reference.type == "bool" || reference.type == "int" || reference.type == "data" {
        
        
        if reference.type == findIn.type {
            returningItem = findIn
            //  #FIXME: Create an external function to handle custom vlues when the type is the same but accepted values are different from older version
            // If possible check authorized values in OC documentation -> failsafe value is used when old value isnt supported anymore
        } else {
            returningItem = getValueWhenTypeDiffers(reference, findIn)
        }
        
        if returningItem.name == "Comment" {
            returningItem.stringValue.removeAll(where: {$0.asciiValue == nil})
        }
        
        if returningItem.type == "string" && (returningItem.name == "Path" || returningItem.name == "BundlePath") {
            returningItem.stringValue = returningItem.stringValue.filter{ocValidCharacters.contains($0)}
        }
        
    }
    else if reference.type == "dict" && reference.type == findIn.type {
        
        returningItem.type = "dict"
        returningItem.name = findIn.name
        returningItem.parentName = findIn.parentName
        
        
        if returningItem.parentName == "DeviceProperties" && (returningItem.name == "Add" || returningItem.name == "Delete") {
            returningItem.childs = findIn.childs
            
            // fix borked PCI path error
            for (ind, itm) in returningItem.childs.enumerated() {
                returningItem.childs[ind].name = itm.name.removeWhitespace()
                
            }
        } else  if returningItem.parentName == "NVRAM" && (returningItem.name == "Add" || returningItem.name == "Delete" || returningItem.name == "LegacySchema") {
            returningItem.childs = findIn.childs
        }
        else {
            
            for item in reference.childs {
                if let foundIndex = findIn.childs.firstIndex(where: {$0.name == item.name}) {
                    returningItem.childs.append(updateOCPlist(item, findIn.childs[foundIndex]))
                } else {
                    if item.name == "Arch" && item.type == "string" && (reference.parentName == "Add" || reference.parentName == "Block" || reference.parentName == "Force" || reference.parentName == "Patch") && (item.stringValue == "x86_64" || item.stringValue == "i386") {
                        var child = item
                        child.stringValue = "Any"
                        returningItem.childs.append(child)
                    }
                    else {
                        returningItem.childs.append(item)
                    }
                    
                }
            }
        }
    }
    else if reference.type == "array" && reference.type == findIn.type {
        
        returningItem.type = "array"
        returningItem.name = findIn.name
        returningItem.parentName = findIn.parentName
        if !findIn.childs.isEmpty {
            
            // Trying to create Template from Reference file
            let template = reference.childs.isEmpty ? HAPlistStruct() : reference.childs.first!
            for item in findIn.childs {
                if template.type.isEmpty {
                    returningItem.childs.append(item)
                } else {
                    if template.parentName == "Drivers" && item.type == "string" {
                        
                        let newDriverStruct =  generateNewDriverStructType(template: template, driverPath: item.stringValue)
                        returningItem.childs.append(newDriverStruct)
                    } else {
                        returningItem.childs.append(updateOCPlist(template, item))
                    }
                }
            }
        }
    }
    return returningItem
}


