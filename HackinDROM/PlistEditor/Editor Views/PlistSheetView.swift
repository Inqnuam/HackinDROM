//
//  MiniChildView.swift
//  HackinDROM
//
//  Created by Inqnuam 30/04/2021.
//  Copyright © 2021 HackinDROM. All rights reserved.
//

import SwiftUI
import Scout
struct PlistSheetView: View {
    @EnvironmentObject var sharedData: HASharedData
    @Binding var selectedSection: HAPlistStruct
    @Binding var MiniChild: HAPlistStruct
    @State var isCharging:Bool = false
    @State var description = ""
    @State var typeLabelColor:Color = Color(.tertiaryLabelColor)
    
    var body: some View {
        
        VStack {
           
            HStack {
                
                VStack(alignment: .leading) {
//                    Text(MiniChild.ParentName + " -> " + MiniChild.name) //
//                        .contextMenu(menuItems: {
//                            if sharedData.EditorMode {
//                                Button("Remove '\(MiniChild.name)'") {
//                                    DispatchQueue.main.async {
//
//
//
//                                        selectedSection.Childs.removeAll(where: {$0.id == MiniChild.id})
//
//
//                                    }
//                                  
//                                    sharedData.isSaved = false
//                                }
//                            }
//                        })
                    
                    HStack {
                        Text(MiniChild.type == "dict" ? "Dictionary" : "Array")
                            .foregroundColor(typeLabelColor)
                        Text("\(MiniChild.Childs.count) Items")
                            .foregroundColor(typeLabelColor)
                    }
                }
                
                
                
                
              
                if MiniChild.ParentName == "ACPI" && MiniChild.name == "Add" {
                    
                    Button("Select files") {
                        addAMLfiles(multiFileSelector(allowedFileTypes: ["aml", "bin"]))
                    }
                    ZStack {
                        if MiniChild.Childs.isEmpty {
                            Button("+") {
                                
                                
                            }
                            .allowsHitTesting(false)
                        }
                        
                        MenuButton(""){
                            
                            ForEach(sharedData.availableocts, id:\.self) { ocv in
                                
                                Button("OpenCore \(ocv)"){
                                    
                                    if MiniChild.type == "array" {
                                        
                                        insertArrayFromTemplate(ocv)
                                        
                                    }
                                }
                                
                            }
                            
                        }.menuButtonStyle(BorderlessButtonMenuButtonStyle())
                            .frame(width: 70)
                            .allowsHitTesting(MiniChild.Childs.isEmpty)
                        
                        if !MiniChild.Childs.isEmpty && MiniChild.type == "array" {
                            Button("+") {
                                
                                cleanFisrtAndInsert()
                            }
                        }
                    }
                }
                else if MiniChild.ParentName == "Kernel" && MiniChild.name == "Add" {
                    
                    Button("Select files") {
                        addKextfiles(multiFileSelector(allowedFileTypes: ["kext"]))
                    }
                    ZStack {
                        if MiniChild.Childs.isEmpty {
                            Button("+") {
                                
                                
                            }
                            .allowsHitTesting(false)
                        }
                        
                        MenuButton(""){
                            
                            ForEach(sharedData.availableocts, id:\.self) { ocv in
                                
                                Button("OpenCore \(ocv)"){
                                    
                                    if MiniChild.type == "array" {
                                        
                                        insertArrayFromTemplate(ocv)
                                        
                                    }
                                }
                                
                            }
                            
                        }.menuButtonStyle(BorderlessButtonMenuButtonStyle())
                            .frame(width: 70)
                            .allowsHitTesting(MiniChild.Childs.isEmpty)
                        
                        if !MiniChild.Childs.isEmpty && MiniChild.type == "array" {
                            Button("+") {
                                
                                cleanFisrtAndInsert()
                            }
                        }
                    }
                }
                else if MiniChild.ParentName == "UEFI" && MiniChild.name == "Drivers" {
                    
                    Button("Select files") {
                        addDriverfiles(multiFileSelector(allowedFileTypes: ["efi"]))
                    }
                    ZStack {
                        if MiniChild.Childs.isEmpty {
                            Button("+") {
                                
                                
                            }
                            .allowsHitTesting(false)
                        }
                        
                        MenuButton(""){
                            
                            ForEach(sharedData.availableocts, id:\.self) { ocv in
                                
                                Button("OpenCore \(ocv)"){
                                    
                                    if MiniChild.type == "array" {
                                        
                                        insertArrayFromTemplate(ocv)
                                        
                                    }
                                }
                                
                            }
                            
                        }.menuButtonStyle(BorderlessButtonMenuButtonStyle())
                            .frame(width: 70)
                            .allowsHitTesting(MiniChild.Childs.isEmpty)
                        
                        if !MiniChild.Childs.isEmpty && MiniChild.type == "array" {
                            Button("+") {
                               
                                cleanFisrtAndInsert()
                            }
                        }
                    }
                }
                else if MiniChild.ParentName == "NVRAM" && MiniChild.name == "Add" {
                    
                    Button("+") {
                        
                        addNewDict([PathElement(stringLiteral: "NVRAM"), PathElement(stringLiteral: "Add"), PathElement(stringLiteral: "Item \(MiniChild.Childs.count)")])
                        
                    }
                }
                else if MiniChild.ParentName == "NVRAM" && MiniChild.name == "Delete" {
                    
                    Button("+") {
                        
                        addNewArray([PathElement(stringLiteral: "NVRAM"), PathElement(stringLiteral: "Delete"), PathElement(stringLiteral: "Item \(MiniChild.Childs.count)")])
                    }
                }
                else if MiniChild.ParentName == "NVRAM" && MiniChild.name == "LegacySchema" {
                    
                    Button("+") {
                        addNewArray([PathElement(stringLiteral: "NVRAM"), PathElement(stringLiteral: "LegacySchema"), PathElement(stringLiteral: "Item \(MiniChild.Childs.count)")])
                    }
                }
                else if MiniChild.ParentName == "DeviceProperties" && MiniChild.name == "Add" {
                    
                    Button("+") {
                        
                        addNewDict([PathElement(stringLiteral: "DeviceProperties"), PathElement(stringLiteral: "Add"), PathElement(stringLiteral: "Item \(MiniChild.Childs.count)")])
                    }
                }
                else if MiniChild.ParentName == "DeviceProperties" && MiniChild.name == "Delete" {
                    
                    Button("+") {
                        addNewArray([PathElement(stringLiteral: "DeviceProperties"), PathElement(stringLiteral: "Delete"), PathElement(stringLiteral: "Item \(MiniChild.Childs.count)")])
                    }
                }
                else {
                    
                    
                    
                    ZStack {
                        if MiniChild.Childs.isEmpty {
                            Button("+") {
                                
                                
                            }
                            .allowsHitTesting(false)
                        }
                        
                        MenuButton(""){
                            
                            ForEach(sharedData.availableocts, id:\.self) { ocv in
                                
                                Button("OpenCore \(ocv)"){
                                    
                                    if MiniChild.type == "array" {
                                        
                                        insertArrayFromTemplate(ocv)
                                        
                                    }
                                }
                                
                            }
                            
                        }.menuButtonStyle(BorderlessButtonMenuButtonStyle())
                            .frame(width: 70)
                            .allowsHitTesting(MiniChild.Childs.isEmpty)
                        
                        if !MiniChild.Childs.isEmpty && MiniChild.type == "array" {
                            Button("+") {
                                
                                cleanFisrtAndInsert()
                            }
                        }
                    }.contentShape(Rectangle())
                    
                }
                
                Spacer()
                Spacer()
            }
            .contentShape(Rectangle())
            .contextMenu(menuItems: {
                
                Button("Editor Mode") {
                    withAnimation {
                        sharedData.EditorMode.toggle()
                    }
                }
                if MiniChild.type == "array" {
                    MenuButton("Template"){
                        ForEach(sharedData.availableocts, id:\.self) { ocv in
                            
                            Button("OpenCore \(ocv)"){
                                
                                insertArrayFromTemplate(ocv)
                            }
                            
                        }
                        
                    }.menuButtonStyle(BorderlessButtonMenuButtonStyle())
                        .frame(width: 70)
                }
                
            })
            
            Divider()
            
            
            
           
          //  ScrollView {
                if MiniChild.type == "array" {
                    
                    ChildsView(MicroChild: $MiniChild).environmentObject(sharedData)
                    
                } else {
                    
                  
                    DictView(MicroChild: $MiniChild).environmentObject(sharedData)
               
                }
          //  }.padding(.trailing, 5)
           
            
            if MiniChild.ParentName == "PlatformInfo" && MiniChild.name == "Generic" {
                
                HStack {
                    Text("Import from:")
                        .bold()
                    Button("My System") {
                        
                        
                        getAndSetPlatformInfo(MyHackData)
                    }
                    Button("File") {
                        
                        ImportFromFile() { found in
                            
                            getAndSetPlatformInfo(found)
                        }
                    }
                    
                    Spacer()
                    Divider()
                        .frame(height: 15)
                    Button("Generate New") {
                        
                        DispatchQueue.main.async {
                            
                            
                            generateNewSMBIOS()
                        }
                    }
                }
            }
            
            Spacer()
            
            if sharedData.EditorMode {
                Divider()
                
                addingNewItem(parentItem:$MiniChild)
                
            }
            //                if !description.isEmpty {
            //                Text(description)
            //                }
        
        }
        
    }
    func generateNewSMBIOS() {
        
        var mycustomdata = MyHackDataStrc()
        mycustomdata.SystemUUID = UUID().uuidString
        
        let romdefin =  mycustomdata.SystemUUID.suffix(7).prefix(6)
        
        let rom1 = randomHEXByte()
        let rom2 = randomHEXByte()
        let rom3 = randomHEXByte()
        let romik = rom1 + rom2 + rom3 + romdefin
        
        let base64 = romik.data(using: .bytesHexLiteral)?.base64EncodedString()
        
        if let base64 = base64 {
            mycustomdata.ROM = Base64toHex(base64)
        }
        
        
        
        if let IndeX = MiniChild.Childs.firstIndex(where: {$0.name == "SystemProductName"}) {
            
            let data =  macserial(MiniChild.Childs[IndeX].StringValue).trimmingCharacters(in: .whitespacesAndNewlines).split(whereSeparator: \.isWhitespace)
            mycustomdata.SystemProductName = MiniChild.Childs[IndeX].StringValue
            mycustomdata.SystemSerialNumber = String(data[0])
            mycustomdata.MLB =   String(data[2])
            getAndSetPlatformInfo(mycustomdata)
        }
        sharedData.isSaved = false
    }
    func getAndSetPlatformInfo(_ gotData: MyHackDataStrc) {
        
        
        if let IndeX = MiniChild.Childs.firstIndex(where: {$0.name == "SystemSerialNumber"}) {
            
            MiniChild.Childs[IndeX].StringValue = gotData.SystemSerialNumber
        }
        
        if let IndeX = MiniChild.Childs.firstIndex(where: {$0.name == "ROM"}) {
            
            MiniChild.Childs[IndeX].StringValue = gotData.ROM
            nc.post(name: Notification.Name("UpdateValues"), object: nil, userInfo: ["name": "ROM"])
            
        }
        
        if let IndeX = MiniChild.Childs.firstIndex(where: {$0.name == "SystemUUID"}) {
            
            MiniChild.Childs[IndeX].StringValue = gotData.SystemUUID
            
        }
        if let IndeX = MiniChild.Childs.firstIndex(where: {$0.name == "MLB"}) {
            
            MiniChild.Childs[IndeX].StringValue = gotData.MLB
            
            
        }
        
        if let IndeX = MiniChild.Childs.firstIndex(where: {$0.name == "SystemProductName"}) {
            
            MiniChild.Childs[IndeX].StringValue = gotData.SystemProductName
            
            nc.post(name: Notification.Name("UpdateValues"), object: nil, userInfo: ["name": "SystemProductName"])
            
        }
        sharedData.isSaved = false
    }
    
