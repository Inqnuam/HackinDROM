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
    var BoolValue: Bool = false, isEditing: Bool = false, isShowing: Bool = false, isOn: Bool = false
    var type = ""
    var ParentName = ""
    var Childs: [HAPlistStruct] = []
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

struct AnyEncodable: Encodable {

    private let _encode: (Encoder) throws -> Void
    public init<T: Encodable>(_ wrapped: T) {
        _encode = wrapped.encode
    }

    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}
func createDictFrom(_ hap: HAPlistStruct) {

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

