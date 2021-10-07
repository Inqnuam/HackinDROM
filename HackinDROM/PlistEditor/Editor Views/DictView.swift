//
//  DictView.swift
//  HackinDROM
//
//  Created by Inqnuam on 11/05/2021.
//  Copyright © 2021 HackitALL. All rights reserved.
//

import SwiftUI
import Scout
struct DictView: View {
    @Binding var MicroChild: HAPlistStruct
    @EnvironmentObject var sharedData: HASharedData
    @State var isLoading = false
    @State var isAdding:Bool = false
    @State var editingIndex:Int = 99
    @State var newName:String = ""
    
    @State var newNameIndex: Int = 99
    @State var addingIndex:Int = 99
    func binding(for index: Int) -> Binding<HAPlistStruct> {
            .init(get: {
                guard MicroChild.Childs.indices.contains(index) else { return HAPlistStruct() } // check if `index` is valid
                return MicroChild.Childs[index]
            }, set: {
                MicroChild.Childs[index] = $0
            })
    }
    
    
    var body: some View {
        
        
            BoolListView(Parent: $MicroChild).environmentObject(sharedData)
     
        
            ForEach(MicroChild.Childs.indexed(), id:\.element.id) { (littleElIndex, element) in
                
                if element.type == "string" || element.type == "int" || element.type == "data" {
                   
                        SingleRawStringView(Dict: $MicroChild.Childs[littleElIndex]).environmentObject(sharedData)
                            .contextMenu(menuItems: {
                                Button("Edit") {
                                    MicroChild.Childs[littleElIndex].isEditing = true
                                }
                                Button("Delete") {
                                    
                                    MicroChild.Childs.remove(at: littleElIndex)
                                    
                                }
                            })
                    
                }
                
               
                
            }
            
            
        ForEach(MicroChild.Childs.indexed(), id:\.element.id) { (littleElIndex, element) in
                if element.type == "dict" || element.type == "array" {
             
                    
                    Section(header:
                                
                                
                                HStack {
                        FormSectionsHeader(item: $MicroChild.Childs[littleElIndex], editingIndex: $editingIndex, littleElIndex: littleElIndex)
                            .onLongPressGesture{
                                
                                editingIndex = littleElIndex
                            }
                        
                    }.contextMenu(menuItems: {
                        Button("Rename") {
                            
                            
                            editingIndex = littleElIndex
                        }
                        
                        Button("Delete") {
                            
                            withAnimation{
                                editingIndex = 99
                                MicroChild.Childs.remove(at: littleElIndex) ///////
                            }
                            
                        }
                    })
                            
                            
                    ) {
                        if element.isShowing {
                            
                            DictDetailsView(dict: $MicroChild.Childs[littleElIndex]).environmentObject(sharedData)
                            Divider()
                            
                            
                        }
                    }
                    
                
                }
            }
        
            //.onMove(perform: onMove)
            //.listStyle(PlainListStyle())
        //}
        //ArrayStringView(MicroChild: $MicroChild).environmentObject(sharedData)
        
        
        
    }
    private func onMove(source: IndexSet, destination: Int) {
        MicroChild.Childs.move(fromOffsets: source, toOffset: destination)
        
    }
    
}


struct FormSectionsHeader: View {
    @State var newName = ""
    
    @Binding var item: HAPlistStruct
    @Binding var editingIndex:Int
    var littleElIndex:Int = 0
    
    var body: some View {
        
        if editingIndex == littleElIndex {
            HStack {
                
                TextField("", text: $newName, onEditingChanged: { isTaping in
                    if  !isTaping {
                        item.name = newName
                        
                    }
                }, onCommit: {
                    item.name = newName
                    editingIndex = 99
                    
                })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
            }.onAppear {
                newName = item.name
                
            }
            
        } else {
            HStack {
                Text(item.name)
                    .font(.system(size: 14))
                    .bold()
                
                    .foregroundColor(Color(.labelColor))
                Spacer()
                Text("\(item.Childs.count) items")
                    .foregroundColor(Color(.tertiaryLabelColor))
                if item.isShowing {
                    Button(item.isEditing ? "-" : "+") {
                        withAnimation {
                            item.isEditing.toggle()
                        }
                    }
                }
                
            }
            .padding(5)
            .contentShape(Rectangle())
            .background(item.isShowing ? Color(.systemIndigo).opacity(0.1) : Color(.clear))
            .onTapGesture {
                withAnimation {
                    item.isShowing.toggle()
                }
                
            }
            
            
        }
        
        
        
    }
}
