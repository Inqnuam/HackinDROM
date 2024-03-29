//
//  HAPlistEncoder.swift
//  HackinDROM
//
//  Created by lian on 26/02/2022.
//  Copyright © 2022 Inqnuam. All rights reserved.
//

import Foundation

func haPlistEncode(_ haPlist: HAPlistStruct, _ filePath: String) {
    
    let rawOutput = haPlistEncoder(haPlist)
    
    // remove first empty <key></key> which is genereated at serialization when plist is loaded
    let plistNodes = rawOutput.dropFirst(12)
    
    let fileContent = """
     <?xml version="1.0" encoding="UTF-8"?>
     <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
     <plist version="1.0">\(plistNodes)
     </plist>
     """
    let data = Data(fileContent.utf8)
    
    do {
        let serilizedPlist = try PropertyListSerialization.propertyList(from: data, format: nil)
        let newPlist = try PropertyListSerialization.data(fromPropertyList: serilizedPlist, format: .xml, options:0)
        try newPlist.write(to: URL(fileURLWithPath: filePath), options: .atomic)
    } catch {
        print(error)
    }
}


func haPlistEncoder(_ haPlist: HAPlistStruct, _ parentIsArray: Bool = false) -> String {
    
    var text:String = ""
    
    
    switch haPlist.type {
        case "string":
            
            if parentIsArray {
                text = """
            
                       <string>\(haPlist.stringValue)</string>
            """
            } else {
                text = """
                    
                    <key>\(haPlist.name)</key>
                    <string>\(haPlist.stringValue)</string>
                    """
            }
            break
            
        case "int":
            
            if parentIsArray {
                text = """
            
                       <integer>\(haPlist.stringValue)</integer>
            """
            } else {
                text = """
                    
                    <key>\(haPlist.name)</key>
                    <integer>\(haPlist.stringValue)</integer>
                    """
            }
            break
            
        case "data":
            
            var base64String = ""
            if let base64encoded = haPlist.stringValue.data(using: .bytesHexLiteral)?.base64EncodedString() {
                base64String = base64encoded
                
            }
            if parentIsArray {
                text = """
            
                       <data>\(base64String)</data>
            """
            } else {
                
                text = """
                    
                    <key>\(haPlist.name)</key>
                    <data>\(base64String)</data>
                    """
            }
            break
            
        case "bool":
            if parentIsArray {
                text = """
            
                       \(haPlist.boolValue ? "<true/>" : "<false/>")
            """
            }
            text = """
                    
                    <key>\(haPlist.name)</key>
                    \(haPlist.boolValue ? "<true/>" : "<false/>")
                    """
            break
            
            
        case "dict":
            var dictString:String = ""
            
            if haPlist.childs.isEmpty {
                dictString = "<dict/>"
            } else {
                dictString = "<dict>"
                for pChild in haPlist.childs {
                    
                    dictString += haPlistEncoder(pChild)
                }
                dictString += "</dict>"
            }
            
            if parentIsArray {
                text = """
            
                       \(dictString)
            """
            } else {
                
                text = """
                    
                    <key>\(haPlist.name)</key>
                    \(dictString)
                    """
            }
            break
            
        case "array":
            var arrayString:String = ""
            
            if haPlist.childs.isEmpty {
                arrayString = "<array/>"
            } else {
                arrayString = "<array>"
                
                for pChild in haPlist.childs {
                    
                    arrayString += haPlistEncoder(pChild, true)
                }
                arrayString += "</array>"
                
            }
            
            if parentIsArray {
                text = """
            
                    \(arrayString)
            """
                
            } else {
                text = """
                    
                    <key>\(haPlist.name)</key>
                    \(arrayString)
                    """
            }
            break
        default:
            text = ""
            break
    }
    
    return text
    
}
