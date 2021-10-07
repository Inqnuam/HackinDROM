//
//  updateOCPlist.swift
//  updateOCPlist
//
//  Created by Inqnuam on 13/08/2021.
//  Copyright © 2021 HackitALL. All rights reserved.
//

import Foundation

func updateOCPlist(_ reference: HAPlistStruct, _ findIn: HAPlistStruct) -> HAPlistStruct {
    
    var returningItem = HAPlistStruct()
    
    if reference.type == "string" || reference.type == "bool" || reference.type == "int" || reference.type == "data" {
        
        if reference.type == findIn.type {
            
            returningItem = findIn
            //  #FIXME Create an external function to handle custom vlues when the type is the same but accepted values are different from older version
            // If possible check authorized values in OC documentation -> failsafe value is used when old value isnt supported anymore
        } else {
            returningItem = reference
            
            // Not sur about next 2 lines
            returningItem.StringValue = ""
            returningItem.BoolValue = false
        }
        
        if returningItem.name == "Comment" {
            returningItem.StringValue.removeAll(where: {$0.asciiValue == nil})
        }
        
    }
    else if reference.type == "dict" && reference.type == findIn.type {
        
        returningItem.type = "dict"
        returningItem.name = findIn.name
        returningItem.ParentName = findIn.ParentName
        
        
        
        if (returningItem.name == "Add" || returningItem.name == "Delete") && returningItem.ParentName == "DeviceProperties" {
            returningItem.Childs = findIn.Childs
        } else  if (returningItem.name == "Add" || returningItem.name == "Delete" || returningItem.name == "LegacySchema") && returningItem.ParentName == "NVRAM" {
            returningItem.Childs = findIn.Childs
        }
        else {
            
            for item in reference.Childs {
                
                
                if let foundIndex = findIn.Childs.firstIndex(where: {$0.name == item.name}) {
                    
                    returningItem.Childs.append(updateOCPlist(item, findIn.Childs[foundIndex]))
                } else {
                    if item.name == "Arch" && item.type == "string" && (reference.ParentName == "Add" || reference.ParentName == "Block" || reference.ParentName == "Force" || reference.ParentName == "Patch") && (item.StringValue == "x86_64" || item.StringValue == "i386") {
                        var child = item
                        child.StringValue = "Any"
                        returningItem.Childs.append(child)
                    } else {
                        returningItem.Childs.append(item)
                    }
                    
                }
                
                
            }
        }
    }
    else if reference.type == "array" && reference.type == findIn.type {
        
        returningItem.type = "array"
        returningItem.name = findIn.name
        returningItem.ParentName = findIn.ParentName
        if !findIn.Childs.isEmpty {
            
            // Trying to create Template from Reference file
            let template = reference.Childs.isEmpty ? HAPlistStruct() : reference.Childs.first!
                      
            for item in findIn.Childs {
                if template.type.isEmpty {
                    returningItem.Childs.append(item)
                } else {
                    returningItem.Childs.append(updateOCPlist(template, item))
                }
 
            }
        }
        
    }
    
    return returningItem
}
