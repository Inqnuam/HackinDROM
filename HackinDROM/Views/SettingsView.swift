//
//  SettingsView.swift
//  HackinDROM EFI
//
//  Created by Inqnuam 07/02/2021.
//  Copyright © 2021 HackinDROM. All rights reserved.
//

import SwiftUI
import LaunchAtLogin
//import Scout
import UserNotifications
struct SettingsView: View {
    @EnvironmentObject var sharedData: HASharedData
    
    @AppStorageCompat("Vendor") var vendor = ""
    @AppStorageCompat("MyBuildID") var MyBuildID = ""
    @AppStorageCompat("GPU") var GPU = 0
    @AppStorageCompat("Wifi") var Wifi = 0
    
    @AppStorageCompat("HideWindow") var HideWindow = false
    @AppStorageCompat("FirstOpen") var FirstOpen = true
    @AppStorageCompat("MountAutomaticly") var MountAutomaticly = false
    @AppStorageCompat("BackUpsCustomFolder") var BackUpsCustomFolder = ""
    @AppStorageCompat("BackUpToFolder") var BackUpsToFolder = false
    
    @State var StatusText: String = ""
    
    @State var HideMySerials: Bool = true
    @State var NewSelection: Bool = false
    @State var isAvailable: Bool = false
    @AppStorageCompat("Notifications") var Notifications:Bool = false
    @State var NotificationsAllowed:Bool = false
    @State var NotificationDenied:Bool = false
    @State var selectedBuild = AllBuilds()
    @State var selectedConfig = BuildConfigs()
    @State var selectedPlist = PlistData()
    var body: some View {
        
        if !FirstOpen {
            HStack {
                
                Button(action: {
                    sharedData.currentview = 0
                    
                }, label: {
                    if #available(macOS 11.0, *) {
                        
                        Image(systemName: "arrow.backward")
                        
                    } else {
                        
                        Text("←")
                        
                    }
                    
                }
                )
                
                    .padding(.leading, 5)
                    .padding(.top, 8)
                
                Spacer()
                
                Text(StatusText)
                
                    .bold()
                
                Button(action: {
                    
                    HideMySerials.toggle()
                }, label: {
                    if #available(macOS 11.0, *) {
                        Image(systemName: HideMySerials ? "eye" : "eye.slash")
                    } else {
                        Image(HideMySerials ? "eye" : "eye.slash")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                        
                    }
                })
            }
            .onHover { inside in
                
                if inside {
                    
                    StatusText = ""
                }
            }
            