    func insertArrayFromTemplate(_ ocv: String) {
        
        if let parInd = sharedData.ocTemplatesHD[ocv]!.Childs.firstIndex(where: {$0.name == MiniChild.ParentName}) {
            
            if let childInd = sharedData.ocTemplatesHD[ocv]!.Childs[parInd].Childs.firstIndex(where: {$0.name == MiniChild.name}) {
                
                let templateObj = sharedData.ocTemplatesHD[ocv]!.Childs[parInd].Childs[childInd]
                
                if let elem = templateObj.Childs.first {
                    
                    var cleaned = cleanHAPlistStruct(elem)
                    
                    if cleaned.type == "string" {
                        cleaned.StringValue = "Item \(MiniChild.Childs.count)"
                    }
                    
                    
                    MiniChild.Childs.append(cleaned)
                    sharedData.isSaved = false
                    
                }
            }
        }
        
        
    }
    func cleanFisrtAndInsert(){
        typeLabelColor = .red
        let exampleDict = MiniChild.Childs.first!
        
        if MiniChild.type == "array" {
            
            
            
        }
        
        var cleanedItem = cleanHAPlistStruct(exampleDict)
        
        var newItemValues: [String: ExplorerValue] = [:]
        
        
        
        if cleanedItem.type == "string" {
            cleanedItem.name = MiniChild.name
            cleanedItem.ParentName = MiniChild.ParentName
            cleanedItem.StringValue = "New Item \(MiniChild.Childs.count + 1)"
            if MiniChild.type == "dict" { // à revoir tout ça
            }
            
            MiniChild.Childs.append(cleanedItem)
            sharedData.isSaved = false
            
        }  else {
            for val in cleanedItem.Childs {
                
                if val.type == "string" {
                    newItemValues.updateValue(.string(""), forKey: val.name)
                    
                } else if val.type == "int" {
                    newItemValues.updateValue(.int(0), forKey: val.name)
                    
                } else if val.type == "bool" {
                    newItemValues.updateValue(.bool(false), forKey: val.name)
                }  else if val.type == "data" {
                    newItemValues.updateValue(.data(Data()), forKey: val.name)
                }
            }
            
            MiniChild.Childs.append(cleanedItem)
            sharedData.isSaved = false
            
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            typeLabelColor =  Color(.tertiaryLabelColor)
        }
        //#FIXME: check if it works in different sections
    }
    
    
    func addAMLfiles(_ files: [String]) {
        
        for file in files {
            let filName = URL(fileURLWithPath: file, isDirectory: false).lastPathComponent
            
            MiniChild.Childs.append(HAPlistStruct(name: "", StringValue: "", type: "dict", Childs:[
                HAPlistStruct(name:"Comment", StringValue: "", type: "string"),
                HAPlistStruct(name:"Enabled", BoolValue: true, type: "bool"),
                HAPlistStruct(name:"Path", StringValue: filName, type: "string")
            ])
            )
            
            
        }
        
        sharedData.isSaved = false
    }
    
