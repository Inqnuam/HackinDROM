//
//  InstallView.swift
//  HackinDROM EFI
//
//  Created by Inqnuam 05/02/2021.
//  Copyright © 2021 HackinDROM. All rights reserved.
//

import Foundation
import SwiftUI
import Scout
import Zip

struct InstallView: View {
    
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject var sharedData: HASharedData
    
    @Binding var EFIs: [EFI]
    @State var ProgressValue  = 0.0
    @State var DownloadColor: Color = Color.yellow
    @State var StatusText: String = ""
    @State var isWorking: Bool = false
    @State var KextList: [KextStructs] = []
    @State var mycustomdata = MyHackDataStrc()
    @State var PreparingKexts: [SelectingKexts] = []
    @State var PreparingAMLs: [SelectingAMLs] = []
    @State var PreparingDrivers: [SelectingDrivers] = []
    @State var Currentindex: Int = 100
    @State var MySystem = ""
    @Binding var isCharging: Bool
    
    @State var CancelMe: Bool = false
    @AppStorageCompat("MyBuildID") var Motherboard = ""
    @AppStorageCompat("GPU") var GPU = 0
    
    @State private var showingSheet = false
    @State var buildID: Int = 0
    @State var localPlist = HAPlistStruct()
    @State var caseyPlist = HAPlistStruct()
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
                .disabled(isWorking)
            