            .padding(.top, 10)
            .padding(.leading, 10)
            .padding(.trailing, 10)
            .padding(.bottom, 1)
            
        }
        
        Divider()
        ScrollView(.vertical, showsIndicators: false) {
            
            HStack {
                LaunchAtLogin.Toggle {
                    Text("Launch at login")
                        .toolTip("Lunch HackinDROM.app when the system boots")
                    
                }
                
                if NotificationDenied {
                    Button("Notifications") {
                        NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Library/PreferencePanes/Notifications.prefPane"))
                        
                    }
                    
                } else if NotificationsAllowed {
                    Toggle(isOn: $Notifications) {
                        Text("Notifications")
                        
                    }
                } else {
                    Button("Notifications") {
                        AskForNotifAuth()
                    }
                }
                
                
                Toggle(isOn: $MountAutomaticly) {
                    Text("Automatically mount EFI partitions")
                    
                        .toolTip("When a new device is plugged HackinDROM will try to mount the EFI partition")
                    
                }
                .onHover { inside in
                    
                    if inside {
                        
                        StatusText = "When a new device is plugged HackinDROM will try to mount the EFI partition"
                    } else {
                        if #available(macOS 11.0, *) {
                            StatusText = ""
                        }
                    }
                }
                Spacer()
                
            }
            
            HStack {
                
                Toggle(isOn: $HideWindow) {
                    Text("Click outside to hide")
                        .toolTip("Click outside of HackinDROM app's window to hide the app")
                    
                }
                .onHover { inside in
                    
                    if inside {
                        
                        StatusText = "Click outside of HackinDROM app's window to hide the app"
                    } else {
                        if #available(macOS 11.0, *) {
                            StatusText = ""
                        }
                    }
                }
                //
                
                if !BackUpsToFolder {
                    Spacer()
                    Toggle(isOn: $BackUpsToFolder.toggled(0, "", ChooseBackUpFolder)) {
                        Text("Custom folder for EFI Backups")
                            .toolTip("Custom folder for EFI Backups during Update process. Will use your specified folder instead of EFI partition.")
                        
                    }
                    .onHover { inside in
                        
                        if inside {
                            
                            StatusText = "Custom folder for EFI Backups during Update process. Will use your specified folder instead of EFI partition."
                        } else {
                            if #available(macOS 11.0, *) {
                                StatusText = ""
                            }
                        }
                    }
                } else {
                    Spacer()
                    Divider()
                        .frame(height: 15)
                    
                    Text("Backups folder:")
                        .onHover { inside in
                            
                            if inside {
                                
                                StatusText = "Open in Finder"
                            } else {
                                if #available(macOS 11.0, *) {
                                    StatusText = ""
                                }
                            }
                        }
                        .onTapGesture {
                            NSWorkspace.shared.open(URL(fileURLWithPath: BackUpsCustomFolder, isDirectory: true))
                        }
                    Text(BackUpsCustomFolder)
                        .frame(width: 200, alignment: .leading)
                        .lineLimit(1)
                        .onTapGesture {
                            BackUpsToFolder.toggle()
                            BackUpsCustomFolder = ""
                        }
                        .onHover { inside in
                            
                            if inside {
                                
                                StatusText = BackUpsCustomFolder + " ❌"
                            } else {
                                if #available(macOS 11.0, *) {
                                    StatusText = ""
                                }
                            }
                        }
                }
            }
            Divider().frame(width: 200)
            
            VStack {
                
                HStack {
                    Picker(selection: $vendor, label: Text("Vendor").fontWeight(.semibold)) { //
                        ForEach(sharedData.vendors, id:\.self) { vendor in
                            
                            Text(vendor).tag(vendor)
                            
                        }
                    }.frame(width: 200)
                    Picker(selection: $MyBuildID.pickerSelected(SetNewMlb), label: Text("Motherboard").fontWeight(.semibold)) {
                        ForEach(sharedData.AllBuilds.filter {$0.active && $0.vendor == vendor}) { build in
                            
                            Text(build.name).tag(build.id)
                            
                        }
                    }
                    
                }
                
                HStack {
                    Picker(selection: $GPU.pickerChanged(SetNewGPU), label: Text("GPU").fontWeight(.semibold)) {
                        Text("AMD GPU").tag(0)
                        Text("Intel iGPU").tag(1)
                    }
                    
                    Picker(selection: $Wifi.pickerChanged(SetNewWiFi), label: Text("WiFi").fontWeight(.semibold)) {
                        Text("Broadcom (Fenvi, YOUBO, Syba..)").tag(0)
                        Text("Intel Wifi").tag(1)
                    }
                    
                    if NewSelection && !FirstOpen {
                        Button("OK") {
                            
                            sharedData.GetAllBuildsAndConfigure()
                            NewSelection.toggle()
                            
                        }.disabled(!isAvailable)
                    }
                    
                }
                if FirstOpen {
                    Spacer()
                    Text(sharedData.isOnline ? "Welcome! Please select your Motherboard, GPU and WiFi." : "Can't connect to https://hackindrom.zapto.org. Online mode is required to unlock all features.")
                        .foregroundColor(sharedData.isOnline ? .green : .red)
                    HStack {
                        Button(sharedData.isOnline ? "Confirm" : "OK") {
                            if sharedData.isOnline {
                                
                                sharedData.GetAllBuildsAndConfigure()
                                NewSelection.toggle()
                                
                                FirstOpen = false
                                sharedData.currentview = 0
                            } else {return}
                        }.disabled(!isAvailable)
                        
                        Button("Skip") {
                            FirstOpen = false
                            sharedData.currentview = 0
                        }
                    }
                }
                
                Divider()
                HStack {
                    
                    VStack {
                        
                        Text(MyHackData.SystemProductName)
                            .toolTip("System Product Name")
                            .onHover { inside in
                                if #available(macOS 11.0, *) {
                                    if inside {
                                        
                                        StatusText = "System Product Name"
                                    } else {
                                        
                                        StatusText = ""
                                    }
                                }
                            }
                            .onTapGesture {
                                
                                CopyToClipboard(MyHackData.SystemProductName, "System Product Name")
                            }
                        Text(sharedData.OSInfo)
                            .onTapGesture {
                                
                                CopyToClipboard(sharedData.OSInfo, "macOS Version")
                            }
                        if MyHackData.OCV == "0.0.0" {
                            Text("Non OpenCore Bootloader")
                                .foregroundColor(.red)
                            
                        } else {
                            
                            Text("OpenCore " + MyHackData.OCV)
                                .onTapGesture {
                                    CopyToClipboard("OpenCore " + MyHackData.OCV, "OpenCore Version")
                                }
                        }
                        
                        ForEach(sharedData.MySystemsGPUs, id: \.self) { gpu in
                            Text(gpu.name)
                        }
                        
                        
                        
                    }
                    
                    VStack {
                        
                        Text(MyHackData.SystemSerialNumber)
                        
                            .blur(radius: HideMySerials ? 4 : 0)
                            .onHover { inside in
                                if #available(macOS 11.0, *) {
                                    if inside {
                                        
                                        StatusText = "System Serial Number"
                                    } else {
                                        
                                        StatusText = ""
                                    }
                                }
                            }
                            .onTapGesture {
                                
                                CopyToClipboard(MyHackData.SystemSerialNumber, "System Serial Number")
                            }
                        
                        Text(MyHackData.ROM)
                            .blur(radius: HideMySerials ? 4 : 0)
                            .onHover { inside in
                                if #available(macOS 11.0, *) {
                                    if inside {
                                        
                                        StatusText = "ROM"
                                    } else {
                                        
                                        StatusText = ""
                                    }
                                }
                            }
                        
                            .onTapGesture {
                                
                                CopyToClipboard(MyHackData.ROM, "ROM")
                            }
                        Text(MyHackData.MLB)
                            .blur(radius: HideMySerials ? 4 : 0)
                            .onHover { inside in
                                if #available(macOS 11.0, *) {
                                    if inside {
                                        
                                        StatusText = "Motherboard Serial Number"
                                    } else {
                                        
                                        StatusText = ""
                                    }
                                }
                            }
                        
                            .onTapGesture {
                                
                                CopyToClipboard(MyHackData.MLB, "Motherboard Serial Number")
                            }
                        Text(MyHackData.SystemUUID)
                            .blur(radius: HideMySerials ? 4 : 0)
                            .onHover { inside in
                                if #available(macOS 11.0, *) {
                                    if inside {
                                        
                                        StatusText = "System UUID"
                                    } else {
                                        
                                        StatusText = ""
                                    }
                                }
                            }
                        
                            .onTapGesture {
                                
                                CopyToClipboard(MyHackData.SystemUUID, "System UUID")
                            }
                        
                        
                        
                        
                    }
                    
                }
                
                if !MyHackData.oemVendor.isEmpty || !MyHackData.oemProduct.isEmpty {
                    Divider().frame(width: 200)
                    HStack {
                        Spacer()
                        Text(MyHackData.oemVendor)
                        Spacer()
                        Text(MyHackData.oemProduct)
                        Spacer()
                    }
                    
                    
                }
                if !(MyHackData.BootArgs).isEmpty {
                    Divider().frame(width: 100)
                    Text(MyHackData.BootArgs)
                        .onHover { inside in
                            if #available(macOS 11.0, *) {
                                if inside {
                                    
                                    StatusText = "Boot Arguments"
                                } else {
                                    
                                    StatusText = ""
                                }
                            }
                        }
                        .onTapGesture {
                            
                            CopyToClipboard(MyHackData.BootArgs, "Boot Arguments")
                        }
                    
                }
                
                if !sharedData.RunningKexts.isEmpty {
                    Divider()
                    HStack {
                        ScrollView {
                            HStack {
                                Text("Running Kexts")
                                    .font(.system(size: 18))
                                Spacer()
                            }
                            .padding(.leading, 0)
                            
                            HStack {
                                
                                VStack(alignment: .leading) {
                                    ForEach(sharedData.RunningKexts, id: \.self) { kext in
                                        
                                        Text(kext.name)
                                        
                                    }
                                    Spacer()
                                }.padding(.leading, 0)
                                
                                VStack(alignment: .leading) {
                                    
                                    ForEach(sharedData.RunningKexts, id: \.self) { kext in
                                        
                                        Text(kext.version)
                                        
                                    }
                                    
                                    Spacer()
                                }.padding(.leading, 0)
                                Spacer()
                            }.padding(.leading, 0)
                            
                        }
                        
                        BTMonitoringView()
                    }.padding(.leading, 0)
                }
                
            }
            .onHover { inside in
                if #available(macOS 11.0, *) {
                    
                } else {
                    
                    if inside {
                        
                        StatusText = ""
                    }
                }
            }
            
            .onAppear {
                
                
                isAvailable = avaibilityCheck()
                
                
                UNUserNotificationCenter.current().getNotificationSettings() { settings in
                    NotificationsAllowed = settings.authorizationStatus == .authorized ? true : false
                    NotificationDenied = settings.authorizationStatus == .denied
                }
            }
            
        }
        .padding(.trailing, 15)
        .padding(.leading, 15)
        .padding(.bottom, 15)
        .padding(.top, 0)
        
        
        
    }
    
    func avaibilityCheck() -> Bool {
        if !sharedData.AllBuilds.isEmpty {
            if let BuildIndex = self.sharedData.AllBuilds.firstIndex(where: {$0.active && $0.id == MyBuildID}) {
                
                if GPU == 0 {
                    
                    if Wifi == 0 {
                        
                        if self.sharedData.AllBuilds[BuildIndex].latest.AMDGPU.firstIndex(where: {$0.Name.contains("Broadcom")}) != nil {
                            
                            return true
                        } else {
                            
                            return false
                        }
                        
                    } else {
                        
                        if self.sharedData.AllBuilds[BuildIndex].latest.AMDGPU.firstIndex(where: {$0.Name.contains("Intel")}) != nil {
                            
                            return true
                        } else {
                            
                            return false
                        }
                        
                    }
                    
                } else {
                    if Wifi == 0 {
                        
                        if  self.sharedData.AllBuilds[BuildIndex].latest.IntelGPU.firstIndex(where: {$0.Name.contains("Broadcom")}) != nil {
                            
                            return true
                            
                        } else {
                            return false
                        }
                        
                    } else {
                        
                        if  self.sharedData.AllBuilds[BuildIndex].latest.IntelGPU.firstIndex(where: {$0.Name.contains("Intel")}) != nil {
                            
                            return true
                            
                        } else {
                            return false
                        }
                        
                    }
                }
                
            } else {
                return false
            }
        } else {
            
            return false
        }
    }
    
    
    func SetNewMlb(to value: String) {
        
        NewSelection = true
        isAvailable = avaibilityCheck()
        
    }
    
    func AskForNotifAuth() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                NotificationsAllowed = true
                Notifications = true
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
        
        
    }
    
    func ChooseBackUpFolder(to value: ToggleChanged) {
        if value.yes {
            
            let SelectAFolder = FileSelector(allowedFileTypes: ["zip"], canCreateDirectories: true, canChooseFiles: false, canChooseDirectories: true)
            if SelectAFolder != "nul" {
                BackUpsCustomFolder = SelectAFolder
            } else {
                BackUpsToFolder = false
            }
            
        }
    }
    func SetNewGPU(to value: Int) {
        
        NewSelection = true
        isAvailable = avaibilityCheck()
    }
    func SetNewWiFi(to value: Int) {
        
        NewSelection = true
        isAvailable = avaibilityCheck()
    }
    
    
    func CopyToClipboard(_ string: String, _ status: String) {
        
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(string, forType: .string)
        
        StatusText = status + " Copied!"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            StatusText = ""
        }
        
    }
}
@available(OSX 11.0, *)
struct DarkBlueShadowProgressViewStyle: ProgressViewStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        
        ProgressView(configuration)
            .shadow(color: Color(red: 0, green: 0, blue: 0.6),
                    radius: 4.0, x: 1.0, y: 2.0)
        
    }
    
}

