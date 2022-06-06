//
//  PlistAnalyzer.swift
//  HackinDROM
//
//  Created by Inqnuam 22/04/2021.
//  Copyright © 2021 HackinDROM. All rights reserved.
//

import Foundation

struct HAPlistStruct: Identifiable, Equatable {
    var id = UUID()
    var name = ""
    var stringValue: String = "" {
        didSet(oldValue) {
            if type == "int" {
                var  filtered = stringValue.filter { $0.isNumber }
                if stringValue.contains("-") {
                    filtered.insert("-", at: filtered.startIndex)
                }
                stringValue = filtered
            } else if type == "data" {
                let dataString = stringValue.uppercased().filter({ "ABCDEF0123456789".contains($0) })
                if dataString.data(using: .bytesHexLiteral) != nil {
                    stringValue = dataString
                }
            } else if type == "string" && name == "Comment" {
                stringValue.removeAll(where: {$0.asciiValue == nil})
            }
        }
    }
    var boolValue: Bool = false, isEditing: Bool = false, isShowing: Bool = false, isOn: Bool = false
    var type:String = "", parentName:String = ""
    var childs: [HAPlistStruct] = []
    var customName: String {
        var newVal = ""
        if let indeX = childs.firstIndex(where: {$0.type == "string" && $0.name == "Path"}) {
            newVal = childs[indeX].stringValue.replacingOccurrences(of: ".aml", with: "", options: .caseInsensitive).replacingOccurrences(of: ".efi", with: "", options: .caseInsensitive)
        } else if let indeX = childs.firstIndex(where: {$0.type == "string" && $0.name == "BundlePath"}) {
            newVal = childs[indeX].stringValue.replacingOccurrences(of: ".kext", with: "", options: .caseInsensitive)
        } else if let indeX = childs.firstIndex(where: {$0.type == "string" && $0.name == "Comment"}) {
            newVal = childs[indeX].stringValue
        }
        return newVal
    }
    
}





func cleanHAPlistStruct(_ originalItem: HAPlistStruct) -> HAPlistStruct {
    
    var cleanItem = originalItem
    cleanItem.id = UUID()
    if cleanItem.type == "int" {
        cleanItem.stringValue = "0"
    } else {
        cleanItem.stringValue = ""
    }
    
    if cleanItem.name == "Enabled"{
        cleanItem.boolValue = true
    } else {
        cleanItem.boolValue = false
    }
    
    for indeX in cleanItem.childs.indices {
        
        
        cleanItem.childs[indeX] = cleanHAPlistStruct(cleanItem.childs[indeX])
    }
    return cleanItem
}

struct AnyEncodable: Encodable {
    
    private let _encode: (Encoder) throws -> Void
    public init<T: Encodable>(_ wrapped: T) {
        _encode = wrapped.encode
    }
    
    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
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

