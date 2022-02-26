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
    let fileContent = """
     <?xml version="1.0" encoding="UTF-8"?>
     <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
     <plist version="1.0">\(rawOutput.dropFirst(12))
     </plist>
     """
    let data = Data(fileContent.utf8)
    
    
    do {
      try data.write(to: URL(fileURLWithPath: filePath))
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
            
                       <string>\(haPlist.StringValue)</string>
            """
            } else {
            text = """
                    
                    <key>\(haPlist.name)</key>
                    <string>\(haPlist.StringValue)</string>
                    """
            }
            break
            
        case "int":
            
            if parentIsArray {
                text = """
            
                       <integer>\(haPlist.StringValue)</integer>
            """
            } else {
            text = """
                    
                    <key>\(haPlist.name)</key>
                    <integer>\(haPlist.StringValue)</integer>
                    """
    }
            break
            
        case "data":
            
            var base64String = ""
            if let base64encoded = haPlist.StringValue.data(using: .bytesHexLiteral)?.base64EncodedString() {
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
            
                       \(haPlist.BoolValue ? "<true/>" : "<false/>")
            """
            }
            text = """
                    
                    <key>\(haPlist.name)</key>
                    \(haPlist.BoolValue ? "<true/>" : "<false/>")
                    """
            break
            
            
        case "dict":
            var dictString:String = ""
            
            if haPlist.Childs.isEmpty {
                dictString = "<dict/>"
            } else {
                dictString = "<dict>"
                for pChild in haPlist.Childs {
                    
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
            
            if haPlist.Childs.isEmpty {
                arrayString = "<array/>"
            } else {
                arrayString = "<array>"
                
                for pChild in haPlist.Childs {
                    
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
