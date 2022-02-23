//
//  ToolbarButtons.swift
//  ToolbarButtons
//
//  Created by Inqnuam on 19/08/2021.
//  Copyright © 2021 HackitALL. All rights reserved.
//

import Foundation
import SwiftUI
struct ToolbarButtons: View {
    @EnvironmentObject var sharedData: HASharedData
    @ObservedObject var HAPlist: HAPlistContent
    var body: some View {
        
        
        HStack {
            Text(HAPlist.originalPath)

                ZStack {
                    
                    Button("File") {
                        
                    }
                    .allowsHitTesting(false)
                    MenuButton(""){
                        if !HAPlist.isTemplate {
                            
                            
                            Button("Save") {
                             let _ = HAPlist.saveplist()
                            }
                        }
                        
                        if !HAPlist.isTemplate {
                            Button("Save as") {
                                
                                
                                let newDict = FileSaver(allowedFileTypes: ["plist"], filename: sharedData.ocTemplateName.isEmpty ? URL(fileURLWithPath: HAPlist.originalPath).lastPathComponent : "config.plist")
                                
                                if newDict != "nul" {
                                    
                                    let _ =  HAPlist.saveplist(newPath: newDict)
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
                            if !HAPlist.isSaved {
                           //     sharedData.editorIsAlerting = true
                            } else {
                                HAPlist.isSaved = true
                                
                                let _ =   HAPlist.loadPlist(filePath: FileSelector(allowedFileTypes: ["plist"], canCreateDirectories: false, canChooseFiles: true, canChooseDirectories: false), isTemplate: false)
                            }
                        }
                        
                        
                        MenuButton("New from template"){
                            
                            ForEach(sharedData.availableocts, id:\.self) { ocv in
                                
                                Button("OpenCore \(ocv)"){
                                    if !sharedData.isSaved {
                                        sharedData.editorIsAlerting = true
                                    } else {
                                        
                                        HAPlist.isSaved = true
                                      
                                      //  sharedData.loadPlist("\(tmp)/oct/s/\(ocv).plist")
                                        let _ =    HAPlist.loadPlist(filePath: "\(tmp)/oct/s/\(ocv).plist", isTemplate: true)
                                    }
                                }
                                
                            }
                            
                        }
                        
                    }.menuButtonStyle(BorderlessButtonMenuButtonStyle())
                        .contentShape(Rectangle())
                    
                    
                        .frame(width: 50, height: 15)
                }
            

        }
       
    }
}
