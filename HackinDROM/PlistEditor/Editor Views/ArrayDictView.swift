//
//  ChildsView.swift
//  HackinDROM
//
//  Created by Inqnuam on 06/05/2021.
//  Copyright © 2021 HackinDROM. All rights reserved.
//


import SwiftUI
struct ChildsView: View {
    @Binding var MicroChild: HAPlistStruct
    @EnvironmentObject var sharedData: HASharedData
    @State var isHovered:Bool = true
    @State var hoveredIndex: Int = 0
    func binding(for index: Int) -> Binding<HAPlistStruct> {
        .init(get: {
            guard MicroChild.Childs.indices.contains(index) else { return HAPlistStruct() } // check if `index` is valid
            return MicroChild.Childs[index]
        }, set: {
            MicroChild.Childs[index] = $0
        })
    }
    var body: some View {
        
        
        ForEach(MicroChild.Childs.indexed(), id:\.element.id) { (elIndex, element) in
            
            
            if element.type == "string" || element.type == "int" || element.type == "data" {
                HStack {
                    
                    ArrayOfStringsView(MicroChild: $MicroChild.Childs[elIndex])
                        .contextMenu(menuItems: {
                            Button("Edit") {
                                MicroChild.Childs[elIndex].isEditing = true
                                
                            }
                            Button("Delete") {
                               
                                    MicroChild.Childs.remove(at: elIndex)
                                    sharedData.isSaved = false
                                
                            }
                        })
                    
                    if MicroChild.name != "Drivers" && MicroChild.ParentName != "UEFI" {
                        Text("❌")
                            .onTapGesture {
                             
                                    MicroChild.Childs.remove(at: elIndex)
                                    sharedData.isSaved = false
                                
                            }
                    }
                    
                }
            }
            
            
        }
        
        ForEach(MicroChild.Childs.indexed(), id:\.element.id) { (elIndex, element) in
            
            if element.type == "dict" || element.type == "array" {
                Section(header:
                            
                            HStack {
                    if let EnableBoolIndex = element.Childs.firstIndex(where: {$0.type == "bool" && $0.name == "Enabled"}) {
                        
                        setToggleView(element: $MicroChild.Childs[elIndex].Childs[EnableBoolIndex]).environmentObject(sharedData)
                        
                    }
                    Text(element.customName.isEmpty ? "Item \(elIndex)" : element.customName)
                        .bold()
                        .foregroundColor(Color(.labelColor))
                    
                    
                    Spacer()
                    Text("\(element.Childs.count) Items")
                        .foregroundColor(Color(.tertiaryLabelColor))
                    if element.isShowing {
                        
                        Button(element.isEditing ? "-" : "+") {
                            withAnimation {
                                MicroChild.Childs[elIndex].isEditing.toggle()
                            }
                        }
                        
                        
                    }
                    
                }
                            .contentShape(Rectangle())
                            .background(element.isShowing ? Color(.systemIndigo).opacity(0.1) : Color(.clear))
                            .onTapGesture {
                    withAnimation {
                        MicroChild.Childs[elIndex].isShowing.toggle()
                    }
                    
                }
                            .contextMenu(menuItems: {
                    Button("Delete") {
                        
                        MicroChild.Childs.remove(at: elIndex)
                        sharedData.isSaved = false
                    }
                })
                ) {
                    
                    if element.isShowing {
                        DictDetailsView(dict: $MicroChild.Childs[elIndex])
                        Divider()
                    }
                }
                
            }
        }
      
    }
    
    private func move(source: IndexSet, destination: Int) {
        MicroChild.Childs.move(fromOffsets: source, toOffset: destination)
        
    }
    private func onDelete(offsets: IndexSet) {
        MicroChild.Childs.remove(atOffsets: offsets)
    }
}










struct setToggleView: View {
    @EnvironmentObject var sharedData: HASharedData
    @Binding var element: HAPlistStruct
    var body: some View {
        
        
        if #available(macOS 11.0, *) {
            Toggle("", isOn: $element.BoolValue.toggled(0, "", setisNotSaved))
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: .green))
            
        } else {
            
            HDToggleView(isOn: $element.BoolValue.toggled(0, "", setisNotSaved))
        }
    }
    
    func setisNotSaved(to value: ToggleChanged) {
        sharedData.isSaved = false
    }
    
}
