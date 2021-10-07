//
//  PlistEditorHeader.swift
//  PlistEditorHeader
//
//  Created by lian on 18/08/2021.
//  Copyright © 2021 Golden Chopper. All rights reserved.
//

import Foundation
import SwiftUI
struct PlistEditorMainHeader: View {
    @EnvironmentObject var sharedData: HASharedData
    @Binding var EditingName:Bool
    @Binding var newName: String
    @Binding var ClickedIndex: Int
    @ObservedObject var HAPlist: HAPlistContent
    var body: some View {
        
        HStack {
            
            HStack {
                Button(action: {
                    
                    sharedData.currentview = 0
                    
                },
                       label: {
                    if #available(OSX 11.0, *) {
                        Image(systemName: "arrow.backward")
                        
                    } else {
                        Text("←")
                        
                    }
                    
                })
                
            }
            .padding(.leading, 15)
            .padding(.top, 18)
            
            
            Spacer()
            HStack {
                
                
                if EditingName {
                    TextField("", text: $HAPlist.pContent.Childs[ClickedIndex].name, onEditingChanged: { isTaping in
                        if !isTaping {
                           
                            EditingName = false
                            
                        }
                    }
                    )
                } else if !sharedData.ocTemplateName.isEmpty {
                    Text(sharedData.ocTemplateName)
                } else {
                    Text(sharedData.savingFilePath)
                        .lineLimit(2)
                        .toolTip(sharedData.savingFilePath)
                        .onTapGesture {
                            let url = URL(fileURLWithPath: sharedData.savingFilePath, isDirectory: false)
                            let path = url.deletingLastPathComponent().relativePath // 'a/b'
                            
                            NSWorkspace.shared.open(URL(fileURLWithPath: path, isDirectory: true))
                        }
                    
                }
                if !HAPlist.isSaved {
                    Text("* Not saved")
                        .bold()
                        .foregroundColor(.red)
                }
                Spacer()
                
                ZStack {
                    
                    Button("File") {
                        
                    }
                    .allowsHitTesting(false)
                    MenuButton(""){
                        if !sharedData.savingFilePath.isEmpty {
                            
                            
                            Button("Save") {
                                HAPlist.saveplist()
                            }
                        }
                        
                        if !sharedData.savingFilePath.isEmpty || !sharedData.ocTemplateName.isEmpty {
                            Button("Save as") {
                                
                                
                                let newDict = FileSaver(allowedFileTypes: ["plist"], filename: sharedData.ocTemplateName.isEmpty ? URL(fileURLWithPath: sharedData.savingFilePath).lastPathComponent : "config.plist")
                                
                                if newDict != "nul" {
                                    
                                    HAPlist.saveplist(newPath: newDict)
                                }
                                
                            }
                        }
//                        Button("Import 2 (test)") {
//
//                            var referenceO = HAPlistStruct()
//                            var findInO = HAPlistStruct()
//                            getHAPlistFrom("\(tmp)/oct/c/\(sharedData.availableocts.first!).plist") { item in
//                                print(sharedData.availableocts.first!)
//                                referenceO = item
//                            }
//
//                            getHAPlistFrom(
//                                FileSelector(allowedFileTypes: ["plist"], canCreateDirectories: false, canChooseFiles: true, canChooseDirectories: false)) { item in
//
//                                    findInO = item
//                                }
//
//
//                            sharedData.CPlist = updateOCPlist(referenceO, findInO)
//                            sharedData.savingFilePath = "/Users/lian/Desktop/EFIs/generated.plist"
//
//                        }
                       
                        
                        Button("Open"){
                            if !sharedData.isSaved {
                                sharedData.editorIsAlerting = true
                            } else {
                                sharedData.isSaved = true
                                sharedData.ocTemplateName = ""
                                sharedData.savingFilePath = FileSelector(allowedFileTypes: ["plist"], canCreateDirectories: false, canChooseFiles: true, canChooseDirectories: false)
                              
                                HAPlist.loadPlist(filePath: sharedData.savingFilePath, isTemplate: false)
                            }
                        }
                        
                        
                        MenuButton("New from template"){
                            
                            ForEach(sharedData.availableocts, id: \.self) { ocv in
                                
                                Button("OpenCore \(ocv)"){
                                    if !sharedData.isSaved {
                                        sharedData.editorIsAlerting = true
                                    } else {
                                        
                                        sharedData.isSaved = true
                                        sharedData.ocTemplateName = "OpenCore \(ocv)"
                                        sharedData.savingFilePath = ""
                                      //  sharedData.loadPlist("\(tmp)/oct/s/\(ocv).plist")
                                        HAPlist.loadPlist(filePath: "\(tmp)/oct/s/\(ocv).plist", isTemplate: true)
                                    }
                                }
                                
                            }
                            
                        }
                        
                    }.menuButtonStyle(BorderlessButtonMenuButtonStyle())
                        .contentShape(Rectangle())
                    
                    
                        .frame(width: 50, height: 15)
                }.frame(width: 50, height: 15)
                
                
            }
            .padding(.trailing, 15)
            .padding(.top, 18)
        }.padding(.bottom, 3)
            .contentShape(Rectangle())
            .contextMenu(menuItems: {
                
                Button("Editor Mode") {
                    withAnimation {
                        sharedData.EditorMode.toggle()
                    }
                }
                
            })
    }
}
