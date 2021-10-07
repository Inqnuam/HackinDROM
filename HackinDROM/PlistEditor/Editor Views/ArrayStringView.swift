//
//  ArrayStringView.swift
//  HackinDROM
//
//  Created by Inqnuam on 12/05/2021.
//  Copyright © 2021 HackinDROM. All rights reserved.
//

import SwiftUI
import Scout

struct ArrayStringView: View {
    @EnvironmentObject var sharedData: HASharedData
    @Binding var MicroChild: HAPlistStruct
    @State var isEditingName: Bool = false
    @State var newName: String = ""
    
    var body: some View {
        
        VStack {
            
            ForEach(MicroChild.Childs.indexed(), id:\.element.id) { (indeX, element) in
                
                
                    if element.type == "array" {
                        HStack {
                            
                            if element.isEditing {
                                Text("❌")
                                    .onTapGesture {
                                        MicroChild.Childs[indeX].isEditing = false
                                        MicroChild.Childs[indeX].isShowing = false
                                        
                                        MicroChild.Childs.remove(at: indeX)
                                        
                                    }
                                
                                TextField("", text: $newName, onEditingChanged: { isTaping in
                                    if !isTaping {
                                        MicroChild.Childs[indeX].name = newName
                                        MicroChild.Childs[indeX].isEditing.toggle()
                                        
                                    }
                                    
                                })
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            } else {
                                Text(element.name)
                                    .bold()
                            }
                            Spacer()
                            if element.isShowing {
                                Button("+") {
                                    
                                    MicroChild.Childs[indeX].Childs.insert(HAPlistStruct(type: "string"), at: 0)
                                }
                            }
                            Text(element.isShowing ? "⬇️" : "➡️")
                        }
                        .padding(.top, 2.5)
                            .padding(.bottom, 2.5)
                            .contentShape(Rectangle())
                            .background(element.isShowing ? Color(.systemIndigo).opacity(0.1) : Color(.clear))
                            .onTapGesture {
                                MicroChild.Childs[indeX].isShowing.toggle()
                                
                            }
                            .onLongPressGesture {
                                newName = element.name
                                MicroChild.Childs[indeX].isEditing = true
                            }
                        
                        
                        if element.isShowing {

                            ArrayOfStringShowing(element: $MicroChild.Childs[indeX]).environmentObject(sharedData)
                           
                        }
                    }
                
            }
            
            
        }
        
        
    }
}

struct ArrayOfStringShowing: View {
    @EnvironmentObject var sharedData: HASharedData
    @Binding var element: HAPlistStruct
    var body: some View {
        
        ForEach(element.Childs.indexed(), id:\.element.id) { (idx, childElement) in

            let childIndeX = 0

            if childElement.type == "string" {
                HStack {

                    TextField("String", text: $element.Childs[idx].StringValue).textFieldStyle(RoundedBorderTextFieldStyle())

                    Text("❌")
                        .onTapGesture {
                            element.Childs.remove(at: childIndeX)
                        }
                }


            }
            else
                if childElement.type == "dict" {
                VStack {
                    DictView(MicroChild: $element.Childs[idx]).environmentObject(sharedData)
                }
                .background(element.Childs.count == 1 ? Color.clear : Color(childIndeX.isMultiple(of: 2) ? .systemIndigo : .systemPurple).opacity(0.07))
                if  element.Childs.count != childIndeX + 1 {
                    Divider()
                }
            }

        }
        Divider()
    }
}

struct ArrayOfStringsView: View {
    @Binding var MicroChild: HAPlistStruct
    @EnvironmentObject var sharedData: HASharedData
    
    @State var newValue = ""
    @State var isEditing: Bool = false
    var body: some View {
        
        
        HStack {
            if MicroChild.ParentName == "UEFI" && MicroChild.name == "Drivers" {
                if #available(macOS 11.0, *) {
                    
                    Toggle("", isOn: $MicroChild.isOn.toggled(0, "", setToggle))
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle(tint: .green))
                } else {
                    HDToggleView(isOn: $MicroChild.isOn.toggled(0, "", setToggle))
                }
                
                if MicroChild.isEditing {
                    TextField("String", text: $newValue, onEditingChanged: { isTaping in
                        if !isTaping {
                            UpdateToggleVal(to: StringChanged(which: 0, what: newValue))
                        }
                    }, onCommit: {
                        MicroChild.isEditing = false
                    })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onAppear {
                            newValue =  MicroChild.StringValue
                        }
                    
                } else {
                    Text(MicroChild.StringValue.replacingOccurrences(of: "#", with: "").replacingOccurrences(of: ".efi", with: ""))
                    
                        .onLongPressGesture {
                            MicroChild.isEditing = true
                        }
                }
            } else {
                TextField(MicroChild.type == "string" ? "String" : MicroChild.type == "int" ? "Number" : "Data", text: $newValue, onEditingChanged: { isTaping in
                    if !isTaping {
                        UpdateToggleVal(to: StringChanged(which: 0, what: newValue))
                    }
                }, onCommit: {
                    MicroChild.isEditing = false
                })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onAppear {
                        newValue =  MicroChild.StringValue
                    }
            }
            Spacer()
            
        }
        
    }
    
    func UpdateToggleVal(to value: StringChanged) {
        
        if !value.what.hasPrefix("#") {
            
            MicroChild.isOn = true
        } else {
            MicroChild.isOn = false
        }
        
        MicroChild.StringValue = value.what
        sharedData.isSaved = false
        MicroChild.isEditing = false
    }
    
    func setToggle(to value: ToggleChanged){
        
        if value.yes && MicroChild.StringValue.hasPrefix("#") {
            
            MicroChild.StringValue.remove(at: MicroChild.StringValue.startIndex)
            
        } else {
            MicroChild.StringValue.insert("#", at: MicroChild.StringValue.startIndex)
        }
        
        
    }
}



