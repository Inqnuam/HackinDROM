//
//  NewDrive.swift
//  HackinDROM EFI
//
//  Created by Inqnuam 16/02/2021.
//  Copyright © 2021 HackinDROM. All rights reserved.
//

import SwiftUI

struct CreateEFI: View {
    @EnvironmentObject var sharedData: HASharedData
    
    @Binding var ExternalDisksList: [ExternalDisks]
    @Binding var isCharging: Bool
    @Binding var EFIs: [EFI]
    @State var selectedDrive:ExternalDisks = ExternalDisks()
    @State var selectedGPU = 0
    @State var selectedWiFi = 0
    @State var selectedCore = "20"
    @State var selectedBuild = AllBuilds()
    @State var selectedConfig = BuildConfigs()
    @State var selectedPlist = PlistData()
    @State var CancelMe: Bool = false
    @State var EnableSIP: Bool = true
    @State var selectedVendor = ""
    @State var MyRom: String = ""
    @State var SelectedFolder = ""
    @State var ProgressValue  = 0.0
    @State var DownloadColor: Color = Color.yellow
    @State var StatusText: String = ""
    @State var isWorking: Bool = false
    @State var mycustomdata = MyHackDataStrc(SystemProductName: "iMacPro1,1", OCV: "0.0.0", SIP: "00000000")
    @State private var BootArgs: [String] = []
    @State private var newBootArg = ""
    @State var isHoveredOnBootArgs: Bool = false
    @State var BootArgHoveredIndex: Int = 100
    @State var ImportBootArgsFromMySystem: Bool = false
    let GPUs = ["AMD GPU", "Intel iGPU"]
    
    let AuthNotif = nc.publisher(for: NSNotification.Name("FormatInstall"))
    
