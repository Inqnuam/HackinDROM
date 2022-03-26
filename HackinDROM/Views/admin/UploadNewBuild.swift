//
//  LeadersView.swift
//  HackinDROM
//
//  Created by Inqnuam 20/02/2021.
//  Copyright © 2021 HackinDROM. All rights reserved.
//

import SwiftUI
import Zip
struct NewBuildView: View {
    @EnvironmentObject var sharedData: HASharedData
    @Binding var isCharging: Bool
    @State var configplists: [URL] = []
    @State var FolderPath: String = ""
    @State var imageUrls: [Int: URL] = [:]
    @State var selectedMLB = AllBuilds()
    @State var customOCv: String = ""
    @State var OCvS: String = ""
    @State var isWorking: Bool = false
    @State var isNewBuild: Bool = false
    @State var setLatest: Bool = true
    @State var selectedVendor: String = ""
    @State var UploadNewBuild = UploadNewBuildStruct(SPN: "iMacPro1,1")
    @AppStorageCompat("UserID") var UserID = ""
    @State private var showingSheet = false
    
    @State var selectedProductName = 120
    @State  var vendorsList = ["Apple", "ASRock", "ASUS", "Acer", "Dell", "Gigabyte", "HP", "Huawei", "Intel", "LG", "Lenovo", "MSI", "Mechrevo", "Razer Blade", "XiaoMi"]
    var body: some View {
        
        HStack {
            
            Button(action: {
                withAnimation {
                    sharedData.currentview = 5
                    
                }
                
            }, label: {
                
                Text("←")
                
            }
            )
            
            .padding(.leading, 15)
            .padding(.top, 18)
            
            Spacer()
            if isWorking {
                
                if #available(OSX 11.0, *) {
                    ProgressView()
                    
                } else {
                    Text("Working...")
                }
                
            }
            if !isNewBuild {
                Picker(selection: $selectedMLB, label: Text("Select Build")) {
                    ForEach(sharedData.AllBuilds.filter({$0.leader.localizedCaseInsensitiveContains(sharedData.ConnectedUser)}), id: \.self) { build in
                        
                        Text(build.vendor + " " + build.name).tag(build)
                        
                        
                    }
                }
                Text("OR")
                    .foregroundColor(.red)
                    .bold()
                
                Button(action: {
                    isNewBuild = true
                }, label: {
                    
                    Text("Add")
                }
                )
            } else {
                
                Picker(selection: $UploadNewBuild.vendor, label: Text("Vendor")) {
                    
                    ForEach(vendorsList, id:\.self) { vendor in
                        
                        Text(vendor).tag(vendor)
                        
                        
                    }
                    Divider()
                    Text("Other").tag("Other")
                    
                    
                }
                TextField("New build's name (MLB model ...)", text: $UploadNewBuild.name)
                
                Picker(selection: $UploadNewBuild.SPN, label: Text("")) {
                    ForEach(Macs, id:\.self) { mac in
                        Text(mac).tag(mac)
                    }
                }  .frame(width: 138)
                    .toolTip("Default System Product Name")
                
                Button(action: {
                    isNewBuild = false
                }, label: {
                    if #available(OSX 11.0, *) {
                        Image(systemName: "xmark.rectangle.fill")
                    } else {
                        Text("❌")
                    }
                }
                )
            }
            
        }
        Divider()
        ScrollView(.vertical, showsIndicators: false) {
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        
                        selectOCEFIfolder()
                        
                    }, label: {
                        Text(FolderPath == "" ? "Select EFI folder" : "Change folder")
                    })
                    
                    
                    
                }
                HStack {
                    
                    if OCvS == "0.0.0" {
                        Image("OCLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                        
                        TextField("", text: $customOCv)
                            .frame(width: 38)
                        
                    } else if OCvS == "" {
                        
                    } else {
                        Image("OCLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                        Text(OCvS)
                    }
                    Text(FolderPath)
                        .underline()
                        .onTapGesture {
                            NSWorkspace.shared.open(URL(fileURLWithPath: FolderPath, isDirectory: true))
                            
                        }
                    Spacer()
                }
            }
            .padding(10)
            
            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    
                    ForEach(configplists, id: \.self, content: { plist in
                        
                        DragableImage(url: plist)
                        
                    })
                    
                }.padding(20)
                
            }
            
            VStack {
                HStack {
                    
                    VStack(alignment: .center, spacing: 90) {
                        Image("AMDGPU")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 75, height: 64)
                        Image("InteliGPU")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 75, height: 64)
                        
                    }
                    DroppableArea(imageUrls: $imageUrls, configplists: $configplists)
                }
                
            }
            .padding(.top, configplists.isEmpty ? 30 : 2 )
            
        }
        Divider()
        HStack {
            
            Button("Release Notes") {
                
                showingSheet = true
                
            }
            
            Spacer()
            
            if #available(OSX 11.0, *) {
                Toggle("", isOn: $UploadNewBuild.config.active.toggled(0, "", isDisableSoAsLatest))
                    .toggleStyle(SwitchToggleStyle(tint: .green))
                    .help(UploadNewBuild.config.active ? "Disable" : "Enable")
                
            } else {
                Toggle("Enable", isOn: $UploadNewBuild.config.active.toggled(0, "", isDisableSoAsLatest))
                
            }
            
            if #available(OSX 11.0, *) {
                Image(systemName: "exclamationmark.square.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .foregroundColor(UploadNewBuild.config.warning ? .yellow : .primary)
                    .help("Warning!")
                    .onTapGesture {
                        UploadNewBuild.config.warning.toggle()
                        
                    }
            } else {
                Image("exclamationmark.square.fill")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                
                    .frame(width: 18, height: 18)
                    .foregroundColor(UploadNewBuild.config.warning ? .yellow : .primary)
                    .toolTip("Warning!")
                    .onTapGesture {
                        UploadNewBuild.config.warning.toggle()
                        
                    }
            }
            //
            Toggle("Set Latest", isOn: $setLatest)
            // .padding(.leading, 5)
            
            VStack {
                
                Button(action: {
                    isWorking = true
                    if isNewBuild && UploadNewBuild.name.count > 5 && !UploadNewBuild.vendor.isEmpty {
                        
                        
                        
                        pushBuildtoDB() { uploaded in
                            
                            if uploaded {
                                DispatchQueue.main.async {
                                    sharedData.GetAllBuildsAndConfigure()
                                    isWorking = false
                                    sharedData.currentview = 5
                                }
                                
                                
                            }
                            
                        }
                        
                        
                    } else if !isNewBuild && !selectedMLB.vendor.isEmpty {
                        
                        pushBuildtoDB() { uploaded in
                            
                            if uploaded {  DispatchQueue.main.async {
                                
                                sharedData.GetAllBuildsAndConfigure()
                                isWorking = false
                                sharedData.currentview = 5
                            }
                            }
                            
                        }
                    } else {
                        isWorking = false
                    }
                    
                    
                }, label: {
                    
                    if #available(OSX 11.0, *) {
                        Image(systemName: "icloud.and.arrow.up.fill")
                    } else {
                        Text("☁️ Upload")
                    }
                }).disabled(imageUrls.isEmpty || self.FolderPath == "nul" || self.FolderPath == "" || (!isNewBuild && selectedMLB.vendor.isEmpty))
                    .toolTip("Upload")
                
            }
            
        } .padding(.trailing, 10)
            .padding(.leading, 10)
            .padding(.bottom, 5)
            .onAppear {
                
                vendorsList.sort {
                    $0 < $1
                }
            }
            .sheet(isPresented: $showingSheet) {
                
                
                
                VStack {
                    
                    if #available(OSX 11.0, *) {
                        TextEditor(text: $UploadNewBuild.config.notes)
                    } else {
                        TextField("Release Notes (Copy and paste here please)", text: $UploadNewBuild.config.notes)
                    }
                    
                    Divider()
                    HStack {
                        
                        Image(nsImage: NSImage(named: NSImage.touchBarOpenInBrowserTemplateName)!)
                        TextField("link to forum", text: $UploadNewBuild.config.followLink)
                        
                        Spacer()
                        
                        Button("OK") {
                            
                            showingSheet = false
                            
                        }
                        .padding(.trailing, 0)
                        
                    }
                } .frame(width: 400, height: 450)
                    .padding()
                    .background(Color.clear)
                
            }
        
    }
    func isDisableSoAsLatest(to value: ToggleChanged) {
        
        if !value.yes {
            
            setLatest = false
        }
        
    }
    
    func pushBuildtoDB(completion: @escaping (Bool)->()) {
        
        if isNewBuild {
            UploadNewBuild.leader = sharedData.ConnectedUser
        } else {
            UploadNewBuild.config.buildID = selectedMLB.id
        }
        
        
        
        UploadNewBuild.config.ocvs = OCvS == "0.0.0" ? customOCv : OCvS
        
        let serialQueue = DispatchQueue(label: "newBuild")
        let group = DispatchGroup()
        
        group.enter()
        serialQueue.async {
            
            shell("cp -a '\(FolderPath)' '\(tmp)/HDWorkingFolder'") {_, _ in
                
                
                
                let FindPlists = try! fileManager.contentsOfDirectory(at: URL(fileURLWithPath: "\(tmp)/HDWorkingFolder/OC/"), includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
                
                let plists =  FindPlists.filter { $0.pathExtension == "plist" }
                
                for plist in plists {
                    
                    
                    if fileManager.fileExists(atPath: plist.relativePath) && imageUrls.firstIndex(where: {$0.value.lastPathComponent == plist.lastPathComponent}) == nil {
                        
                        shell("rm '\(plist.relativePath)'") { _, _ in}
                        
                    }
                    
                }
                
                
                if let sizeOnDisk = try? URL(fileURLWithPath: "\(tmp)/HDWorkingFolder").sizeOnDisk() {
                    UploadNewBuild.config.size = sizeOnDisk
                }
                
                group.leave()
            }
            
            
        }
        
        
        
        
        group.enter()
        serialQueue.async {
            for plist in imageUrls {
                getHAPlistFrom(plist.value.relativePath) { plistStruct in
                    var plistStruct = plistStruct
                    
                    plistStruct.set(HAPlistStruct(stringValue: "** Enter Board Serial Number **"), to: ["PlatformInfo", "Generic", "MLB"])
                    plistStruct.set(HAPlistStruct(stringValue: "** Enter Serial Number **"), to: ["PlatformInfo", "Generic", "SystemSerialNumber"])
                    plistStruct.set(HAPlistStruct(stringValue: "** Enter System UUID **"), to: ["PlatformInfo", "Generic", "SystemUUID"])
                    plistStruct.set(HAPlistStruct(stringValue: UploadNewBuild.SPN), to: ["PlatformInfo", "Generic", "SystemProductName"])
                    plistStruct.set(HAPlistStruct(stringValue: "Cw53kXtk"), to: ["PlatformInfo", "Generic", "ROM"])
                    let bootargs =   plistStruct.get(["NVRAM", "Add", "7C436110-AB2A-4BBB-A880-FE41995C9F82", "boot-args"])?.stringValue ?? ""
                    haPlistEncode(plistStruct, plist.value.relativePath)
                    
                    var newPlist = NewConfigsData(link: plist.value.lastPathComponent, bootArgs: bootargs)
                    
                     if let KernelSection =  plistStruct.childs.first(where: {$0.name == "Kernel"}) {
                        
                        if let PatchSection =  KernelSection.childs.first(where: {$0.name == "Patch"}) {
                            
                            for kentry in PatchSection.childs {
                                
                                var isFound:Bool = false
                                if !isFound {
                                    for eField in kentry.childs {
                                        
                                        if (eField.name == "Replace" && eField.type == "data") && (eField.stringValue.localizedCaseInsensitiveCompare("B8CC00000000") == .orderedSame
                                                                                                   || eField.stringValue.localizedCaseInsensitiveCompare("BACC00000000") == .orderedSame
                                                                                                   || eField.stringValue.localizedCaseInsensitiveCompare("BACC00000090") == .orderedSame) {
                                            
                                            
                                            
                                            isFound = true
                                            UploadNewBuild.config.amdosx = true
                                            
                                            break
                                            
                                        }
                                    }
                                } else {
                                    break
                                }
                            }
                        }
                    }
                    
                    if plist.key == 1 {
                        newPlist.Name = "Broadcom"
                        UploadNewBuild.config.AMDGPU.append(newPlist)
                        
                    }
                    if plist.key == 2 {
                        newPlist.Name = "Intel Wifi"
                        UploadNewBuild.config.AMDGPU.append(newPlist)
                    }
                    if plist.key == 3 {
                        newPlist.Name = "Broadcom"
                        UploadNewBuild.config.IntelGPU.append(newPlist)
                        
                    }
                    
                    if plist.key == 4 {
                        newPlist.Name = "Intel Wifi"
                        UploadNewBuild.config.IntelGPU.append(newPlist)
                    }
                }
                
            }
            group.leave()
        }
        
        
        
        
        
        group.enter()
        serialQueue.async {
            
            do {
                
                try Zip.zipFiles(paths: [URL(fileURLWithPath: "\(tmp)/HDWorkingFolder")], zipFilePath: URL(fileURLWithPath: "\(tmp)/HDWorkingFolder.zip"), password: nil, progress: { (progress) -> () in
                    
                    if progress == 1.0 {
                        
                        UploadNewBuild.config.Archive = FileUpload("\(tmp)/HDWorkingFolder.zip").trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        if  UploadNewBuild.config.Archive != "nul" && UploadNewBuild.config.Archive != "" {
                            do {
                                try fileManager.removeItem(at: URL(fileURLWithPath: "\(tmp)/HDWorkingFolder.zip"))
                                try  fileManager.removeItem(at: URL(fileURLWithPath: "\(tmp)/HDWorkingFolder"))
                            } catch {
                                print(error)
                                
                            }
                        }
                        
                    }
                    
                })
                
            } catch {
                
                print("Creation of ZIP archive failed with error: \(error)")
                
            }
            
            
            group.leave()
        }
        
        
        
        group.enter()
        serialQueue.async {
            
            
            let url = URL(string: "https://hackindrom.zapto.org/app/builds?latest=\(setLatest.description)")
            guard let requestUrl = url else { fatalError() }
            
            var request = URLRequest(url: requestUrl)
            request.httpMethod = "POST"
            
            // Set HTTP Request Header
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let jsonData = try! JSONEncoder().encode(UploadNewBuild)
            
            request.httpBody = jsonData
            
            let task =  URLSession.shared.dataTask(with: request) { (_, response, error) in
                
                if let error = error {
                    print("Error took place \(error)")
                    return
                }
                //  guard let data = data else {return}
                
                //  let _ = try JSONDecoder().decode(link.self, from: data)
                if let httpResponse = response as? HTTPURLResponse {
                    if (httpResponse.statusCode) == 200 {
                        
                        completion(true)
                        
                        
                    } else {
                        
                        completion(false)
                    }
                    isWorking = false
                    
                }
                
            }
            task.resume()
            
            group.leave()
        }
        
        
    }
    
    func selectOCEFIfolder() {
        
        let selectedPath = FileSelector(allowedFileTypes: ["zip"], canCreateDirectories: true, canChooseFiles: false, canChooseDirectories: true)
        if selectedPath != "nul" && selectedPath != "" {
            self.FolderPath = selectedPath
            do {
                let FindKexts = try fileManager.contentsOfDirectory(at: URL(fileURLWithPath: "\(selectedPath)/OC"), includingPropertiesForKeys: nil)
                if fileManager.fileExists(atPath: "\(selectedPath)/OC/OpenCore.efi") {
                    
                    let createddate = GetOCCreatedDate("\(selectedPath)/OC/OpenCore.efi")
                    
                    OCvS = OCDateAndVersion[createddate.monthAndYear] ?? "0.0.0"
                    
                    if OCvS == "0.0.0" {
                        customOCv = OCvS
                    }
                    let plists =  FindKexts.filter { $0.pathExtension == "plist" }
                    
                    configplists = []
                    for plist in plists {
                        
                        configplists.append(plist)
                    }
                } else {
                    self.FolderPath = "OpenCore not found"
                    OCvS = ""
                    customOCv = ""
                    configplists = []
                }
                
                
            } catch {
                self.FolderPath = "OpenCore not found"
                OCvS = ""
                customOCv = ""
                configplists = []
            }
            
        } else {
            self.FolderPath = ""
            self.OCvS = ""
            self.customOCv = ""
            configplists = []
            imageUrls = [:]
        }
        nc.post(name: Notification.Name("OpenPopover"), object: nil)
    }
    
}


