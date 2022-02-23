//
//  getHAPlist.swift
//  getHAPlist
//
//  Created by Inqnuam on 13/08/2021.
//  Copyright © 2021 HackitALL. All rights reserved.
//

import Foundation

func getHAPlistFrom(_ FilePath: String, completion: @escaping(HAPlistStruct)->()) {
    var analyzedstruct = HAPlistStruct(name:"Root")
    if FilePath != "nul" {
        //  var config:Data?
        
        let filesRawData = fileManager.contents(atPath: FilePath) ?? nil
        
        if filesRawData != nil {
            do {
                
                let pListObject = try PropertyListSerialization.propertyList(from: filesRawData!, options: PropertyListSerialization.ReadOptions(), format: nil)
                
                
                if let pListDict = pListObject as? [String: AnyObject] {
                    
                    
                    
                    analyzedstruct = HAPlistConstructor(pListDict, HAPlistStruct(type:"dict"))
                    completion(analyzedstruct)
                    
                    
                }
                
            } catch {
                
                print(error)
            }
            
        }
    }
    
}


func HAPlistConstructor(_ item: [String: AnyObject], _ parent:HAPlistStruct) -> HAPlistStruct {
    
    var OCSecondChildItems = parent
    
    // #FIXME: really ? :( a better implementation is needed
    // use switch statement
    // check by NS type value and not by string describing
    // ex:
    //    if MiniChild.value is String {
    //        print(MiniChild.value, "is String")
    //    }
    
    
    for MiniChild in item {
        
        var MiniChilItem = HAPlistStruct()
        
        
        let MiniChildType = String(describing: type(of: MiniChild.value) as Any)
        
        MiniChilItem.name = MiniChild.key
        MiniChilItem.ParentName = parent.name.isEmpty ? parent.ParentName : parent.name
        
        
        if MiniChildType == "__NSCFBoolean" {
            MiniChilItem.type = "bool"
            MiniChilItem.BoolValue = MiniChild.value as! Bool
        } else if MiniChildType == "NSTaggedPointerString" || MiniChildType == "__NSCFString" || MiniChildType ==  "__NSCFConstantString" {
            MiniChilItem.StringValue = MiniChild.value as! String
            MiniChilItem.type = "string"
            
        } else if MiniChildType == "__NSCFNumber" {
            
            MiniChilItem.StringValue = String(MiniChild.value as! Int)
            MiniChilItem.type = "int"
            
        } else if MiniChildType == "__NSCFData" {
            
            let DataRawValue = MiniChild.value as! Data
            MiniChilItem.StringValue = DataRawValue.hexEncodedString()
            MiniChilItem.type = "data"
            
        }
        else if MiniChildType == "__NSDictionaryM" || MiniChildType == "__NSDictionaryI" {
            
            if let OCSecondChild = item[MiniChild.key] as? [String: AnyObject] {
                MiniChilItem.type = "dict"
                MiniChilItem.Childs = HAPlistConstructor(OCSecondChild, MiniChilItem).Childs
                
            }
        }
        else if MiniChildType == "__NSArrayM" || MiniChildType == "__NSArray0" {
            MiniChilItem.type = "array"
            
            if let arrayItems = item[MiniChild.key] as? [[String: AnyObject]] {
                
                
                for OCSecondChild in arrayItems {
                    
                    let microchild = HAPlistConstructor(OCSecondChild, HAPlistStruct(type:"dict", ParentName: MiniChilItem.name))
                    
                    
                    MiniChilItem.Childs.append(microchild)
                }
            } else if let OCSecondChilds = item[MiniChild.key] as? [String] {
                
                
                for StringItem in OCSecondChilds {
                    
                    
                    MiniChilItem.Childs.append(HAPlistStruct(name: MiniChild.key, StringValue: StringItem, isOn: !StringItem.hasPrefix("#"), type: "string", ParentName: MiniChilItem.ParentName))
                    
                }
            }
            
            
        }
        
        
        OCSecondChildItems.Childs.append(MiniChilItem)
    }
    
    if OCSecondChildItems.type == "dict"{
        
        
        OCSecondChildItems.Childs.sort(by: { $0.name < $1.name })
        
        
    }
    
    return OCSecondChildItems
}
