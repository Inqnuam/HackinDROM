//
//  PlistAnalyzer.swift
//  HackinDROM
//
//  Created by Inqnuam 22/04/2021.
//  Copyright © 2021 HackinDROM. All rights reserved.
//

import Foundation
import Scout

struct HAPlistStruct: Identifiable, Equatable {
    var id = UUID()
    var name = ""
    var StringValue: String = "" {
        
        
        didSet(oldValue) {
            
            if type == "int" {
                
                var  filtered = StringValue.filter { $0.isNumber }
                
                if StringValue.contains("-") {
                    filtered.insert("-", at: filtered.startIndex)
                }
                
                StringValue = filtered
                
                
            } else if type == "data" {
                if StringValue.uppercased().filter({ "ABCDEF0123456789".contains($0) }).data(using: .bytesHexLiteral) != nil {
                    StringValue = StringValue.uppercased().filter { "ABCDEF0123456789".contains($0) }
                    
                }
            } else if type == "string" && name == "Comment" {
                StringValue.removeAll(where: {$0.asciiValue == nil})
            }
        }
    }
    var BoolValue: Bool = false
    var type = ""
    var ParentName = ""
    var Childs: [HAPlistStruct] = []
    var isEditing: Bool = false
    var isShowing: Bool = false
    var isOn: Bool = false
    var customName: String {
        var newVal = ""
        if let indeX = Childs.firstIndex(where: {$0.type == "string" && $0.name == "Path"}) {
            newVal = Childs[indeX].StringValue.replacingOccurrences(of: ".aml", with: "", options: .caseInsensitive).replacingOccurrences(of: ".efi", with: "", options: .caseInsensitive)
        } else if let indeX = Childs.firstIndex(where: {$0.type == "string" && $0.name == "BundlePath"}) {
            newVal = Childs[indeX].StringValue.replacingOccurrences(of: ".kext", with: "", options: .caseInsensitive)
        } else if let indeX = Childs.firstIndex(where: {$0.type == "string" && $0.name == "Comment"}) {
            newVal = Childs[indeX].StringValue
        }
        
        return newVal
    }
    
}





func cleanHAPlistStruct(_ originalItem: HAPlistStruct) -> HAPlistStruct {
    
    var cleanItem = originalItem
    cleanItem.id = UUID()
    if cleanItem.type == "int" {
        cleanItem.StringValue = "0"
    } else {
        cleanItem.StringValue = ""
    }
    
    if cleanItem.name == "Enabled"{
        cleanItem.BoolValue = true
    } else {
        cleanItem.BoolValue = false
    }
    
    for indeX in cleanItem.Childs.indices {
        
        
        cleanItem.Childs[indeX] = cleanHAPlistStruct(cleanItem.Childs[indeX])
    }
    return cleanItem
}






func createScoutExplValfromHDDict(hdItem: HAPlistStruct) -> ExplorerValue {
    
    var scoutExplVal: ExplorerValue = [:]
    
    if hdItem.type == "string" {
        
        return .string(hdItem.StringValue)
        
    } else if hdItem.type == "bool" {
        
        return .bool(hdItem.BoolValue)
        
    } else if hdItem.type == "int" {
        
        return .int(Int(hdItem.StringValue)!)
        
    }  else if hdItem.type == "data" {
        
        
        if let HexToData =   Data(hexString: hdItem.StringValue) {
            return .data(HexToData)
        } else {
            return .data(Data())
        }
        
    } else if hdItem.type == "dict" {
        
        
        for itm in hdItem.Childs {
            
            
            do {
                try  scoutExplVal.add(createScoutExplValfromHDDict(hdItem: itm), at: PathElement(stringLiteral: itm.name))
                
            } catch {
                print(error)
            }
        }
        
        
    } else if hdItem.type == "array" {
        
        var scoutarray:ExplorerValue = []
        for (n, itm) in hdItem.Childs.enumerated() {
            
            try! scoutarray.add(createScoutExplValfromHDDict(hdItem: itm), at: PathElement(integerLiteral: n))
            
        }
        return scoutarray
    }
    
    
    return scoutExplVal
}

struct HAPMultiOptions:Identifiable, Hashable {
    var id = UUID()
    var value: Int
    var isSelected:Bool
    var info: String
}
func calculateSelected(_ somme: Int, _ possibleNumbers:[HAPMultiOptions])-> [HAPMultiOptions] {
    var possibleNumbers = possibleNumbers
    var selectedOptions: [HAPMultiOptions] = []

    var sommeOfSelectedOptions:Int = 0
    
    while !possibleNumbers.isEmpty && somme != sommeOfSelectedOptions {
        
        if  somme - possibleNumbers.last!.value >= 0 && somme >= sommeOfSelectedOptions + possibleNumbers.last!.value {
            selectedOptions.append(possibleNumbers.last!)
            sommeOfSelectedOptions = sommeOfSelectedOptions + possibleNumbers.last!.value
            possibleNumbers = possibleNumbers.dropLast()
        } else {
            possibleNumbers = possibleNumbers.dropLast()
        }
       
        
    }
    return selectedOptions
}
