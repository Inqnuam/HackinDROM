//
//  addingNewItem.swift
//  HackinDROM
//
//  Created by Inqnuam on 13/05/2021.
//  Copyright © 2021 HackinDROM. All rights reserved.
//

import SwiftUI
import Scout


// #FIXME Simplify addiding proceess 
struct addingNewItem: View {
    @EnvironmentObject var sharedData: HASharedData
    @State var newItem = HAPlistStruct(type:"string")
    @Binding var parentItem: HAPlistStruct
    @State var selectedType: Int = 0
    @State var showbase64:Bool = false
    @State var base64value:String = ""
    @State var addedStatusText: String = "Add"
    
    var body: some View {
        
        HStack {
            Button("P") {
                dump(newItem)
            }
            Picker("", selection: $newItem.type) {
                if sharedData.EditorMode {
                    Text("Array").tag("array")
                    Text("Dictionary").tag("dict")
                    Divider()
                }
                
                Text("String").tag("string")
                Text("Boolean").tag("bool")
                Text("Number").tag("int")
                Text("Data").tag("data")
                
            }
         
            TextField("Key", text: $newItem.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if newItem.type != "array" && newItem.type != "dict" {
                
                if newItem.type == "bool" {
                    Toggle("", isOn: $newItem.BoolValue)
                        .labelsHidden()
                    
                } else {
                    if !showbase64 {
                        TextField(newItem.type == "data" ? "Data (Hex)" : "Value", text: $newItem.StringValue.stringChanged(0, VerifyContentAndFix))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    } else {
                        
                        TextField("Data (Base64)", text: $base64value.stringChanged(64, VerifyContentAndFix))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                
                if newItem.type == "data" {
                    
                    Divider()
                        .frame(height: 15)
                    Text("🧬")
                        
                        .onTapGesture{
                            
                            showbase64.toggle()
                        }
                }
                
            }
            
            Spacer()
            
            
                Button(addedStatusText) {
                 
                    insertnewItems()
                    
                }
            
             
        }
        
    }
    func insertnewItems() {
       // guard (parentItem.Childs.firstIndex(where: {$0.name == newItem.name}) == nil) else { return }
        
        if parentItem.type != "array" {
        if newItem.name.isEmpty {
            if !parentItem.Childs.isEmpty {
                newItem.name = "🤡 New Item \(parentItem.Childs.count + 1)"
            } else {
                newItem.name = "🤡 New Item "
            }
        }
            
            newItem.ParentName = parentItem.name
        }
       
        
        
        
        if parentItem.type == "array" {
            newItem.ParentName = parentItem.ParentName
            newItem.name = parentItem.name
        } else if parentItem.type == "dict" {
            
        }
        
      
        
        

        withAnimation {
            parentItem.Childs.append(newItem)
            newItem = HAPlistStruct(type:"string")
           
         sharedData.isSaved = false
        }
        
       
        
        
    }
    
    func VerifyContentAndFix(to value: StringChanged) {
        
        if  selectedType == 1 {
            
            if newItem.StringValue.localizedCaseInsensitiveContains("true") || newItem.StringValue == "1" {
                newItem.BoolValue = true
            } else  if newItem.StringValue.localizedCaseInsensitiveContains("false") || newItem.StringValue == "0"  {
                newItem.BoolValue = false
            }
            
        } else if  selectedType == 2 {
            newItem.StringValue = value.what.filter { "-0123456789".contains($0) }
            
            if newItem.StringValue.contains("-") {
                
                newItem.StringValue = newItem.StringValue.replacingOccurrences(of: "-", with: "")
                newItem.StringValue.insert("-", at: newItem.StringValue.startIndex)
                
            }
            
        } else if selectedType == 3 {
            
            if value.which != 64 {
                
                if let HexToData =  value.what.uppercased().filter({ "ABCDEF0123456789".contains($0) }).data(using: .bytesHexLiteral) {
                    newItem.StringValue = value.what.uppercased().filter { "ABCDEF0123456789".contains($0) }
                    base64value = HexToData.base64EncodedString()
                }
                
            } else {
                
                let convertedVal = Base64toHex(base64value)
                newItem.StringValue = convertedVal
            }
        }
        
    }
}
