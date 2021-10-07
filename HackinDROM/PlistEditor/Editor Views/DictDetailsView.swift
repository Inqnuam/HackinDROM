//
//  DictDetailsView.swift
//  HackinDROM
//
//  Created by Inqnuam on 14/05/2021.
//  Copyright © 2021 HackinDROM. All rights reserved.
//

import SwiftUI
import Scout
struct DictDetailsView: View {
    @EnvironmentObject var sharedData: HASharedData
    @Binding var dict:HAPlistStruct
    @State var newItem:HAPlistStruct = HAPlistStruct(type: "string")
    @State var isCharging:Bool = false
    var body: some View {
        
        if dict.isEditing {
            addingNewItem(parentItem: $dict)
            
        }
        
        
        ForEach(dict.Childs.indexed(), id:\.element.id) { (childIndex, element) in
            
           
                
                
                HStack{
                    
                    if element.type == "string" || element.type == "data" || element.type == "int" || element.type == "bool" {
                        //element.name != "Enabled"
                        
                        SingleRawStringView(Dict: $dict.Childs[childIndex], parentType: dict.type == "array" ? "array":"").environmentObject(sharedData)
                        if dict.type == "array" {
                            Text("❌")
                                .onTapGesture {
                                    
                                    dict.Childs.remove(at: childIndex)
                                    sharedData.isSaved = false
                                }
                        }
                        
                    }
                    
                }.padding(.bottom, 2)
                
                    .contextMenu(menuItems: {
                        Button("Edit") {
                            dict.Childs[childIndex].isEditing = true
                        }
                        Button("Delete") {
                            dict.Childs[childIndex].isShowing = false
                            dict.Childs.remove(at: childIndex)
                            sharedData.isSaved = false
                            
                        }
                    })
                if element.type == "dict" {
                    
                    VStack {
                        HStack {
                            Text(element.name)
                            Spacer()
                            Text("\(element.Childs.count) items")
                                .foregroundColor(Color(.tertiaryLabelColor))
                            if element.isShowing {
                                Button(element.isEditing ? "-" : "+") {
                                    dict.Childs[childIndex].isEditing.toggle()
                                    
                                }
                            }
                            Text(element.isShowing ? "⬇️" : "➡️")
                        }.contentShape(Rectangle())
                            .background(element.isShowing ? Color(.systemIndigo).opacity(0.1) : Color(.clear))
                            .onTapGesture {
                                dict.Childs[childIndex].isShowing.toggle()
                                
                            }
                        if element.isShowing {
                            
                            DictDetailsView(dict: $dict.Childs[childIndex])
                            
                        }
                    }
                    
                }
            
        }
        
        
    }
    
    
    
}



struct LoaderView: View {
    var body: some View {
        
        HStack{
            Spacer()
            if #available(macOS 11.0, *) {
                
                ProgressView()
                
            } else {
                
                Text("Loading")
                
            }
            Spacer()
        }
    }
}
