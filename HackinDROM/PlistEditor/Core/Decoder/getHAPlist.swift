//
//  getHAPlist.swift
//  getHAPlist
//
//  Created by Inqnuam on 13/08/2021.
//  Copyright © 2021 HackitALL. All rights reserved.
//

import Foundation

func getHAPlistFrom(_ filePath: String, completion: @escaping(HAPlistStruct)->()) {
    var analyzedstruct = HAPlistStruct(name:"Root")
    if filePath != "nul" || !filePath.isEmpty {
        //  var config:Data?
        
        let filesRawData = fileManager.contents(atPath: filePath) ?? nil
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

func isNSString(_ t:String) -> Bool {
    if t == "NSTaggedPointerString" || t == "__NSCFString" || t ==  "__NSCFConstantString" {
        return true
    }
    return false
}

func isNSDict(_ t:String) -> Bool {
    if t == "__NSDictionaryM" || t == "__NSDictionaryI" || t == "__NSDictionary0" {
        return true
    }
    return false
}

func isNSArray(_ t:String) -> Bool {
    if t == "__NSArrayM" || t == "__NSArray0" || t == "__NSArrayI" {
        return true
    }
    return false
}

func HAPlistConstructor(_ item: [String: AnyObject], _ parent:HAPlistStruct) -> HAPlistStruct {
    
    var OCSecondChildItems = parent
    
    // #FIXME: really ? :( a better implementation is needed
    // use switch statement
    
    
    for MiniChild in item {
        
        var MiniChilItem = HAPlistStruct()
        
        
        let MiniChildType = String(describing: type(of: MiniChild.value) as Any)
        
        MiniChilItem.name = MiniChild.key
        MiniChilItem.ParentName = parent.name.isEmpty ? parent.ParentName : parent.name
        
        if MiniChildType == "__NSCFBoolean" {
            MiniChilItem.type = "bool"
            MiniChilItem.BoolValue = MiniChild.value as! Bool
        } else if isNSString(MiniChildType) {
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
        else if isNSDict(MiniChildType) {
            
            if let OCSecondChild = item[MiniChild.key] as? [String: AnyObject] {
                MiniChilItem.type = "dict"
                MiniChilItem.Childs = HAPlistConstructor(OCSecondChild, MiniChilItem).Childs
                
            }
        }
        else if isNSArray(MiniChildType) {
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
