//
//  BoolListView.swift
//  HackinDROM
//
//  Created by Inqnuam 01/05/2021.
//  Copyright © 2021 HackinDROM. All rights reserved.
//

import SwiftUI
import ExyteGrid
struct BoolListView: View {
    @EnvironmentObject var sharedData: HASharedData
    @Binding var Parent: HAPlistStruct
    @State var lBool:[String] = []
    @State var rBool:[String] = []
    var body: some View {
        
        HStack(alignment: .top) {
            VStack {
                ForEach(Parent.Childs.indexed(), id:\.element.id) { (idx, headEl) in
                    if headEl.type == "bool" && lBool.contains(headEl.id.uuidString) {
                        
                        HStack {
                            if headEl.isEditing {
                                
                                TextField("String", text: $Parent.Childs[idx].name,
                                          onEditingChanged: { isTaping in
                                    if !isTaping {
                                        Parent.Childs[idx].isEditing = false
                                        sharedData.isSaved = false
                                        
                                    }
                                    
                                }, onCommit: {
                                    Parent.Childs[idx].isEditing = false
                                    
                                    
                                }
                                )
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                            } else {
                                HStack {
                                    if #available(macOS 11.0, *) {
                                        
                                        Toggle("", isOn: $Parent.Childs[idx].BoolValue)
                                            .labelsHidden()
                                            .toggleStyle(SwitchToggleStyle(tint: .green))
                                    } else {
                                        HDToggleView(isOn: $Parent.Childs[idx].BoolValue)
                                    }
                                    
                                }
                                
                                Text(headEl.name)
                                    .onLongPressGesture {
                                        Parent.Childs[idx].isEditing = true
                                        
                                        
                                    }
                                    .contextMenu(menuItems: {
                                        Button("Rename") {
                                            
                                            Parent.Childs[idx].isEditing = true
                                        }
                                        
                                        Button("Delete") {
                                            Parent.Childs[idx].isEditing = false
                                            
                                            Parent.Childs.removeAll(where: {$0.id == headEl.id})
                                            computeBoolElements()
                                            
                                            
                                            
                                        }
                                    })
                            }
                            
                            
                            Spacer()
                        }
                        
                        
                    }
                   
                }
            }
            VStack {
                ForEach(Parent.Childs.indexed(), id:\.element.id) { (idx, headEl) in
                    if headEl.type == "bool" && rBool.contains(headEl.id.uuidString) {
                        
                        HStack {
                            if headEl.isEditing {
                                
                                TextField("String", text: $Parent.Childs[idx].name,
                                          onEditingChanged: { isTaping in
                                    if !isTaping {
                                        Parent.Childs[idx].isEditing = false
                                        sharedData.isSaved = false
                                        
                                    }
                                    
                                }, onCommit: {
                                    Parent.Childs[idx].isEditing = false
                                    
                                    
                                }
                                )
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                            } else {
                                HStack {
                                    if #available(macOS 11.0, *) {
                                        
                                        Toggle("", isOn: $Parent.Childs[idx].BoolValue)
                                            .labelsHidden()
                                            .toggleStyle(SwitchToggleStyle(tint: .green))
                                    } else {
                                        HDToggleView(isOn: $Parent.Childs[idx].BoolValue)
                                    }
                                    
                                }
                                
                                Text(headEl.name)
                                    .onLongPressGesture {
                                        Parent.Childs[idx].isEditing = true
                                        
                                        
                                    }
                                    .contextMenu(menuItems: {
                                        Button("Rename") {
                                            
                                            Parent.Childs[idx].isEditing = true
                                        }
                                        
                                        Button("Delete") {
                                            Parent.Childs[idx].isEditing = false
                                            
                                            Parent.Childs.removeAll(where: {$0.id == headEl.id})
                                            computeBoolElements()
                                            
                                            
                                            
                                        }
                                    })
                            }
                            
                            
                            Spacer()
                        }
                        
                        
                    }
                    
                }
            }
        }

        
        .onAppear{
            computeBoolElements()
        }
        .onReceive([self.Parent].publisher.first()) { (value) in
              
            computeBoolElements()
           }
    }
    
    func computeBoolElements() {
        let boolElements = Parent.Childs.filter{$0.type == "bool"}
        var leftB:[String] = []
        var rightB:[String] = []
        for (boolI, bool) in boolElements.enumerated() {
            
            boolI.isMultiple(of: 2) ?  leftB.append(bool.id.uuidString) : rightB.append(bool.id.uuidString)
                
        }
        lBool = leftB
        rBool = rightB
        
        
    }
}