struct ChartsEmojis: Hashable {
    
    var valeur: Int
    var Emoji: String
    
}



struct BTMonitoringView: View {
    @State var connectedBTDevices: [BTDevices] = []
    @State var lesvaleurs: [ChartsEmojis] = []
    @State var selectedBTDiv:Int = 99
    @State var BTAverage: Double = 0
    @State var ProgressViewColor: Color = Color(.red)
    @State var ProgressViewEmoji: String = "🤭"
    @State var isMonitoring: Bool = false
    var body: some View {
        VStack(alignment: .leading) {
            if !connectedBTDevices.isEmpty {
                Divider()
                
                HStack {
                    Image("bt")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                    Text("Average Signal (RSSI):  -\(Int(BTAverage))dBm")
                }
                HStack {
                    if #available(OSX 11.0, *) {
                        ProgressView(value: BTAverage, total: 100.0)
                            .accentColor(Color(.blue))
                            .foregroundColor(.purple)
                            .progressViewStyle(DarkBlueShadowProgressViewStyle())
                    }
                    Text(ProgressViewEmoji)
                    //  .scaleEffect(x: 1, y: 4, anchor: .center)
                    
                }
                HStack {
                    Picker(selection: $selectedBTDiv, label: Text("")) {
                        
                        ForEach(connectedBTDevices.indices, id:\.self) { ind in
                            Text("\(connectedBTDevices[ind].RSSI)dBm \(connectedBTDevices[ind].name)").tag(ind)
                        }
                        
                    }
                    
                    Button(action: {
                        isMonitoring.toggle()
                        
                        if isMonitoring {
                            lesvaleurs = []
                            Timer.scheduledTimer(withTimeInterval: 0.7, repeats: true) { timer in
                                DispatchQueue.main.async {
                                    
                                    BTScan()
                                }
                                if !isMonitoring {
                                    timer.invalidate()
                                }
                            }
                            
                        }
                    }, label: {
                        
                        if isMonitoring { /// peut mieux faire
                            if #available(macOS 11.0, *) {
                                Image(systemName: "pause.rectangle")
                            } else {
                                Image("pause.rectangle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 18, height: 18)
                            }
                            
                        } else {
                            if #available(macOS 11.0, *) {
                                Image(systemName: "play.rectangle")
                            } else {
                                Image("play.rectangle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 18, height: 18)
                            }
                            
                        }
                        
                    }).disabled(selectedBTDiv == 99)
                }
                
                ChartsView(lesvaleurs: $lesvaleurs)
                
            }
        }.onAppear {
            
            DispatchQueue.main.async {
                
                connectedBTDevices = pairedDevices()
                var AVGVal = 0
                for bt in connectedBTDevices {
                    
                    AVGVal += abs(Int(bt.RSSI)!)
                    
                }
                if !connectedBTDevices.isEmpty {
                    BTAverage = Double(AVGVal / connectedBTDevices.count)
                    
                    ProgressViewEmoji =  GetEmojifromVal(Int(abs(BTAverage)))
                } else {
                    BTAverage = 0.00
                    ProgressViewEmoji =  GetEmojifromVal(Int(abs(BTAverage)))
                    
                }
            }
        }
        
        .onDisappear {
            isMonitoring = false
            
        }
    }
    
    
    func BTScan() {
        if isMonitoring {
            connectedBTDevices = pairedDevices()
            let valeur = abs(Int(connectedBTDevices[selectedBTDiv].RSSI)!)
            let Emoji = GetEmojifromVal(valeur)
            lesvaleurs.append(ChartsEmojis(valeur: valeur, Emoji: Emoji))
            connectedBTDevices[selectedBTDiv].RSSI = String("-" + String(abs(Int(connectedBTDevices[selectedBTDiv].RSSI)!)))
            
            var AVGVal = 0
            for bt in connectedBTDevices {
                
                AVGVal += abs(Int(bt.RSSI)!)
                
            }
            
            if !connectedBTDevices.isEmpty {
                BTAverage = Double(AVGVal / connectedBTDevices.count)
                ProgressViewEmoji =  GetEmojifromVal(Int(abs(BTAverage)))
            } else {
                BTAverage = 0.00
                ProgressViewEmoji =  GetEmojifromVal(Int(abs(BTAverage)))
                
            }
            
            
        }
        
    }
}




