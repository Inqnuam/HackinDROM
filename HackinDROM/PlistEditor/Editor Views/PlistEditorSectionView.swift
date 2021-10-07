//
//  PlistEditorChildView.swift
//  HackinDROM
//
//  Created by Inqnuam 29/04/2021.
//  Copyright © 2021 HackinDROM. All rights reserved.
//
import SwiftUI
import Scout
struct PlistEditorSectionView: View {
    @EnvironmentObject var sharedData: HASharedData
    @State var isCharging: Bool = false
    var sectionIndex: Int = 0
    @Binding var sectionEl: HAPlistStruct
    @Binding var selectedSection: HAPlistStruct
    
    @State var selectedChildsIndex: Int = 0
    var body: some View {
        
        
        
        ScrollView {
        TabView {
            ForEach(sectionEl.Childs.indexed(), id:\.element.id) { (idx, Field)  in
                
                if (Field.type == "dict" || Field.type == "array") {
                   
                    PlistSheetView(selectedSection: $sectionEl, MiniChild: $sectionEl.Childs[idx])
                        .tabItem {
                            Text(Field.name)
                           
                               
                        }
                    
                }
                
            }
        }
        
        
       // PlistSheetView(selectedSection: $sectionEl, MiniChild: $sectionEl.Childs[selectedChildsIndex])
        BoolListView(Parent: $sectionEl).environmentObject(sharedData)
        
       
            
            ForEach(sectionEl.Childs.indexed(), id:\.element.id) { (idx, Field)  in
                
                if Field.type == "string" || Field.type == "int" || Field.type == "data" {
                    
                    
                    HStack {
                        
                        SingleRawStringView(Dict: $sectionEl.Childs[idx]).environmentObject(sharedData)
                        
                            .contextMenu(menuItems: {
                                Button("Dump") {
                                    dump(Field)
                                }
                                Button("Edit") {
                                    sectionEl.Childs[idx].isEditing = true
                                }
                                Button("Delete") {
                                    
                                        sectionEl.Childs.remove(at: idx)
                                        
                                    
                                    
                                }
                            })
                        
                    }
                    
                    
                }
                
                
            }
            
            
            
        }  .padding(.horizontal)
        
        
        
        
        Spacer()
        Spacer()
        Divider()
        HStack {
            if #available(OSX 11.0, *) {
                Button("||") {
                    
                    NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
                    
                }
                Spacer()
            }
            if sharedData.EditorMode {
                
                addingNewItem(parentItem: $sectionEl).environmentObject(sharedData)
                
                
                
            }
        }.padding(.bottom, 7)
        
        
        
    }
    
    
}




extension Binding {
    
    /// When the `Binding`'s `wrappedValue` changes, the given closure is executed.
    /// - Parameter closure: Chunk of code to execute whenever the value changes.
    /// - Returns: New `Binding`.
    func onUpdate(_ closure: @escaping () -> Void) -> Binding<Value> {
        Binding(get: {
            wrappedValue
        }, set: { newValue in
            wrappedValue = newValue
            closure()
        })
    }
}