            Spacer()
            if isWorking {
                Section {
                    
                    if #available(OSX 11.0, *) {
                        Text(StatusText)
                        Spacer()
                        ProgressView(value: ProgressValue, total: 100.0)
                            .accentColor(DownloadColor)
                            .scaleEffect(x: 1, y: 4, anchor: .center)
                    } else {
                        
                        Text("Updating....:")
                            .foregroundColor(DownloadColor)
                        Text(StatusText)
                    }
                    
                }
            }
        }
        .padding(15)
        Divider()
        Button(MySystem) {
            withAnimation {
                sharedData.currentview = 3
            }
        }
        .buttonStyle(LinkButtonStyle())
        NavigationView {
            
            List {
                
                NavigationLink(destination: PlatformInfo(mycustomdata: $mycustomdata, isWorking: isWorking).environmentObject(sharedData)) {
                    
                    Text("Info")
                    
                }
                
                NavigationLink(destination: ACPI(PreparingAMLs: self.$PreparingAMLs, isWorking: isWorking).environmentObject(sharedData)) {
                    
                    Text("ACPI")
                    
                }
                
                NavigationLink(destination: KextsView(PreparingKexts: self.$PreparingKexts, isWorking: isWorking).environmentObject(sharedData)) {
                    
                    Text("Kexts")
                    
                }
                
                NavigationLink(destination: DriversView(PreparingDrivers: self.$PreparingDrivers,  isWorking: isWorking).environmentObject(sharedData)) {
                    
                    Text("Drivers")
                    
                }
                
            }.listStyle(SidebarListStyle())
            
        }
        
        HStack {
            
            
            
            
            if !sharedData.AllBuilds.isEmpty {
                if sharedData.AllBuilds.indices.contains(Currentindex) {
                    if !sharedData.AllBuilds[Currentindex].latest.notes.isEmpty {
                        //
                        
                        Button(action: {
                            buildID = sharedData.AllBuilds[Currentindex].configs.firstIndex(where: { $0.id == sharedData.AllBuilds[Currentindex].latest.id }) ?? 0
                            showingSheet.toggle()
                            
                        }, label: {
                            
                            if !sharedData.AllBuilds[Currentindex].latest.warning {
                                Text("Release Notes")
                            } else {
                                
                                Text("⚠️")
                            }
                            
                        })
                        
                    } else if !sharedData.AllBuilds[Currentindex].latest.followLink.isEmpty {
                        
                        Button(action: {
                            
                            OpenSafari(sharedData.AllBuilds[Currentindex].latest.followLink)
                        }, label: {
                            
                            if !sharedData.AllBuilds[Currentindex].latest.warning {
                                Image(nsImage: NSImage(named: NSImage.touchBarOpenInBrowserTemplateName)!)
                            } else {
                                
                                Text("⚠️")
                            }
                        })
                        
                    }
                }
            }
            
            Spacer()
            
            Button(action: {
                if !isWorking {
                    InstallUpdateOC()
                } else {
                    CancelMe = true
                    DownloadColor = .red
                    StatusText = "Canceling..."
                    
                    
                    
                    self.EFIs = getEFIList()
                    sharedData.currentview = 0
                    
                    
                }
                
            }, label: {
                
                if !isWorking {
                    if sharedData.Updating == "Update" {
                        Text("Update OpenCore")
                        
                    } else {
                        
                        Text("New Build")
                    }
                    
                } else {
                    Text("Cancel")
                }
                
            })
                .disabled(PreparingKexts.isEmpty || PreparingAMLs.isEmpty || PreparingDrivers.isEmpty || CancelMe)
        }
        .padding( 10)
        .onAppear {
            
            if let index = sharedData.AllBuilds.firstIndex(where: { $0.id == Motherboard}) {
                
                MySystem = GPU == 0 ? "\(sharedData.AllBuilds[index].vendor) \(sharedData.AllBuilds[index].name) - AMD GPU" : "\(sharedData.AllBuilds[index].vendor) \(sharedData.AllBuilds[index].name) - Intel iGPU"
                
                Currentindex = index
                
            }
            
            ProgressValue = 0
            mycustomdata =  GetPlatformInfo()
            
            StatusText = ""
            
            if sharedData.Updating == "Update" {
                
                DispatchQueue.global(qos: .background).async {
                    self.PreparingAMLs = MergeAMLs()
                    
                    self.PreparingKexts = MergeKexts()
                    self.PreparingDrivers = MergeDrivers()
                    
                }
            }
            getHAPlistFrom(EFIs[sharedData.CurrentEFI].mounted + "/EFI/OC/config.plist") {plist in
                localPlist = plist
            }
            
            getHAPlistFrom(EFIs[sharedData.CurrentEFI].mounted + "/EFI/OC/config.plist") {plist in
                caseyPlist = plist
            }
        }
        
        .onReceive(ClosePopoNotif) { (_) in
            if showingSheet {
                
                showingSheet = false
            }
            
        }
        .sheet(isPresented: $showingSheet) {
            
            SheetView(build: $sharedData.AllBuilds[Currentindex]).environmentObject(sharedData)
            
            
        }
    }
    
    func InstallUpdateOC() {
        
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
        let CurrentEFI = EFIs[sharedData.CurrentEFI].mounted
        guard  let plist = fileManager.contents(atPath: "\(CurrentEFI)/EFI/OC/config.plist") else {
            CancelMe = true
            DownloadColor = .red
            StatusText = "Canceling..."
            
            
            
            self.EFIs = getEFIList()
            sharedData.currentview = 0
            
            return
            
        }
        
        var pathu = ""
        isWorking = true
        let serialQueue = DispatchQueue(label: "serialQueue")
        let group = DispatchGroup()
        var DownloadLink = ""
        let LinkOfLatestOC = sharedData.OpenCoreDownloadLink
        let url = URL(string: "https://hackindrom.zapto.org/app/public/uploads/\(sharedData.CaseyLastestOCArchive)")!
        var CaseysFolder = ""
        var newplace = ""
        var SendingAMLs: [AMLs] = []
        var SendingKexts: [Kexts] = []
        var SendingDrivers: [Drivers] = []
        
        var BackupFolder = ""
        let BackUpsCustomFolder = UserDefaults.standard.string(forKey: "BackUpsCustomFolder")
        let BackUpsToFolder = UserDefaults.standard.bool(forKey: "BackUpToFolder")
        
        if BackUpsToFolder {
            
            BackupFolder = BackUpsCustomFolder ?? fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!.relativePath + "/HackinDROMBackUps"
            
        } else {
            
            BackupFolder = CurrentEFI
        }
        let randomnumber = "_OC_\(EFIs[sharedData.CurrentEFI].OCv)_" + CreateTodayDate()
        StatusText = "Cleaning"
        
        StatusText = "Backup"
        
        group.enter()
        serialQueue.async {  // call this whenever you need to add a new work item to your queue
            mycustomdata.SIP = mycustomdata.SIP.removeWhitespace()
            if mycustomdata.SIP == "" {
                
                mycustomdata.SIP = "00000000"
            }
            
            for aml in PreparingAMLs {
                
                if !aml.isSelected && !aml.AML.Enabled && fileManager.fileExists(atPath: "\(CurrentEFI)/EFI/OC/ACPI/\(aml.AML.Path)") {
                    
                    SendingAMLs.append(aml.AML)
                    
                } else {
                    SendingAMLs.append(aml.AML)
                }
                
                
            }
            
            for driver in PreparingDrivers {
                
                if driver.isSelected {
                    
                    SendingDrivers.append(driver.Driver)
                    
                }
                
                
            }
            
            for kext in PreparingKexts {
                if CancelMe { return}
                
                
                if !kext.isSelected && !kext.Kext.Enabled && fileManager.fileExists(atPath: "\(CurrentEFI)/EFI/OC/Kexts/\(kext.Kext.BundlePath)") {
                    
                    if kext.Kext.BundlePath == "Lilu.kext" {
                        SendingKexts.insert(kext.Kext, at: 0)
                    } else if kext.Kext.BundlePath == "VirtualSMC.kext" {
                        SendingKexts.insert(kext.Kext, at: 1)
                    } else {
                        SendingKexts.append(kext.Kext)
                    }
                    
                    
                } else {
                    if kext.Kext.BundlePath == "Lilu.kext" {
                        SendingKexts.insert(kext.Kext, at: 0)
                    } else if kext.Kext.BundlePath == "VirtualSMC.kext" {
                        SendingKexts.insert(kext.Kext, at: 1)
                    } else {
                        SendingKexts.append(kext.Kext)
                    }
                    
                }
                
                
                
            }
            
            
            
            if CancelMe { return}
            group.leave()
            
        }
        
        serialQueue.async {  // call this whenever you need to add a new work item to your queue
            
            group.wait()
            group.enter()
            let myPlist = HAPlistContent()
            if myPlist.loadPlist(filePath: "\(CurrentEFI)/EFI/OC/config.plist", isTemplate: false) {
                
                let _ =  myPlist.pContent.set(HAPlistStruct(name:"MLB", StringValue: mycustomdata.MLB, type: "string"), to: ["PlatformInfo", "Generic", "MLB"])
                
                let _ =  myPlist.pContent.set(HAPlistStruct(name:"SystemSerialNumber", StringValue: mycustomdata.SystemSerialNumber, type: "string"), to: ["PlatformInfo", "Generic", "SystemSerialNumber"])

                let _ =  myPlist.pContent.set(HAPlistStruct(name:"SystemProductName", StringValue: mycustomdata.SystemProductName, type: "string"), to: ["PlatformInfo", "Generic", "SystemProductName"])
                
                let _ =  myPlist.pContent.set(HAPlistStruct(name:"SystemUUID", StringValue: mycustomdata.SystemUUID, type: "string"), to: ["PlatformInfo", "Generic", "SystemUUID"])
                
                
                let _ = myPlist.pContent.set(HAPlistStruct(name:"boot-args", StringValue: mycustomdata.BootArgs, type: "string"), to: ["NVRAM", "Add", "7C436110-AB2A-4BBB-A880-FE41995C9F82", "boot-args"])
                
                let _ = myPlist.pContent.set(HAPlistStruct(name:"ROM", StringValue: mycustomdata.ROM, type: "data"), to: ["PlatformInfo", "Generic", "ROM"])
                
                let _ = myPlist.pContent.set(HAPlistStruct(name:"csr-active-config", StringValue: mycustomdata.SIP, type: "data"), to: ["NVRAM", "Add", "7C436110-AB2A-4BBB-A880-FE41995C9F82", "csr-active-config"])
                
                let pathik = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("workingHD.plist")
                pathu = pathik.relativePath
                if  myPlist.saveplist(newPath: pathu) {
                    group.leave()
                } else {
                    DownloadColor =  Color.red
                    StatusText = "Error while saving plist"
                }
            } else {
                DownloadColor =  Color.red
                StatusText = "Plist not found"
            }
              
        }
        
        serialQueue.async {
            
            group.wait()
            group.enter()
            if CancelMe { return}
            UpdatePlist(pathu, SendingAMLs, SendingKexts, SendingDrivers, CaseyLatestPlist: sharedData.CaseyLatestPlist, v: sharedData.OCv) { gang in
                
                DownloadLink = gang
                
                if !DownloadLink.isEmpty {
                    StatusText = "Downloading files.."
                    shell("curl --silent '\(DownloadLink)'  -L -o '\(pathu)'") { res, _ in
                        StatusText = "Ready to update"
                        print(res)
                        if fileManager.fileExists(atPath: "\(CurrentEFI)/EFI") {
                            
                            if fileManager.fileExists(atPath: "\(BackupFolder)/OLD_EFI.zip") {
                                
                                shell("mv '\(BackupFolder)/OLD_EFI.zip' '\(BackupFolder)/OLD_EFI\(randomnumber).zip'") { _, _ in
                                    
                                    ProgressValue += 5
                                    StatusText = "Creating Backup!!"
                                    if CancelMe { return}
                                    group.leave()
                                }
                                
                            } else {
                                
                                if CancelMe { return}
                                
                                group.leave()
                            }
                            
                        } else {
                            
                            if CancelMe { return}
                            group.leave()
                        }
                        
                    }
                    
                } else {
                    
                    CancelMe = true
                    
                    group.leave()
                }
                
            }
            
        }
        
        serialQueue.async {
            group.wait()
            group.enter()
            if CancelMe { return}
            shell("rm -rf '\(CurrentEFI)/.Trashes' '\(CurrentEFI)/MyOldEfi'") { _, _ in
                
                do {
                    
                    try Zip.zipFiles(paths: [URL(fileURLWithPath: "\(CurrentEFI)/EFI/")], zipFilePath: URL(fileURLWithPath: "\(BackupFolder)/OLD_EFI.zip"), password: nil, progress: { (progress) -> Void in
                        
                        if progress == 1.0 {
                            if CancelMe { return}
                            StatusText = "Backup OK!"
                            ProgressValue += 5
                            
                            StatusText = "Working on EFI"
                            shell("mv '\(CurrentEFI)/EFI' '\(CurrentEFI)/MyOldEfi'") { _, _ in
                                StatusText = "EFI Cleaned!"
                                ProgressValue += 5
                                if CancelMe { return}
                                group.leave()
                            }
                            
                        }
                        
                    })
                } catch {
                    
                    print(error)
                }
                
            }
            
        }
        serialQueue.async {
            group.wait()
            group.enter()
            
            if CancelMe { return}
            // DispatchQueue
            ProgressValue += 5
            
            StatusText = "Downloading..."
            
            ProgressValue += 5
            FileDownloader.loadFileAsync(url: url) { (path, error) in
                
                ProgressValue += 5
                StatusText = "Preparing OC"
                
                StatusText = "Let me work"
                let name = URL(fileURLWithPath: path!).lastPathComponent // nom apres dernier slash
                
                newplace = path!.replacingOccurrences(of: name, with: "HackinDROM" + String(Int.random(in: 45..<843)))
                
                if CancelMe { return}
                StatusText = "Unzipping Archive"
                
                shell("unzip '\(path!)' -d '\(newplace)'") { _, _ in
                    ProgressValue += 15
                    if CancelMe { return}
                    StatusText = "Unzipped"
                    do {
                        let GetCaseysFolder = try fileManager.contentsOfDirectory(at: URL(fileURLWithPath: newplace), includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
                        
                        CaseysFolder = GetCaseysFolder[0].lastPathComponent
                        
                        StatusText = "Patching new OC"
                        shell("rm '\(path!)'") { _, _ in
                            shell("curl --silent '\(LinkOfLatestOC)'  -L -o '\(newplace)/latestOC.zip'") { _, _ in
                                if CancelMe { return}
                                
                                StatusText = "Let's unzip LatestOC"
                                
                                shell("unzip '\(newplace)/latestOC.zip' -d '\(newplace)/latestOC'") { _, _ in
                                    StatusText = "Unzipped"
                                    
                                    shell("rm '\(newplace)/latestOC.zip'") { _, _ in
                                        ProgressValue += 5
                                        if CancelMe { return}
                                        group.leave()
                                    }
                                    
                                }
                            }
                            
                        }
                    } catch {
                        print(error)
                        
                    }
                }
                
            }
            
        }
        
        serialQueue.async {
            group.wait()
            group.enter()
            if CancelMe { return}
            
            shell("mv '\(pathu)' '\(newplace)/\(CaseysFolder)/OC/config.plist'") { res, _ in
                print(res)
                let FindPlists = try? fileManager.contentsOfDirectory(at: URL(fileURLWithPath: "\(newplace)/\(CaseysFolder)/OC/"), includingPropertiesForKeys: nil)
                let plists =  FindPlists!.filter { $0.pathExtension == "plist" }
                
                StatusText = "Cleaning plists..."
                for plist in plists {
                    
                    if  plist.lastPathComponent.localizedCaseInsensitiveCompare("config.plist") != .orderedSame {
                        
                        shell("rm '\(plist.relativePath)'") { _, _ in}
                        
                    }
                }
                ProgressValue += 5
                
                group.leave()
            }
            
        }
        
        serialQueue.async {
            group.wait()
            group.enter()
            
            do {
                
                if CancelMe { return}
                
                StatusText = "Updating Kexts."
                
                for kext in PreparingKexts {
                    
                    if kext.isSelected {
                        if !fileManager.fileExists(atPath: "\(newplace)/\(CaseysFolder)/OC/Kexts/\(kext.Kext.BundlePath)") {
                            
                            if kext.DownloadLink == "YES" {
                                
                                let downloadthis = GetGitHubDownloadLink(kext.Kext.BundlePath.replacingOccurrences(of: ".kext", with: ""))
                                if downloadthis.count > 10 {
                                    StatusText = "Downloading \(kext.Kext.BundlePath.replacingOccurrences(of: ".kext", with: ""))"
                                    
                                    let downloadedkextname = kext.Kext.BundlePath + String(Int.random(in: 45..<843))
                                    
                                    shell("curl --silent '\(downloadthis)'  -L -o '\(newplace)/\(downloadedkextname).zip'") { _, _ in
                                        
                                        shell("unzip '\(newplace)/\(downloadedkextname).zip' -d '\(newplace)/downloaded'") { _, _ in
                                            
                                            shell("rm '\(newplace)/\(downloadedkextname).zip'") { _, _ in}
                                        }
                                    }
                                    let FindKexts = try fileManager.contentsOfDirectory(at: URL(fileURLWithPath: "\(newplace)/downloaded"), includingPropertiesForKeys: nil)
                                    let kexts =  FindKexts.filter { $0.pathExtension == "kext" }
                                    
                                    shell("rm -rf '\(newplace)/\(CaseysFolder)/OC/Kexts/\(kexts[0].lastPathComponent)'") { _, _ in
                                        
                                        shell("mv -r '\(newplace)/downloaded/\(kexts[0].lastPathComponent)' '\(newplace)/\(CaseysFolder)/OC/Kexts/\(kexts[0].lastPathComponent)'") { _, _ in}
                                    }
                                    
                                    shell("rm -rf '\(newplace)/downloaded'") { _, _ in}
                                    
                                }
                            } else {
                                
                                shell("rm -rf '\(newplace)/\(CaseysFolder)/OC/Kexts/\(kext.Kext.BundlePath)'") { _, _ in
                                    
                                    shell("cp -a '\(CurrentEFI)/MyOldEfi/OC/Kexts/\(kext.Kext.BundlePath)' '\(newplace)/\(CaseysFolder)/OC/Kexts/\(kext.Kext.BundlePath)'") { _, _ in}
                                }
                            }
                            
                        }
                        
                    } else {
                        if fileManager.fileExists(atPath: "\(CurrentEFI)/MyOldEfi/OC/Kexts/\(kext.Kext.BundlePath)") {
                            
                            shell("rm -rf '\(newplace)/\(CaseysFolder)/OC/Kexts/\(kext.Kext.BundlePath)'") { _, _ in
                                
                                shell("cp -a '\(CurrentEFI)/MyOldEfi/OC/Kexts/\(kext.Kext.BundlePath)' '\(newplace)/\(CaseysFolder)/OC/Kexts/\(kext.Kext.BundlePath)'") { _, _ in
                                    StatusText = "\(kext.Kext.BundlePath) copied"
                                }
                            }
                            
                        }
                        
                    }
                    if CancelMe { return}
                    StatusText = "Updating Kexts.."
                }
                ProgressValue += 5
                let CaseyKexts =  try fileManager.contentsOfDirectory(at: URL(fileURLWithPath: "\(newplace)/\(CaseysFolder)/OC/Kexts"), includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
                
                StatusText = "Updating Kexts..."
                for kext in CaseyKexts {
                    if  SendingKexts.firstIndex(where: {$0.BundlePath == kext.lastPathComponent}) == nil {
                        
                        try fileManager.removeItem(at: kext) /////// ????
                        
                        shell("rm -rf '\(kext.relativePath)'") { _, _ in} /////////////// ???
                    }
                    
                }
                
                if CancelMe { return}
                
                ProgressValue += 5
                let CaseyDrivers =  try fileManager.contentsOfDirectory(at: URL(fileURLWithPath: "\(newplace)/\(CaseysFolder)/OC/Drivers"), includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
                
                for driver in CaseyDrivers {
                    
                    if  SendingDrivers.firstIndex(where: {$0.Path == driver.lastPathComponent}) == nil {
                        
                        shell("rm  '\(driver.relativePath)'") { _, _ in
                            
                        }
                    }
                    if CancelMe { return}
                    
                }
                
                for driver in PreparingDrivers {
                    StatusText = "Working with \(driver.Driver.Path.replacingOccurrences(of: ".efi", with: ""))"
                    if driver.isSelected {
                        
                        if !fileManager.fileExists(atPath: "\(newplace)/\(CaseysFolder)/OC/Drivers/\(driver.Driver.Path)") {
                            
                            if fileManager.fileExists(atPath: "\(newplace)/latestOC/X64/EFI/OC/Drivers/\(driver.Driver.Path)") {
                                
                                shell("rm '\(newplace)/\(CaseysFolder)/OC/Drivers/\(driver.Driver.Path)'") { _, _ in
                                    
                                    shell("mv '\(newplace)/latestOC/X64/EFI/OC/Drivers/\(driver.Driver.Path)' '\(newplace)/\(CaseysFolder)/OC/Drivers/\(driver.Driver.Path)'") { _, _ in}
                                }
                                
                            }
                            
                            if CancelMe { return}
                        }
                    } else {
                        
                        if fileManager.fileExists(atPath: "\(CurrentEFI)/MyOldEfi/OC/Drivers/\(driver.Driver.Path)") {
                            
                            shell("rm '\(newplace)/\(CaseysFolder)/OC/Drivers/\(driver.Driver.Path)'") { _, _ in
                                
                                shell("mv '\(CurrentEFI)/MyOldEfi/OC/Drivers/\(driver.Driver.Path)' '\(newplace)/\(CaseysFolder)/OC/Drivers/\(driver.Driver.Path)'") { _, _ in}
                            }
                            
                        }
                        
                    }
                    
                }
                
                if CancelMe { return}
                
                let DownlodedAMLs =  try fileManager.contentsOfDirectory(at: URL(fileURLWithPath: "\(newplace)/\(CaseysFolder)/OC/ACPI"), includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
                
                ProgressValue += 5
                for aml in DownlodedAMLs {
                    
                    if  PreparingAMLs.firstIndex(where: {$0.isSelected && $0.AML.Path == aml.lastPathComponent}) == nil {
                        
                        try  fileManager.removeItem(atPath: "\(newplace)/\(CaseysFolder)/OC/ACPI/\(aml.lastPathComponent)")
                        StatusText = aml.lastPathComponent.replacingOccurrences(of: ".aml", with: "") + " removed"
                    }
                    
                }
                
                StatusText = "Removed AMLs"
                ProgressValue += 5
                if CancelMe { return}
                for aml in PreparingAMLs {
                    
                    if aml.isSelected {
                        StatusText = "Patching \(aml.AML.Path.replacingOccurrences(of: ".aml", with: ""))"
                        if !fileManager.fileExists(atPath: "\(newplace)/\(CaseysFolder)/OC/ACPI/\(aml.AML.Path)") {
                            shell("rm '\(newplace)/\(CaseysFolder)/OC/ACPI/\(aml.AML.Path)'") { _, _ in
                                
                                shell("cp '\(CurrentEFI)/MyOldEfi/OC/ACPI/\(aml.AML.Path)' '\(newplace)/\(CaseysFolder)/OC/ACPI/\(aml.AML.Path)'") { _, _ in
                                    StatusText = "\(aml.AML.Path) copied"
                                }
                            }
                            
                        }
                    } else {
                        
                        shell("rm '\(newplace)/\(CaseysFolder)/OC/ACPI/\(aml.AML.Path)'") { _, _ in
                            
                            shell("cp '\(CurrentEFI)/MyOldEfi/OC/ACPI/\(aml.AML.Path)' '\(newplace)/\(CaseysFolder)/OC/ACPI/\(aml.AML.Path)'") { _, _ in
                                StatusText = "\(aml.AML.Path) copied"
                            }
                        }
                        
                    }
                    
                }
                StatusText = "AMLs merged!"
                ProgressValue += 5
                
                if CancelMe { return}
                
                StatusText = "Working with OC Tools."
                
                let MyCurrentTools =  try fileManager.contentsOfDirectory(at: URL(fileURLWithPath: "\(CurrentEFI)/MyOldEfi/OC/Tools"), includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
                
                for tool in MyCurrentTools {
                    StatusText = "Working with \(tool.lastPathComponent)"
                    if !fileManager.fileExists(atPath: "\(newplace)/\(CaseysFolder)/OC/Tools/\(tool.lastPathComponent)") {
                        
                        if fileManager.fileExists(atPath: "\(newplace)/latestOC/X64/EFI/OC/Tools/\(tool.lastPathComponent)") {
                            
                            try fileManager.copyItem(atPath: "\(newplace)/latestOC/X64/EFI/OC/Tools/\(tool.lastPathComponent)", toPath: "\(newplace)/\(CaseysFolder)/OC/Tools/")
                            
                        }
                        
                    }
                    
                }
                StatusText = "OC Tools OK!"
                StatusText = "Working with Icons."
                ProgressValue += 5
                if CancelMe { return}
                let OCNewIcons =  try fileManager.contentsOfDirectory(at: URL(fileURLWithPath: "\(newplace)/\(CaseysFolder)/OC/Resources/Image"), includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
                
                for icon in OCNewIcons {
                    
                    if fileManager.fileExists(atPath: "\(CurrentEFI)/MyOldEfi/OC/Resources/Image/\(icon.lastPathComponent)") {
                        
                        try fileManager.removeItem(atPath: "\(newplace)/\(CaseysFolder)/OC/Resources/Image/\(icon.lastPathComponent)")
                        
                        try fileManager.copyItem(atPath: "\(CurrentEFI)/MyOldEfi/OC/Resources/Image/\(icon.lastPathComponent)", toPath: "\(newplace)/\(CaseysFolder)/OC/Resources/Image/\(icon.lastPathComponent)")
                        
                    }
                    
                }
                
                if CancelMe { return}
                let OCOLDIcons =  try fileManager.contentsOfDirectory(at: URL(fileURLWithPath: "\(CurrentEFI)/MyOldEfi/OC/Resources/Image/"), includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
                StatusText = "Working with Icons..."
                if CancelMe { return}
                for icon in OCOLDIcons {
                    
                    if !fileManager.fileExists(atPath: "\(newplace)/\(CaseysFolder)/OC/Resources/Image/\(icon.lastPathComponent)") {
                        
                        try fileManager.copyItem(atPath: "\(CurrentEFI)/MyOldEfi/OC/Resources/Image/\(icon.lastPathComponent)", toPath: "\(newplace)/\(CaseysFolder)/OC/Resources/Image/\(icon.lastPathComponent)")
                        
                    }
                    
                }
                StatusText = "Icons OK"
                if CancelMe { return}
                
            } catch {
                
                print(error)
                
            }
            group.leave()
            
        }
        serialQueue.async {
            group.wait()
            group.enter()
            StatusText = "Checking old files.."
            if CancelMe { return}
            
            do {
                let EFIContent = try fileManager.contentsOfDirectory(atPath: "\(CurrentEFI)/MyOldEfi/")
                
                
                for item in EFIContent {
                    
                    if item != "OC" && item != "APPLE" && item != "BOOT" {
                        
                        shell("cp -a '\(CurrentEFI)/MyOldEfi/\(item)' '\(newplace)/\(CaseysFolder)' ") { _, _ in }
                        
                    }
                }
                group.leave()
            } catch {
                print(error)
            }
            
            
            
        }
        serialQueue.async {
            group.wait()
            group.enter()
            StatusText = "Finishing.."
            if CancelMe { return}
            
            shell("rm -rf '\(CurrentEFI)/MyOldEfi'") { _, _ in
                shell("rm -rf '\(CurrentEFI)/.Trashes'") { _, _ in
                    
                    if CancelMe { return}
                    StatusText = "MyOldEfi removed! ⚰️"
                    
                    shell("cp -a '\(newplace)/\(CaseysFolder)' '\(CurrentEFI)/EFI'") { _, _ in
                        StatusText = "Finishing..."
                        shell("rm -rf '\(newplace)'") { _, _ in
                            
                            StatusText = "EFI moved! ⚰️"
                            ProgressValue += 5
                            
                            if CancelMe { return}
                            StatusText = "Tmp removed! ⚰️"
                            
                            StatusText = "EFI Ready 🧪"
                            
                            ProgressValue += 5
                            
                            group.leave()
                            
                        }
                    }
                    
                }
                
            }
            
        }
        serialQueue.async {
            group.wait()
            group.enter()
            
            if let index = sharedData.AllBuilds.firstIndex(where: { $0.id == Motherboard}) {
                
                StatusText =   "Thank to \(sharedData.AllBuilds[index].leader) :)"
                
            }
            
            DownloadColor = Color.green
            EFIs[sharedData.CurrentEFI].OCv = sharedData.OCv
            
            
            
            
            withAnimation {
                nc.post(name: Notification.Name("JustMounted"), object: nil, userInfo: ["JustMounted": ""])
                sharedData.currentview = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                
                NSWorkspace.shared.open(URL(fileURLWithPath: CurrentEFI, isDirectory: true))
            }
            SetNotif("Your EFI is ready!", "Just installed OC \(sharedData.OCv) on \(EFIs[sharedData.CurrentEFI].Name)")
            group.leave()
            
        }
        
    }
    
    func MergeKexts() -> [SelectingKexts] {
        
        let LocalKexts = GetKexts(localPlist)
        var CaseyKexts =  sharedData.CaseyKexts
        var MergedKexts: [SelectingKexts] = []
        self.KextList = getMyKextList(EFIs[sharedData.CurrentEFI].mounted, sharedData.CaseyKextsList)
        
        for MyKext in LocalKexts {
            
            if CaseyKexts.firstIndex(where: { $0.BundlePath == MyKext.BundlePath }) == nil {
                if let indeX =  self.KextList.firstIndex(where: { $0.name.lowercased() == MyKext.BundlePath.replacingOccurrences(of: ".kext", with: "").lowercased() }) {
                    
                    MergedKexts.append(SelectingKexts(
                        Kext: MyKext,
                        isSelected: true,
                        DownloadLink: self.KextList[indeX].isUpdatable ? self.KextList[indeX].DownloadLink : ""
                    )
                                       
                    )
                    
                }
                
            }
            
        }
        
        for (index, CasKext) in CaseyKexts.enumerated() {
            
            if let LocIndex = LocalKexts.firstIndex(where: { $0.BundlePath.lowercased() == CasKext.BundlePath.lowercased() }) {
                
                CaseyKexts[index].Enabled = LocalKexts[LocIndex].Enabled
                
                MergedKexts.append(SelectingKexts(
                    Kext: CaseyKexts[index],
                    isSelected: true,
                    DownloadLink: ""))
                
            } else {
                
                MergedKexts.append(SelectingKexts(
                    Kext: CasKext,
                    isSelected: true,
                    DownloadLink: ""))
                
            }
            
        }
        
        MergedKexts.sort {
            $0.Kext.BundlePath < $1.Kext.BundlePath
        }
        
        return MergedKexts
    }
    
    func MergeAMLs() -> [SelectingAMLs] {
        var MergedAMLs: [SelectingAMLs] = []
        let LocalAMLs = GetAMLs(localPlist)
        var CaseyAMLs = sharedData.CaseyAMLs
        
        
        
        for MyAML in LocalAMLs {
            
            if CaseyAMLs.firstIndex(where: { $0.Path == MyAML.Path }) == nil {
                
                MergedAMLs.append(SelectingAMLs(
                    AML: MyAML,
                    isSelected: true
                )
                                  
                )
                
            }
            
        }
        
        for (index, CasAML) in CaseyAMLs.enumerated() {
            
            if let LocIndex = LocalAMLs.firstIndex(where: { $0.Path == CasAML.Path }) {
                
                CaseyAMLs[index].Enabled = LocalAMLs[LocIndex].Enabled
                
                MergedAMLs.append(SelectingAMLs(
                    AML: CaseyAMLs[index],
                    isSelected: true
                )
                )
                
            } else {
                
                MergedAMLs.append(SelectingAMLs(
                    AML: CasAML,
                    isSelected: true
                )
                )
                
            }
            
        }
        
        MergedAMLs.sort {
            $0.AML.Path < $1.AML.Path
        }
        
        return MergedAMLs
    }
    
    func MergeDrivers() -> [SelectingDrivers] {
        var mergedDrivers:[SelectingDrivers] = []
        
        let LocalDrivers = GetDrivers(localPlist, updateTo: sharedData.OCv)
        var CaseyDrivers = sharedData.CaseyDriversList
        for myDriver in LocalDrivers {
            
            if CaseyDrivers.firstIndex(where: { $0.Path == myDriver.Path }) == nil {
                
                mergedDrivers.append(SelectingDrivers(
                    Driver: myDriver,
                    isSelected: true
                )
                                     
                )
                
            }
        }
        
        
        for (index, CasDriver) in CaseyDrivers.enumerated() {
            
            if let LocIndex = LocalDrivers.firstIndex(where: { $0.Path.replacingOccurrences(of: "#", with: "").lowercased() == CasDriver.Path.replacingOccurrences(of: "#", with: "").lowercased() }) {
                
                CaseyDrivers[index].Enabled = LocalDrivers[LocIndex].Enabled
                
                mergedDrivers.append(SelectingDrivers(
                    Driver: CaseyDrivers[index],
                    isSelected: true
                )
                )
                
            } else {
                
                mergedDrivers.append(SelectingDrivers(
                    Driver: CasDriver,
                    isSelected: true
                )
                )
                
            }
            
        }
        
        mergedDrivers.sort {
            $0.Driver.Path < $1.Driver.Path
        }
        
        return mergedDrivers
    }
    
    func GetPlatformInfo() -> MyHackDataStrc {
        var PlatformInfo = MyHackDataStrc(MLB: "", ROM: "", SystemUUID: "", BootArgs: "", SystemSerialNumber: "", SystemProductName: "", OCV: "0.0.0", SIP: "")
        let config = EFIs[sharedData.CurrentEFI].mounted + "/EFI/OC/config.plist"
        
        guard  let xml = fileManager.contents(atPath: config) else { return PlatformInfo} // A VERIFIER CAR SI ON SUPPRIME LE DOSSIER MANUELEMENT ICI CA CRACHE
        do {
            let json = try PathExplorers.Plist(data: xml)
            
            PlatformInfo.MLB = try json.get("PlatformInfo", "Generic", "MLB").string ?? ""
            
            PlatformInfo.ROM = Base64toHex(try json.get("PlatformInfo", "Generic", "ROM").data?.base64EncodedString()  ?? "")
            
            PlatformInfo.SystemProductName = try json.get("PlatformInfo", "Generic", "SystemProductName").string ?? ""
            PlatformInfo.SystemSerialNumber = try json.get("PlatformInfo", "Generic", "SystemSerialNumber").string ?? ""
            PlatformInfo.SystemUUID = try json.get("PlatformInfo", "Generic", "SystemUUID").string ?? ""
            PlatformInfo.OCV = EFIs[sharedData.CurrentEFI].OCv
            PlatformInfo.BootArgs = try json.get("NVRAM", "Add", "7C436110-AB2A-4BBB-A880-FE41995C9F82", "boot-args").string ?? ""
            PlatformInfo.SIP = Base64toHex(try json.get("NVRAM", "Add", "7C436110-AB2A-4BBB-A880-FE41995C9F82", "csr-active-config").data?.base64EncodedString()  ?? "")
            
            return PlatformInfo
            
        } catch {
            
        }
        return PlatformInfo
    }
    
}

struct SelectingKexts:Identifiable, Hashable, Decodable, Encodable {
    var id = UUID()
    var Kext = Kexts()
    var isSelected: Bool = false
    var DownloadLink: String = ""
    
}

struct SelectingAMLs: Identifiable, Equatable  {
    let id = UUID()
    var AML = AMLs()
    var isSelected: Bool = false
    
}

struct SelectingDrivers: Identifiable,Hashable, Decodable, Encodable  {
    var id = UUID()
    var Driver = Drivers()
    var isSelected: Bool = false
    
}