    @State private var showingSheet = false
    @State var buildID: Int = 0
    @State var indeX: Int = 0
    @State var showingDesc = ""
    @State var FindBootArg = BootArgData()
    let ClosePopoNotif = nc.publisher(for: NSNotification.Name("CloseSheet"))
    var body: some View {
        HStack {
            
            Button(action: {
                
                sharedData.currentview = 0
                
            }, label: {
                if #available(OSX 11.0, *) {
                    Image(systemName: "arrow.backward")
                } else {
                    Text("←")
                }
                
            }
            )
            
            .padding(.leading, 15)
            .padding(.top, 18)
            
            Spacer()
            
            if isWorking {
                Section {
                    Text(StatusText)
                    Spacer()
                    if #available(OSX 11.0, *) {
                        ProgressView(value: ProgressValue, total: 100.0)
                            .accentColor(DownloadColor)
                            .scaleEffect(x: 1, y: 4, anchor: .center)
                    } else {
                        
                        Text("....")
                    }
                    
                }
            }
            
        }
        Divider()
        
        // ScrollView(.vertical, showsIndicators: false) {
        VStack {
            
            Form {
                VStack {
                    
                    Section {
                        if sharedData.Updating == "Update" {
                            
                            HStack {
                                Picker(selection: $selectedDrive.externalSelected(SetNewSelectedDrive), label: Text("Select an External Drive")) { // #FIXME
                                    ForEach(ExternalDisksList, id: \.self) { extDisk in
                                        Text("\(extDisk.name) - \(extDisk.SSD) \(extDisk.size) \(extDisk.location)")//.tag(extDisk)
                                    }
                                }
                                Text("OR")
                                    .foregroundColor(.red)
                                    .bold()
                                Button(SelectedFolder == "" ? "Select Folder" : "Change Folder") {
                                    
                                    SelectedFolder  = FileSelector(allowedFileTypes: [""], canCreateDirectories: true, canChooseFiles: false, canChooseDirectories: true)
                                    
                                    if SelectedFolder == "nul" {
                                        
                                        SelectedFolder = ""
                                        
                                    } else {
                                        
                                        selectedDrive = ExternalDisks()
                                    }
                                    nc.post(name: Notification.Name("ClosePasswordWindow"), object: nil)
                                }
                                
                            }
                            if SelectedFolder != "" {
                                
                                HStack {
                                    if #available(OSX 11.0, *) {
                                        Image(systemName: "folder.badge.minus")
                                            .foregroundColor(.red)
                                            .font(.system(size: 18.0, weight: .bold))
                                            .onTapGesture {
                                                SelectedFolder = ""
                                            }
                                    } else {
                                        Image(nsImage: NSImage(named: NSImage.folderName)!)
                                            .foregroundColor(.red)
                                            .font(.system(size: 18.0, weight: .bold))
                                            .onTapGesture {
                                                SelectedFolder = ""
                                            }
                                    }
                                    
                                    Button(SelectedFolder) {
                                        NSWorkspace.shared.open(URL(fileURLWithPath: SelectedFolder, isDirectory: true))
                                    }
                                    .buttonStyle(LinkButtonStyle())
                                    Spacer()
                                }
                            }
                            
                        } else {
                            let index = sharedData.CurrentEFI
                            
                            HStack {
                                if #available(OSX 11.0, *) {
                                    Image(systemName: "externaldrive")
                                        .foregroundColor(Color("MountedNameDisk"))
                                } else {
                                    Text("")
                                        .foregroundColor(Color("MountedNameDisk"))
                                }
                                
                                Text(EFIs[index].SSD)
                                    .foregroundColor(Color("MountedNameDisk"))
                                    .cornerRadius(7.0)
                                
                                Text("\(EFIs[index].path) | " + EFIs[index].mounted.replacingOccurrences(of: "/Volumes/", with: ""))
                                    .foregroundColor(Color("CustomEFIName"))
                                
                                Spacer()
                                Text("\(EFIs[index].type) | \(EFIs[index].name)")
                                    .lineLimit(1)
                                
                            }
                            .toolTip("Open EFI folder in Finder")
                            .onTapGesture {
                                NSWorkspace.shared.open(URL(fileURLWithPath: EFIs[index].mounted, isDirectory: true))
                            }
                            
                        }
                    }
                    HStack {
                        
                        Section {
                            Picker(selection: $selectedVendor.pickerSelected(setSelectedVendor), label: Text("Vendor").fontWeight(.semibold)) {
                                ForEach(sharedData.vendors, id:\.self) { vendor in
                                    
                                    Text(vendor).tag(vendor)
                                    
                                }
                            }
                        }.frame(width: 200)
                        
                        Section {
                            Picker(selection: $selectedBuild.buildChanged(SetNewMlb), label: Text("Motherboard").fontWeight(.semibold)) {
                                ForEach(sharedData.ConnectedUser.localizedCaseInsensitiveContains(selectedBuild.leader) ? sharedData.AllBuilds.filter({$0.vendor == selectedVendor}) : sharedData.AllBuilds.filter({$0.vendor == selectedVendor && $0.active})) { mlb in
                                    
                                    Text(mlb.name).tag(mlb)
                                    
                                }
                            }
                        }
                        
                        
                    }
                    HStack {
                        Section {
                            Picker(selection: $selectedConfig.configChanged(setSelectedConfig), label: Text("OpenCore")) {
                                
                                ForEach(sharedData.ConnectedUser.localizedCaseInsensitiveContains(selectedBuild.leader) ? selectedBuild.configs : selectedBuild.configs.filter({ $0.active == true }), id: \.self) { config in // .filter { $0.active == true }
                                    
                                    Text(config.active ? config.ocvs : "🔺 \(config.ocvs)").tag(config)
                                }
                                
                                
                            }//.frame(width: 80)
                            
                        }
                        
                        
                        
                        if !selectedConfig.notes.isEmpty {
                            
                            Button(action: {
                                //   buildID = selectedOC
                                showingSheet.toggle()
                                
                            }, label: {
                                
                                if !selectedConfig.warning {
                                    // Image(systemName: "info")
                                    Text("ℹ︎")
                                } else {
                                    
                                    Text("⚠️")
                                }
                                
                            })
                            .toolTip("Release Notes")
                            
                        } else if !selectedConfig.followLink.isEmpty {
                            
                            Button(action: {
                                
                                OpenSafari(selectedConfig.followLink)
                            }, label: {
                                
                                if !selectedConfig.warning {
                                    Text("🔗")
                                } else {
                                    
                                    Text("⚠️")
                                }
                            })
                            .toolTip("Author's link")
                            
                        }
                        
                        
                        if selectedConfig.amdosx {
                            
                            Section {
                                Picker(selection: $selectedCore, label: Text("AMD CPU Total Cores").fontWeight(.semibold)) {
                                    
                                    
                                    
                                    Text("6").tag("06")
                                    Text("8").tag("08")
                                    Text("12").tag("0C")
                                    Text("16").tag("10")
                                    Text("32").tag("20")
                                    
                                    
                                }
                            }
                        } else {
                            Section {
                                Picker(selection: $selectedGPU.pickerChanged(setSelectedGPU), label: Text("GPU").fontWeight(.semibold)) {
                                    
                                    if !selectedConfig.AMDGPU.isEmpty {
                                        
                                        Text("AMD GPU").tag(0)
                                    }
                                    if !selectedConfig.IntelGPU.isEmpty {
                                        Text("Intel iGPU").tag(1)
                                    }
                                    
                                }
                            }
                            
                            Section {
                                Picker(selection: $selectedPlist.plistChanged(SetBootArgs), label: Text("WiFi").fontWeight(.semibold)) {
                                    
                                    if selectedGPU == 0 {
                                        ForEach(selectedConfig.AMDGPU, id: \.self) { AMD in
                                            Text(AMD.Name).tag(AMD)
                                        }
                                    }
                                    
                                    if selectedGPU == 1 {
                                        ForEach(selectedConfig.IntelGPU, id: \.self) { Intel in
                                            Text(Intel.Name).tag(Intel)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    Divider()
                }
                
            }
            
            
            
            HStack {
                Text("PlatformInfo")
                    .bold()
                    .font(.system(size: 18))
                Spacer()
                Button("Generate New") {
                    DispatchQueue.main.async {
                        
                        mycustomdata.SystemUUID = UUID().uuidString
                        
                        let romdefin =  mycustomdata.SystemUUID.suffix(7).prefix(6)
                        
                        let rom1 = randomHEXByte()
                        let rom2 = randomHEXByte()
                        let rom3 = randomHEXByte()
                        let romik = rom1 + rom2 + rom3 + romdefin
                        
                        let base64 = romik.data(using: .bytesHexLiteral)?.base64EncodedString()
                        
                        if let base64 = base64 {
                            mycustomdata.ROM = Base64toHex(base64)
                            
                            SetNewRom(to: StringChanged(which: 0, what: mycustomdata.ROM))
                        }
                        
                        let data =  macserial(mycustomdata.SystemProductName).trimmingCharacters(in: .whitespacesAndNewlines).split(whereSeparator: \.isWhitespace)
                        
                        mycustomdata.SystemSerialNumber = String(data[0])
                        mycustomdata.MLB =   String(data[2])
                    }
                }
                .toolTip("Generate new SMBIOS data for selected System Product Name")
                Spacer()
                Divider()
                    .frame(height: 15)
                Text("Import from:")
                    .bold()
                Button("My System") {
                    mycustomdata = MyHackData
                    
                    SetNewRom(to: StringChanged(which: 0, what: mycustomdata.ROM))
                    
                    if Macs.firstIndex(where: { $0 == MyHackData.SystemProductName}) != nil {
                        mycustomdata.SystemProductName = MyHackData.SystemProductName
                        
                    }
                    if mycustomdata.SIP == "00000000" {
                        EnableSIP = true
                        
                    } else {
                        EnableSIP = false
                    }
                    
                    // nc.post(name: Notification.Name("ClosePasswordWindow"), object: nil)
                }
                .toolTip("Import SMBIOS data (Serial Numbers, Product Name ...) from current system")
                Button("File") {
                    ImportFromFile { result in
                        
                        mycustomdata = result
                        if result.SystemProductName != "" {
                            
                            if Macs.firstIndex(where: { $0 == result.SystemProductName}) != nil {
                                mycustomdata.SystemProductName = result.SystemProductName
                                
                            }
                            
                        }
                        
                    }
                    
                }
                .toolTip("Import SMBIOS data (Serial Numbers, Product Name ...) from OpenCore or Clover config.plist")
            }.padding(.bottom, 5)
            
            HStack {
                
                VStack(spacing: 2) {
                    
                    Text("System Product Name").font(.system(size: FontSize - CGFloat(1))).bold()
                    Picker(selection: $mycustomdata.SystemProductName, label: Text("")) {
                        ForEach(Macs, id:\.self) { mac in
                            
                            Text(mac).tag(mac)
                        }
                    } .frame(width: 140)
                    
                }
                VStack(spacing: 2) {
                    Text("System Serial Number").font(.system(size: FontSize - CGFloat(1))).bold()
                    HStack {
                        TextField("Required", text: $mycustomdata.SystemSerialNumber)
                        Button(action: {
                            
                            OpenSafari("https://checkcoverage.apple.com/?sn=\(mycustomdata.SystemSerialNumber)")
                        }, label: {
                            if #available(OSX 11.0, *) {
                                Image(systemName: "applelogo")
                            } else {
                                
                                Text("􀣺")
                            }
                            
                        })
                        .toolTip("Check for invalid Serial Number")
                        .disabled(mycustomdata.SystemSerialNumber.count < 10)
                        
                    }
                }
                
                VStack(spacing: 2) {
                    Text("Motherboard").font(.system(size: FontSize - CGFloat(1))).bold()
                    TextField("Required", text: $mycustomdata.MLB)
                    
                    // MaterialTextField(placeholder: "Required", text:$mycustomdata.MLB)
                }
                
            }
            
            HStack {
                
                VStack(spacing: 2) {
                    Text("System UUID").font(.system(size: FontSize - CGFloat(1))).bold()
                    TextField("Required", text: $mycustomdata.SystemUUID)
                }
                
                VStack(spacing: 2) {
                    Text("ROM").font(.system(size: FontSize - CGFloat(1))).bold()
                    
                    HStack {
                        TextField("Required", text: $mycustomdata.ROM.stringChanged(0, SetNewRom))
                            .frame(width: 110)
                        Text(MyRom)
                        
                    }
                }
            }
            .padding(.bottom, 5)
            
            Divider()
            Section {
                
                HStack {
                    Text("Boot Arguments")
                        .bold()
                        .font(.system(size: 18))
                        .padding(.top, 3)
                    Spacer()
                    Divider()
                        .frame(height: 15)
                    if #available(OSX 11.0, *) {
                        Toggle("Enable SIP", isOn: $EnableSIP.toggled(0, "", SetSIPValue))
                            .toggleStyle(SwitchToggleStyle(tint: .green))
                    } else {
                        Toggle("Enable SIP", isOn: $EnableSIP.toggled(0, "", SetSIPValue))
                        
                    }
                    if !EnableSIP {
                        
                        TextField("Custom SIP value", text: $mycustomdata.SIP)
                            .frame(width: 110)
                    }
                    
                }
                
                HStack {
                    ScrollView(.horizontal) {
                        HStack {
                            
                            ForEach(BootArgs.indices, id: \.self) { index in
                                if BootArgs[index] != "" {
                                    let isHovered = isHoveredOnBootArgs && BootArgHoveredIndex == index
                                    let colors = Gradient(colors: [.red, .yellow, .green, .blue, .purple])
                                    let clearbg = Gradient(colors: [.clear])
                                    let conic = RadialGradient(gradient: isHovered ? clearbg : colors, center: .center, startRadius: 50, endRadius: 200)
                                    
                                    ZStack {
                                        Text(BootArgs[index])
                                            .padding(2)
                                            .background(conic)
                                            .cornerRadius(15.0)
                                            .contentShape(Rectangle())
                                        
                                        if isHovered {
                                            
                                            Text("❌")
                                            
                                        }
                                        
                                    }.padding(.bottom, 12)
                                        .onTapGesture {
                                            BootArgs.remove(at: index)
                                        }
                                        .onHover { inside in
                                            
                                            if inside {
                                                BootArgHoveredIndex = index
                                                isHoveredOnBootArgs = true
                                                if BootArgs.indices.contains(index) {
                                                    if BootArgs[index].contains("alcid=") {
                                                        
                                                        if let Gang = BootArguments.firstIndex(where: {$0.value ==  "alcid="}) {
                                                            
                                                            showingDesc = BootArguments[Gang].description
                                                            
                                                        }
                                                        
                                                    } else if BootArgs[index].contains("darkwake=") {
                                                        
                                                        if let Gang = BootArguments.firstIndex(where: {$0.value ==  "darkwake="}) {
                                                            
                                                            showingDesc = BootArguments[Gang].description
                                                            
                                                        }
                                                        
                                                    } else if BootArgs[index].contains("revcpu=") {
                                                        
                                                        if let Gang = BootArguments.firstIndex(where: {$0.value ==  "revcpu="}) {
                                                            
                                                            showingDesc = BootArguments[Gang].description
                                                            
                                                        }
                                                        
                                                    } else if BootArgs[index].contains("revcpuname=") {
                                                        
                                                        if let Gang = BootArguments.firstIndex(where: {$0.value ==  "revcpuname="}) {
                                                            
                                                            showingDesc = BootArguments[Gang].description
                                                            
                                                        }
                                                        
                                                    }
                                                    else {
                                                        
                                                        if let Gang = BootArguments.firstIndex(where: {$0.value ==  BootArgs[index]}) {
                                                            
                                                            showingDesc = BootArguments[Gang].description
                                                            
                                                        } else {
                                                            
                                                            showingDesc =  ""
                                                        }
                                                    }
                                                    
                                                }
                                                
                                            } else {
                                                isHoveredOnBootArgs = false
                                                BootArgHoveredIndex = 100
                                            }
                                            
                                        }
                                    
                                }
                            }
                            
                        }.padding(.bottom, 12)
                        // .padding(.top, 5)
                    }
                    
                }
                
                HStack {
                    HStack {
                        TextField("", text: $newBootArg.stringChanged(0, SetNewBootik), onCommit: addNewWord)
                            .frame(width: 100)
                            .disableAutocorrection(true)
                            .padding(.trailing, 0)
                        
                        Button("Add") {
                            
                            addNewWord()
                        }
                        .disabled(newBootArg.isEmpty)
                    }
                    
                    if FindBootArg.value != "" {
                        Text(FindBootArg.value)
                            .padding(2)
                            .background(RadialGradient(gradient: Gradient(colors: [.blue, .pink, .green, .blue, .purple]), center: .center, startRadius: 50, endRadius: 200))
                            .cornerRadius(15.0)
                            .contentShape(Rectangle())
                        
                            .onTapGesture {
                                if FindBootArg.value.contains("=") {
                                    
                                    let answer = FindBootArg.value.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                                    
                                    // exit if the remaining string is empty
                                    guard answer.count > 0 else {
                                        return
                                    }
                                    
                                    // extra validation to come
                                    if !BootArgs.contains(answer) {
                                        BootArgs.append(answer)
                                        newBootArg = ""
                                    }
                                }
                            }
                        
                    }
                    Spacer()
                    
                    HStack {
                        Divider()
                            .frame(height: 15)
                        if #available(OSX 11.0, *) {
                            Toggle("from my system", isOn: $ImportBootArgsFromMySystem.toggled(0, "", ImportFromMySyS))
                                .toggleStyle(SwitchToggleStyle(tint: .purple))
                        } else {
                            Toggle("from my system", isOn: $ImportBootArgsFromMySystem.toggled(0, "", ImportFromMySyS))
                            
                        }
                        
                    }.padding(.trailing, 0)
                    
                }
                .padding(.leading, 0)
                
                
                Text(isHoveredOnBootArgs ? showingDesc : FindBootArg.description)
                    .alignmentGuide(.leading) { d in d[.trailing] }
                // .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)
                
                
            }
            
            
            
        }
        .padding(.leading, 10)
        .padding(.trailing, 10)
        
        
        //  .frame(minWidth: 500, maxWidth: .infinity, minHeight: 560, maxHeight: .infinity)
        Spacer()
        Divider()
        
        HStack {
            
            Spacer()
            Spacer()
            HStack {
                
                if sharedData.Updating == "Update" {
                    if SelectedFolder == "" {
                        
                        Button(action: {
                            
                            if !isWorking {
                                
                                FormatInstall()
                                
                            } else {
                                
                                CancelFormatInstall()
                            }
                            
                        }, label: {
                            if !isWorking {
                                Text("Format Disk and Create EFI")
                            } else {
                                
                                Text("Cancel")
                            }
                            
                        })
                        .disabled(mycustomdata.MLB.isEmpty || mycustomdata.ROM.count < 12 || mycustomdata.SystemUUID.isEmpty || mycustomdata.SystemSerialNumber.isEmpty  || selectedDrive.name.isEmpty || CancelMe)
                    } else {
                        Button(action: {
                            if !isWorking {
                                FormatInstall()
                            } else {
                                CancelFormatInstall()
                            }
                            
                        }, label: {
                            if !isWorking {
                                Text("Save to folder")
                                
                            } else {
                                
                                Text("Cancel")
                            }
                        })
                        .disabled(mycustomdata.MLB.isEmpty || mycustomdata.ROM.count < 12 || mycustomdata.SystemUUID.isEmpty || mycustomdata.SystemSerialNumber.isEmpty  || SelectedFolder == "" || CancelMe)
                    }
                } else {
                    
                    Button(action: {
                        
                        if !isWorking {
                            FormatInstall()
                        } else {
                            CancelFormatInstall()
                        }
                        
                    }, label: {
                        if !isWorking {
                            Text("Create new OC EFI")
                            
                        } else {
                            
                            Text("Cancel")
                        }
                    })
                    .disabled(mycustomdata.MLB.isEmpty || mycustomdata.ROM.count < 12 || mycustomdata.SystemUUID.isEmpty || mycustomdata.SystemSerialNumber.isEmpty || CancelMe)
                }
            }
            
        }
        .padding(.leading, 10)
        .padding(.trailing, 10)
        .padding(.bottom, 10)
        
        .onAppear {
            
            DispatchQueue.global().async {
                selectedCore = MyHackData.cpuCount
                if !sharedData.AllBuilds.isEmpty {
                    
                    BootArgs  = selectedPlist.bootArgs.components(separatedBy: " ") //
                    
                }
                
                MyRom = (mycustomdata.ROM.data(using: .bytesHexLiteral)?.base64EncodedString()) ?? "invalid"
                
                mycustomdata.ROM = String(mycustomdata.ROM.prefix(12))
                if (Macs.firstIndex(where: { $0 == selectedBuild.SPN}) != nil) {
                    
                    mycustomdata.SystemProductName = selectedBuild.SPN
                    mycustomdata.SystemUUID = UUID().uuidString
                    
                    let romdefin =  mycustomdata.SystemUUID.suffix(7).prefix(6)
                    
                    let rom1 = randomHEXByte()
                    let rom2 = randomHEXByte()
                    let rom3 = randomHEXByte()
                    let romik = rom1 + rom2 + rom3 + romdefin
                    
                    let base64 = romik.data(using: .bytesHexLiteral)?.base64EncodedString()
                    
                    if let base64 = base64 {
                        mycustomdata.ROM = Base64toHex(base64)
                        
                        SetNewRom(to: StringChanged(which: 0, what: mycustomdata.ROM))
                    }
                    
                    let data =  macserial(mycustomdata.SystemProductName).trimmingCharacters(in: .whitespacesAndNewlines).split(whereSeparator: \.isWhitespace)
                    
                    mycustomdata.SystemSerialNumber = String(data[0])
                    mycustomdata.MLB =   String(data[2])
                }
            }
        }
        
        .onReceive(AuthNotif) { (_) in
            
            FormatInstall()
        }
        
        .onReceive(ClosePopoNotif) { (_) in
            if showingSheet {
                
                showingSheet = false
            }
            
        }
        
        .sheet(isPresented: $showingSheet) {
            
            
            
            
            VStack {
                
                HStack {
                    Text(selectedBuild.name)
                        .font(.title)
                        .padding(.leading, 0)
                    Spacer()
                    Text("OC \(selectedConfig.ocvs)")
                        .font(.system(size: 14))
                        .padding(.trailing, 0)
                }
                Divider()
                ScrollView {
                    Text(selectedConfig.notes)
                    
                        .multilineTextAlignment(.leading)
                    
                }
                HStack {
                    
                    HStack {
                        if !selectedConfig.followLink.isEmpty {
                            
                            HStack {
                                // Image(systemName: "safari.fill")
                                Image(nsImage: NSImage(named: NSImage.touchBarOpenInBrowserTemplateName)!)
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.orange)
                                    .frame(width: 15, height: 15)
                                
                            }
                            
                            .onTapGesture {
                                OpenSafari(selectedConfig.followLink)
                            }
                            
                        }
                        
                        Text("by " + selectedBuild.leader)
                            .font(.subheadline)
                    }.padding(.leading, 0)
                    Spacer()
                    Button("Close") {
                        showingSheet = false
                    }
                    .padding(.trailing, 0)
                    
                }
                
            }
            .frame(width: 400, height: 450)
            .padding()
            .background(Color.clear)
            
            
            
        }
    }
    func SetSIPValue(to value: ToggleChanged) {
        
        if value.yes {
            mycustomdata.SIP = "00000000"
            
        } else {
            
            mycustomdata.SIP = "E7030000"
        }
        
    }
    func CancelFormatInstall() {
        CancelMe = true
        isCharging = false
        
        StatusText = "Canceling..."
        
        isWorking = false
        self.EFIs = getEFIList()
        sharedData.currentview = 0
        
    }
    func SetNewSelectedDrive(to value: ExternalDisks) {
        
        if !value.name.isEmpty {
            
            SelectedFolder = ""
        }
        
    }
    
    func SetNewProductName(to value: Int) {
        
        mycustomdata.SystemProductName = Macs[value]
    }
    
    func SetNewBootik(to value: StringChanged) {
        
        if value.what != "" {
            if let gang = BootArguments.firstIndex(where: {"\($0.value)".localizedCaseInsensitiveContains(newBootArg) || "\($0.description)".localizedCaseInsensitiveContains(newBootArg) }) {
                
                FindBootArg = BootArguments[gang]
                
            }
            
        } else {
            
            FindBootArg = BootArgData()
            
        }
        
    }
    
    func SetNewRom(to value: StringChanged) {
        
        if value.what.count != 12 {
            
            MyRom = "6 bytes?"
        } else {
            MyRom = (value.what.data(using: .bytesHexLiteral)?.base64EncodedString()) ?? "invalid"
            mycustomdata.ROM = String(value.what.prefix(12))
        }
    }
    
    
    
    func setSelectedGPU(to value: Int) {
        
        if value == 0 {
            
            if let index = selectedConfig.AMDGPU.firstIndex(where: {$0.Name.localizedCaseInsensitiveContains("Broadcom")}) {
                selectedPlist = selectedConfig.AMDGPU[index]
                
                
            } else if let index = selectedConfig.AMDGPU.firstIndex(where: {$0.Name.localizedCaseInsensitiveContains("Intel")}) {
                selectedPlist = selectedConfig.AMDGPU[index]
                
            }
        } else  if value == 1 {
            
            if let index = selectedConfig.IntelGPU.firstIndex(where: {$0.Name.localizedCaseInsensitiveContains("Broadcom")}) {
                selectedPlist = selectedConfig.IntelGPU[index]
                
            } else if let index = selectedConfig.IntelGPU.firstIndex(where: {$0.Name.localizedCaseInsensitiveContains("Intel")}) {
                selectedPlist = selectedConfig.IntelGPU[index]
                
            }
        }
        SetBootArgs(to: selectedPlist)
        
    }
    
    func setSelectedCore(to value: StringChanged) {
        
    }
    func setSelectedVendor(to value: String) {
        
        
        selectedBuild =  sharedData.ConnectedUser.localizedCaseInsensitiveContains(selectedBuild.leader) ? sharedData.AllBuilds.filter({$0.vendor == selectedVendor}).first ?? AllBuilds() : sharedData.AllBuilds.filter({$0.vendor == selectedVendor && $0.active}).first ?? AllBuilds()
        SetNewMlb(to: selectedBuild)
    }
    
    func setSelectedConfig(to value: BuildConfigs) {
        if !value.AMDGPU.isEmpty {
            selectedGPU = 0
            setSelectedGPU(to: 0)
        } else {
            selectedGPU = 1
            setSelectedGPU(to: 1)
        }
    }
    func SetNewMlb(to value: AllBuilds) {
        
        
        mycustomdata.SystemProductName = value.SPN
        
        
        
        if let firstplist = value.configs.first {
            
            selectedConfig = firstplist
            
            setSelectedConfig(to: selectedConfig)
            
        } else {
            selectedConfig =  BuildConfigs()
            setSelectedConfig(to: BuildConfigs())
        }
        
        
    }
    
    func SetBootArgs(to value: PlistData) {
        BootArgs = value.bootArgs.components(separatedBy: " ")
        
    }
    
    func ImportFromMySyS(to value: ToggleChanged) {
        
        if value.yes {
            
            BootArgs = MyHackData.BootArgs.components(separatedBy: " ")
            
            if mycustomdata.SIP == "00000000" {
                EnableSIP = true
                
            } else {
                EnableSIP = false
            }
        } else {
            if selectedGPU == 0 {
                
                BootArgs = selectedPlist.bootArgs.components(separatedBy: " ")
            }
            
            if selectedGPU == 1 {
                
                BootArgs = selectedPlist.bootArgs.components(separatedBy: " ")
                
            }
            
        }
        
    }
    
    func addNewWord() {
        // lowercase and trim the word, to make sure we don't add duplicate words with case differences
        let answer = newBootArg.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // exit if the remaining string is empty
        guard answer.count > 0 else {
            return
        }
        
        // extra validation to come
        
        BootArgs.append(answer)
        newBootArg = ""
    }
    
    func FormatInstall() {
        
        isWorking = true
        var PlistToEdit = ""
        var OCName = ""
        var CurrentEFI = ""
        var CaseysFolder = ""
        
        let serialQueue = DispatchQueue(label: "Installing")
        let group = DispatchGroup()
        group.enter()
        
        serialQueue.async {
            
            if CancelMe { return}
            
            if selectedGPU == 0 {
                
                PlistToEdit = selectedPlist.link
                
            } else   if selectedGPU == 1 {
                
                PlistToEdit = selectedPlist.link
                
            }
            if CancelMe { return}
            ProgressValue += 5
            shell("rm -rf '\(tmp)/tmp/*'") { _, _ in
                shell("rm '\(tmp)/latestOC.zip'") { _, _ in}
                if CancelMe { return}
                group.leave()
            }
            
            
            
        }
        
        serialQueue.async {
            
            group.wait()
            group.enter()
            
            if sharedData.Updating == "Update" && !selectedDrive.name.isEmpty {
                
                if CancelMe { return}
                StatusText = "DON'T UNPLUG YOUR DRIVE!!"
                OCName = "OPENCORE_" + String(Int.random(in: 45..<843))
                shell("diskutil eraseDisk JHFS+  \(OCName) '\(selectedDrive.location)'") { req, _ in
                    
                    if   req.contains("Finished erase on ") {
                        
                        if CancelMe { return}
                        StatusText = "Erasing done!"
                        if let index = EFIs.firstIndex(where: { $0.parent == selectedDrive.location.replacingOccurrences(of: "/dev/", with: "")}) {
                            
                            EFIs.remove(at: index)
                            
                            ProgressValue += 5
                            
                        }
                        StatusText = "Mounting EFI..."
                        
                        CurrentEFI = mountEFI(UUID: selectedDrive.location.replacingOccurrences(of: "/dev/", with: "") + "s1", NAME: selectedDrive.name, user: sharedData.whoami, pwd: sharedData.Mypwd)
                        group.leave()
                    } else {
                        CancelMe = true
                    }
                    
                    ProgressValue += 10
                    if CancelMe { return}
                }
            } else {
                group.leave()
            }
            
        }
        
        serialQueue.async {  // call this whenever you need to add a new work item to your queue
            
            group.wait()
            group.enter()
            
            StatusText = "Cleaning folder..."
            ProgressValue += 5
            StatusText = "Lets Download..."
            shell("curl --silent https://hackindrom.zapto.org/app/public/uploads/\(selectedConfig.Archive)  -L -o '\(tmp)/latestOC.zip'") { req, _ in
                StatusText = "Download done..."
                shell("unzip '\(tmp)/latestOC.zip' -d '\(tmp)/tmp'") { _, _ in
                    StatusText = "Unzipped..."
                    if CancelMe { return}
                    group.leave()
                    
                }
            }
            
        }
        
        serialQueue.async {
            
            group.wait()
            group.enter()
            
            do {
                
                let GetCaseysFolder = try fileManager.contentsOfDirectory(at: URL(fileURLWithPath: "\(tmp)/tmp"), includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
                // #FIXME: check if archive was successfully downloaded
                CaseysFolder = GetCaseysFolder[0].lastPathComponent
                
                if CancelMe { return}
                ProgressValue += 5
                
                shell("mv '\(tmp)/tmp/\(CaseysFolder)/OC/\(PlistToEdit)' '\(tmp)/tmp/\(CaseysFolder)/OC/configo.plist'") { _, _ in
                    
                    group.leave()
                }
                
            } catch {
                
                print(error)
                
            }
            
        }
        serialQueue.async {
            
            group.wait()
            group.enter()
            
            if CancelMe { return}
            getHAPlistFrom("\(tmp)/tmp/\(CaseysFolder)/OC/configo.plist") { plist in
                
                var plist = plist
                
                
                if let KernelSection =  plist.childs.firstIndex(where: {$0.name == "Kernel"}) {
                    
                    if let PatchSection =  plist.childs[KernelSection].childs.firstIndex(where: {$0.name == "Patch"}) {
                        
                        for (ki, kentry) in plist.childs[KernelSection].childs[PatchSection].childs.enumerated() {
                            
                            
                            for (fi, eField) in kentry.childs.enumerated() {
                                
                                if (eField.name == "Replace" && eField.type == "data") && (eField.stringValue.localizedCaseInsensitiveCompare("B8CC00000000") == .orderedSame
                                                                                           || eField.stringValue.localizedCaseInsensitiveCompare("BACC00000000") == .orderedSame
                                                                                           || eField.stringValue.localizedCaseInsensitiveCompare("BACC00000090") == .orderedSame
                                                                                           || eField.stringValue.localizedCaseInsensitiveCompare("BACC000000") == .orderedSame
                                ) {
                                    plist.childs[KernelSection].childs[PatchSection].childs[ki].childs[fi].stringValue = eField.stringValue.replace(string: "CC", replacement: selectedCore)
                                }
                            }
                            
                        }
                    }
                }
                
                haPlistEncode(plist, "\(tmp)/tmp/\(CaseysFolder)/OC/configo.plist")
                group.leave()
            }
        }
        
        serialQueue.async {
            ProgressValue += 5
            group.wait()
            group.enter()
            if CancelMe { return}
            
            getHAPlistFrom("\(tmp)/tmp/\(CaseysFolder)/OC/configo.plist") { plist in
                var plist = plist
                
                plist.set(HAPlistStruct(stringValue: mycustomdata.MLB), to: ["PlatformInfo", "Generic", "MLB"])
                plist.set(HAPlistStruct(stringValue: mycustomdata.SystemSerialNumber), to: ["PlatformInfo", "Generic", "SystemSerialNumber"])
                plist.set(HAPlistStruct(stringValue: mycustomdata.SystemProductName.removeWhitespace()), to: ["PlatformInfo", "Generic", "SystemProductName"])
                plist.set(HAPlistStruct(stringValue: mycustomdata.SystemUUID), to: ["PlatformInfo", "Generic", "SystemUUID"])
                plist.set(HAPlistStruct(stringValue: mycustomdata.ROM, type: "data"), to: ["PlatformInfo", "Generic", "ROM"])
                plist.set(HAPlistStruct(stringValue: mycustomdata.SIP, type: "data"), to: ["NVRAM", "Add", "7C436110-AB2A-4BBB-A880-FE41995C9F82", "csr-active-config"]) // #FIXME: check if will work when target is nil
                
                plist.set(HAPlistStruct(stringValue: BootArgs.joined(separator: " "), type: "string"), to: ["NVRAM", "Add", "7C436110-AB2A-4BBB-A880-FE41995C9F82", "boot-args"])
                
                let path = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("workingHDx.plist")
                haPlistEncode(plist, path.relativePath)
                
                shell("mv '\(path.relativePath)' '\(tmp)/tmp/\(CaseysFolder)/OC/\(PlistToEdit)'") { req, _ in
                    
                    shell("rm '\(tmp)/tmp/\(CaseysFolder)/OC/configo.plist'") { _, _ in
                        
                        group.leave()
                    }
                    
                }
            }
            
        }
        
        serialQueue.async {
            ProgressValue += 5
            group.wait()
            group.enter()
            
            if CancelMe { return}
            shell("mv '\(tmp)/tmp/\(CaseysFolder)/OC/\(PlistToEdit)' '\(tmp)/tmp/\(CaseysFolder)/OC/config.plist'") { _, _ in
                group.leave()
            }
            
        }
        
        serialQueue.async {
            ProgressValue += 5
            group.wait()
            group.enter()
            
            do {
                
                let FindPlists = try fileManager.contentsOfDirectory(at: URL(fileURLWithPath: "\(tmp)/tmp/\(CaseysFolder)/OC"), includingPropertiesForKeys: nil)
                let plists =  FindPlists.filter { $0.pathExtension == "plist" }
                
                for plist in plists {
                    
                    if  plist.lastPathComponent != "config.plist" {
                        
                        try!   fileManager.removeItem(at: plist)
                        
                    }
                }
            } catch {
                
                print(error)
            }
            
            group.leave()
        }
        
        serialQueue.async {
            ProgressValue += 5
            group.wait()
            
            group.enter()
            
            StatusText = "Cleaning EFI folder..."
            if sharedData.Updating == "Update" &&  SelectedFolder != "" {
                CurrentEFI =   SelectedFolder
                
                shell("rm -R '\(CurrentEFI)/EFI'") { _, _ in
                    
                    
                }
            } else if sharedData.Updating.contains("Install") {
                
                CurrentEFI = EFIs[sharedData.CurrentEFI].mounted
                shell("rm -rf '\(CurrentEFI)/EFI'") { _, _ in
                    
                }
            } else {
                if CancelMe { return}
                
            }
            group.leave()
        }
        
        serialQueue.async {
            ProgressValue += 5
            group.wait()
            group.enter()
            
            shell("mv '\(tmp)/tmp/\(CaseysFolder)' '\(CurrentEFI)/EFI'") { _, _ in
                
                ProgressValue += 5
                if SelectedFolder == "" {
                    
                    EFIs = getEFIList()
                    
                }
                var notifmsg = ""
                if SelectedFolder != "" {
                    
                    notifmsg = "Just saved OC \(selectedConfig.ocvs) EFI in \(SelectedFolder)"
                    
                } else if !selectedDrive.name.isEmpty {
                    
                    notifmsg = "Just installed OC \(selectedConfig.ocvs) into \(selectedDrive.name)"
                } else if sharedData.Updating.contains("Install") {
                    
                    notifmsg = "Just installed OC \(selectedConfig.ocvs) into \(EFIs[sharedData.CurrentEFI].name)"
                    
                }
                SetNotif("Your EFI is ready!", notifmsg)
                NSWorkspace.shared.open(URL(fileURLWithPath: CurrentEFI, isDirectory: true))
                
                isWorking = false
                
                sharedData.currentview = 0
                group.leave()
            }
            
        }
        
    }
    
}