    func addKextfiles(_ files: [String]) {
        
        for file in files {
            let filName = URL(fileURLWithPath: file, isDirectory: false).lastPathComponent
            
            
            var ExecutablePath = ""
            var PlistPath = ""
            var Comment = ""
            if  let infoPlist = fileManager.contents(atPath: "\(file)/Contents/Info.plist") {
                PlistPath = "Contents/Info.plist"
                
                do {
                    let pListObject = try PropertyListSerialization.propertyList(from: infoPlist, options: PropertyListSerialization.ReadOptions(), format: nil)
                    
                    if let pListDict = pListObject as? [String: AnyObject] {
                        if let foundExecutablePath = pListDict["CFBundleExecutable"] as? String {
                            ExecutablePath = "Contents/MacOS/\(foundExecutablePath)"
                        }
                        
                        if let foundVersion = pListDict["CFBundleVersion"] as? String {
                            Comment = "v.\(foundVersion) "
                        }
                        
                    }
                } catch {
                    return
                }
            }
            
            MiniChild.Childs.append(HAPlistStruct(name: "", StringValue: "", type: "dict", Childs:[
                HAPlistStruct(name:"Arch", StringValue: "Any", type: "string"),
                HAPlistStruct(name:"BundlePath", StringValue: filName, type: "string"),
                HAPlistStruct(name:"Comment", StringValue: Comment, type: "string"),
                HAPlistStruct(name:"Enabled", BoolValue: true, type: "bool"),
                HAPlistStruct(name:"ExecutablePath", StringValue: ExecutablePath, type: "string"),
                HAPlistStruct(name:"MaxKernel", StringValue: "", type: "string"),
                HAPlistStruct(name:"MinKernel", StringValue: "", type: "string"),
                HAPlistStruct(name:"PlistPath", StringValue: PlistPath, type: "string")
            ])
            )
            
            
        }
        sharedData.isSaved = false
        
    }
    
    
    func addNewDict(_ fullPath: [PathElement]){
        
        MiniChild.Childs.append(HAPlistStruct(
            name: String(describing: fullPath.last!),
            type: "dict",
            ParentName: MiniChild.name,
            Childs: [HAPlistStruct(name:"Item", type: "string", ParentName: String(describing: fullPath.last!))]))
        
        sharedData.isSaved = false
        
    }
    
    func addNewArray(_ fullPath: [PathElement]){
        
        MiniChild.Childs.append(HAPlistStruct(
            name: String(describing: fullPath.last!),
            type: "array",
            ParentName: MiniChild.name,
            Childs: [HAPlistStruct(name: String(describing: fullPath.last!), StringValue: "Item", type: "string", ParentName: MiniChild.name)]))
        sharedData.isSaved = false
        
    }
    
    func addDriverfiles(_ files: [String]) {
        
        for file in files {
            let filName = URL(fileURLWithPath: file, isDirectory: false).lastPathComponent
            if MiniChild.Childs.firstIndex(where: {$0.type == "string" && $0.StringValue == filName}) == nil {
                
                
                MiniChild.Childs.append(HAPlistStruct(name: "Drivers", StringValue: filName, isOn: !file.hasPrefix("#"), type: "string", ParentName: "UEFI"))
                sharedData.isSaved = false
                
                
            }
            
            
        }
        
    }
    
    
    
}



struct PopoverView: View {
    @Binding var isVisible:Bool
    var body: some View {
        VStack {
            
            
            Spacer()
            HStack {
                Spacer()
                Button("OK") {
                    isVisible.toggle()
                }
            }
        }.padding()
    }
}
