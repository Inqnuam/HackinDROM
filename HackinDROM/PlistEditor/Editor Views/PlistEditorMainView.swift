//
//  PlistEditorMainView.swift
//  HackinDROM
//
//  Created by Inqnuam 29/04/2021.
//  Copyright © 2021 HackinDROM. All rights reserved.
//

import SwiftUI
import Scout

struct PlistEditorMainView: View {
    @EnvironmentObject var sharedData: HASharedData
    @State var EditingName: Bool = false
    @State var ClickedIndex: Int = 0
    @State var searchingValue: String = ""
    let ClosePopoNotif = nc.publisher(for: NSNotification.Name("CloseSheet"))
    @State var newName: String = ""
    @State var selectedChild: HAPlistStruct = HAPlistStruct()
    @State var selectedSection: HAPlistStruct = HAPlistStruct()
    @ObservedObject var HAPlist: HAPlistContent
    var body: some View {
        
  
        VStack {
            
            
            NavigationView {
                
                List {
                    
                    ForEach(HAPlist.pContent.Childs.indexed(), id:\.element.id) { (Section, headSection) in
                        
                        if headSection.type == "dict" || headSection.type == "array" {
                           
                                NavigationLink(destination:
                                                PlistEditorSectionView(sectionIndex: Section, sectionEl: $HAPlist.pContent.Childs[Section], selectedSection: $selectedSection).environmentObject(sharedData),
                                               tag: Section, selection: $sharedData.selectedSection) {
                                    
                                    Text(headSection.name)
                                }.listStyle(SidebarListStyle())
                                
                                               .contextMenu(menuItems: {
                                                   if sharedData.EditorMode {
                                                       Button("Rename") {
                                                           newName = headSection.name
                                                           ClickedIndex = Section
                                                           EditingName = true
                                                       }
                                                       Button("Delete") {
                                                           
                                                           HAPlist.pContent.Childs.remove(at: Section)
                                                           
                                                       }
                                                   }
                                               })
                            
                        }
                        
                    }
                    
                }
                
                .contextMenu(menuItems: {
                    if sharedData.EditorMode {
                        Button("Add") {
                            let newItemName = "Section \(HAPlist.pContent.Childs.count)"
                            
                            
                            
                            HAPlist.pContent.Childs.append(HAPlistStruct(name: newItemName, type: "dict"))
                            
                        }
                    }
                })
            }
            
            
        }
        
        
        .onReceive(ClosePopoNotif) { (output) in
            DispatchQueue.main.async {
                sharedData.isShowingSheet  = false
            }
        }
        
        
       
        .alert(isPresented: $sharedData.editorIsAlerting) {
            let notsavedName = sharedData.savingFilePath.isEmpty ? "Template \(sharedData.ocTemplateName)" : sharedData.savingFilePath
            let primaryButton = Alert.Button.default((Text("Save"))) {
                
                let newDict = FileSaver(allowedFileTypes: ["plist"], filename: sharedData.ocTemplateName.isEmpty ? URL(fileURLWithPath: sharedData.savingFilePath).lastPathComponent : "config.plist")
                
                if newDict != "nul" {
                    do {
                        let readydata = try sharedData.PlistExpl.get().exportData()
                        try readydata.write(to: URL(fileURLWithPath: newDict))
                        sharedData.savingFilePath = newDict
                        sharedData.ocTemplateName = ""
                        sharedData.isSaved = true
                    } catch {
                        print(error)
                    }
                }
                
                
                sharedData.editorIsAlerting = false
            }
            
            let secondaryButton = Alert.Button.destructive(Text("Ignore changes!")) {
                DispatchQueue.main.async {
                    
                    sharedData.ocTemplateName = "Unused Document"
                    sharedData.savingFilePath = ""
                    
                    sharedData.isSaved = true
                    sharedData.editorIsAlerting = false
                }
            }
            return Alert(title: Text("Ooooohhh"),
                         message: Text("\(notsavedName) is not saved!"),
                         primaryButton: primaryButton,
                         secondaryButton: secondaryButton
                         
            )
        }
        
    }
    
    func binding(for index: Int) -> Binding<HAPlistStruct> {
            .init(get: {
                if let section = HAPlist.pContent.Childs.firstIndex(where: {$0 == selectedSection}) {
                    if let child = HAPlist.pContent.Childs[section].Childs.firstIndex(where: {$0 == selectedChild}) {
                        return HAPlist.pContent.Childs[section].Childs[child]
                    } else { return HAPlistStruct() }
                    
                } else { return HAPlistStruct() }
                
            }, set: {
                if let section = HAPlist.pContent.Childs.firstIndex(where: {$0 == selectedSection}) {
                    if let child = HAPlist.pContent.Childs[section].Childs.firstIndex(where: {$0 == selectedChild}) {
                HAPlist.pContent.Childs[section].Childs[child] = $0
                    }
                }
            })
    }
    
    
    func findParamInPlist( _ items: [HAPlistStruct], _ search: String, _ givenpath: [Int]) {
        //        var fullpath = givenpath
        //            if let foundSecion = items.firstIndex(where: { $0.name.localizedCaseInsensitiveCompare(search) == .orderedSame}) {
        //
        //                fullpath.insert(foundSecion, at: 0)
        //
        //
        //
        //                findParamInPlist(sharedData.CPlist.Childs, items[foundSecion].ParentName, fullpath)
        //
        //                print(fullpath)
        //
        //
        ////                sharedData.selectedSection = foundSecion
        ////                sharedData.sectionIndex = foundSecion
        //                //sharedData.isShowingSheet = true
        //
        //                 } else {
        //
        //                for item in items {
        //                    findParamInPlist(item.Childs, search, fullpath)
        //                }
        //            }
        
    }
}








