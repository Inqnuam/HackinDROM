//
//  DeviceDetector.swift
//  HackinDROM EFI
//
//  Created by Inqnuam 03/02/2021.
//  Copyright © 2021 HackinDROM. All rights reserved.
//

import Foundation
import Scout
import Zip
import Version
import SwiftUI
let fileManager = FileManager()
let tmp = fileManager.temporaryDirectory.relativePath + "/HackinDROM"
let procesinfo = ProcessInfo()

class HASharedData: ObservableObject {
    @AppStorageCompat("CurrentUser") var CurrentUser = ""
    @AppStorageCompat("UserID") var UserID = ""
    @AppStorageCompat("MyBuildID") var MyBuildID = ""
    @AppStorageCompat("GPU") var GPU = 0
    @AppStorageCompat("Wifi") var Wifi = 0
    @AppStorageCompat("Updated") var Updated = false
    @AppStorageCompat("v") var UpdatedVersion = ""
    @AppStorageCompat("isOnline") var isOnline: Bool = false
    @AppStorageCompat("FirstOpen") var FirstOpen = true
    @AppStorageCompat("LastDelNotDate") var LastDelNotDate = ""
    @Published var PlistExpl = PathExplorers.Plist(stringLiteral: "")
    @Published var ocTemplatesHD: [String: HAPlistStruct] = [:]
    @Published var CPlist = HAPlistStruct()
    @Published var sectionIndex: Int = 0
    @Published var isSaved:Bool = true
    @Published var PlistData = Data()
    @Published var ocTemplateName = ""
    @Published var currentview: Int = 0
    @Published var CurrentEFI: Int = 0
    @Published var CurrentBuildVersion = "\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String).\(Bundle.main.infoDictionary?["CFBundleVersion"] as! String)"
    @Published var newAppVersion: String = ""
    @Published var BTconnectedDevices: Int = 0
    @Published var Updating: String = ""
    @Published var CurrentKexts: [KextStructs] = []
    @Published var CaseyLatestPlist: String = ""
    @Published var CaseyKextsList: [KextStructs] = []
    @Published var CaseyDriversList: [Drivers] = []
    @Published var OCv: String = "0.0.0"
    @Published var CaseyLastestOCArchive: String = ""
    @Published var OpenCoreDownloadLink: String = ""
    @Published var isCharging: Bool = false
    @Published var JustOpened: Bool = true
    @Published var isShowingNavigationView:Bool = false
    @Published var isShowingSheet:Bool = false
    @Published var selectedSection: Int? = 0
    @Published var selectedChild: Int = 0
    @Published var EditorMode:Bool = false
    @Published var editorIsAlerting:Bool = false
    @Published var savingFilePath: String = ""
    @Published var availableocts: [String] = []
    @Published var MountThisPartition: [String] = ["nul", ""] //#FIXME better implmentation is needed
    @Published var AllBuilds: [AllBuilds] = []
    @Published var vendors: [String] = []
    @Published var ConnectedUser: String = ""
    @Published var MySystemsGPUs: [GPUInfos] = []
    @Published var OSInfo: String = "macOS \(procesinfo.operatingSystemVersion.majorVersion).\(procesinfo.operatingSystemVersion.minorVersion).\(procesinfo.operatingSystemVersion.patchVersion) - \(procesinfo.operatingSystemVersionString.slice(from: "Build ", to: ")") ?? "")"
    @Published var whoami: String = NSUserName()
    @Published var Mypwd: String = ""
    @Published var dortConfig: [DortaniaJSON] = []
    @Published var RunningKexts: [RunningKextsStruct] = runningkexts()
    @Published var initialEFIs: [EFI] = []
    let nvram = NVRAM()
    
   
    init() {
        
        
        do {
            try fileManager.createDirectory(atPath: tmp, withIntermediateDirectories: true, attributes: nil)
            dortConfig = getDortConf()
        } catch {
           
            print(error)
        }
        
     
        imOnline() { my in
            
            if my.online {
                self.getOCLastSamples()
                
                if Version(self.CurrentBuildVersion)! < Version(my.version)! {
                    
                   // HDUpdateLuncher(my.version)
                    self.newAppVersion = my.version
                    
                } else {
                    self.GetAllBuildsAndConfigure()
                    //                    OpenCoreGitHubReleases()
                    self.OpenCoreDownloadLink = GetGitHubDownloadLink("OpenCorePkg")
                    self.isOnline = true
                    
                    if my.userid == "nul" {
                        self.ConnectedUser = ""
                        self.CurrentUser = ""
                        self.UserID = ""
                    }
                    else {
                        self.ConnectedUser = my.username
                        self.CurrentUser = my.username
                        self.UserID = my.userid
                    }
                    
                    
                }
                
            } else {
                self.isOnline = false
                self.FirstOpen = false
                
            }
        }
        
        
        
        do {
            MySystemsGPUs = try getGPUUsage()
            
        } catch {
            print("GPU0x05", error) // CHECK THIS ON REAL MAC TO FIND AN ALTERNATIVE TO DETECT GPU
        }
        
    }
    
    deinit {
        nc.removeObserver(self)
    }
    
    
    func GetAllBuildsAndConfigure() {
       
            if fileManager.fileExists(atPath: tmp, isDirectory: nil) {
                GetAllBuilds() { [self] Builds in
                    
                    self.AllBuilds = Builds
                    
                    
                    
                    for IndeX in self.AllBuilds.indices {
                        
                        self.AllBuilds[IndeX].configs.sort {
                            $0.ocvs > $1.ocvs
                        }
                        
                        
                        if !self.vendors.contains(self.AllBuilds[IndeX].vendor) {
                            
                            if  self.AllBuilds[IndeX].active {
                                
                                self.vendors.append(self.AllBuilds[IndeX].vendor)
                            } else {
                                
                                if self.AllBuilds[IndeX].leader.localizedCaseInsensitiveContains(self.ConnectedUser) {
                                    self.vendors.append(self.AllBuilds[IndeX].vendor)
                                }
                            }
                            
                            
                        }
                        
                        self.vendors.sort {
                            $0 < $1
                        }
                        
                    }
                    
                    if let index = self.AllBuilds.firstIndex(where: {$0.active && $0.id == self.MyBuildID}) {
                       
                        self.CaseyLastestOCArchive = self.AllBuilds[index].latest.Archive
                        let downloadlink =  self.AllBuilds[index].latest.Archive
                        var configname = ""
                        
                      
                        if self.GPU == 0 {
                           
                            if self.Wifi == 0 {
                              
                                if let index2 = self.AllBuilds[index].latest.AMDGPU.firstIndex(where: {$0.Name.contains("Broadcom")}) {
                                   
                                    configname =  self.AllBuilds[index].latest.AMDGPU[index2].link
                                }
                                
                            } else {
                              
                                if let index2 = self.AllBuilds[index].latest.AMDGPU.firstIndex(where: {$0.Name.contains("Intel")}) {
                                    
                                    configname =  self.AllBuilds[index].latest.AMDGPU[index2].link
                                }
                                
                            }
                            
                        }
                        else {
                           
                            if self.Wifi == 0 {
                               
                                if let index2 = self.AllBuilds[index].latest.IntelGPU.firstIndex(where: {$0.Name.contains("Broadcom")}) {
                                   
                                    configname =  self.AllBuilds[index].latest.IntelGPU[index2].link
                                }
                                
                            }
                            else {
                               
                                if let index2 = self.AllBuilds[index].latest.IntelGPU.firstIndex(where: {$0.Name.contains("Intel")}) {
                                   
                                    configname =  self.AllBuilds[index].latest.IntelGPU[index2].link
                                }
                                
                            }
                        }
                        
                      
                        if configname != "" && downloadlink != "nul" {
                            
                            self.OCv = self.AllBuilds[index].latest.ocvs
                            
                            
                            
                            let pathu = "\(tmp)/HDdefault.plist"
                            shell("rm -rf '\(pathu)'") { result, error in
                                
                                shell("curl --silent 'https://hackindrom.zapto.org/app/public/uploads/\(downloadlink)'  -L -o '\(tmp)/\(downloadlink)'") { result, error in
                                    
                                    shell("rm -rf '\(tmp)/extracting'") { result, error in
                                        
                                        shell("unzip '\(tmp)/\(downloadlink)' -d '\(tmp)/extracting'") { result, error in
                                            
                                            var CaseysFolder = ""
                                            CaseysFolder = try! fileManager.contentsOfDirectory(at: URL(fileURLWithPath: "\(tmp)/extracting"), includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]).first!.lastPathComponent
                                            
                                            shell("mv '\(tmp)/extracting/\(CaseysFolder)/OC/\(configname)' '\(pathu)'") { _, error in
                                                
                                                self.CaseyLatestPlist = pathu
                                                
                                                CaseyDriversList = GetDrivers(CaseyLatestPlist)
                                                
                                                do {
                                                    // MyEFI folder's Kexts
                                                    let FindKexts = try fileManager.contentsOfDirectory(at: URL(fileURLWithPath: "\(tmp)/extracting/\(CaseysFolder)/OC/Kexts/"), includingPropertiesForKeys: nil)
                                                    
                                                    let kexts =  FindKexts.filter { $0.pathExtension == "kext" }
                                                    let FileNames = kexts.map { $0.deletingPathExtension().lastPathComponent }
                                                    
                                                    if FileNames.count > 0 {
                                                        
                                                        for KextName in FileNames {
                                                            
                                                            CaseyKextsList.append(KextStructs(name: KextName, LocalV: "nul", GitHubV: "nul", DownloadLink: "nul"))
                                                            
                                                        }
                                                    }
                                                } catch {
                                                    
                                                }
                                                
                                                shell("rm -rf '\(tmp)/extracting'") { result, error in
                                                    
                                                    shell("rm -rf '\(tmp)/\(downloadlink)'") { _, _ in
                                                        
                                                        if Version(self.OCv)! > Version(MyHackData.OCV)! && MyHackData.OCV != "0.0.0" {
                                                            
                                                            
                                                            
                                                            SetNotif("Update Available", "OpenCore \(self.OCv) is available!")
                                                            
                                                        }
                                                    }
                                                }
                                                
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                            }
                        } else {
                            print("*0x45")
                            self.OCv = "0.0.0"
                            
                        }
                    } else {print("*0xFF")}
                    
                    self.AllBuilds.sort {
                        $0.name < $1.name
                    }
                }
            }
            
        
    }
    
    
    
    func getOCLastSamples() {
      
      
            
            var gitocvs = [""]
            shell("curl --silent https://github.com/acidanthera/OpenCorePkg/releases.atom | grep '/releases/tag/' ") { ocs, _ in
                gitocvs =  ocs.components(separatedBy: .newlines)
              
                
                for (o, link) in gitocvs.enumerated() {
                    
                    gitocvs[o] = link.slice(from: "/releases/tag/", to: "\"/>") ?? ""
                   
                }
                gitocvs.sort { (a, b) -> Bool in
                    a.compare(b, options: String.CompareOptions.numeric, range: nil, locale: nil) == .orderedDescending
                }
            }
            if !fileManager.fileExists(atPath: tmp + "/oct") {
                
                do {
                    try fileManager.createDirectory(atPath: tmp + "/oct/downloads", withIntermediateDirectories: true, attributes: nil)
                    try fileManager.createDirectory(atPath: tmp + "/oct/s", withIntermediateDirectories: true, attributes: nil)
                    try fileManager.createDirectory(atPath: tmp + "/oct/c", withIntermediateDirectories: true, attributes: nil)
                    
                    for v in gitocvs {
                        
                        if v != "" && v != "0.6.0" && v != "0.6.1" && v != "0.6.2" {
                            
                            shell("curl --silent https://github.com/acidanthera/OpenCorePkg/releases/download/\(v)/OpenCore-\(v)-RELEASE.zip  -L -o '\(tmp)/oct/downloads/\(v).zip'") { download, _ in
                                
                                do {
                                    try Zip.unzipFile(URL(fileURLWithPath: "\(tmp)/oct/downloads/\(v).zip"), destination: URL(fileURLWithPath: "\(tmp)/oct/downloads/\(v)"), overwrite: true, password: nil, progress:  { completed in
                                        
                                        if completed == 1.0 {
                                            
                                            do {
                                                try fileManager.removeItem(atPath: "\(tmp)/oct/downloads/\(v).zip")
                                                
                                                try fileManager.moveItem(atPath: "\(tmp)/oct/downloads/\(v)/Docs/Sample.plist", toPath: "\(tmp)/oct/s/\(v).plist")
                                                try fileManager.moveItem(atPath: "\(tmp)/oct/downloads/\(v)/Docs/SampleCustom.plist", toPath: "\(tmp)/oct/c/\(v).plist")
                                                try fileManager.removeItem(atPath: "\(tmp)/oct/downloads/\(v)")
                                                
                                                
                                                // self.PlistData = fileManager.contents(atPath: "\(tmp)/oct/c/\(v).plist")!
                                                getHAPlistFrom("\(tmp)/oct/c/\(v).plist") { expl in
                                                   
                                                    
                                                    self.ocTemplatesHD.updateValue(expl, forKey: v)
                                                    self.availableocts.append(v)
                                                }
                                                
                                                
                                                
                                                
                                            } catch {
                                                print(error)
                                            }
                                        }
                                        
                                    })
                                } catch {
                                    print("unzipping error:", error)
                                }
                                
                            }
                        }
                    }
                    self.availableocts.sort { (a, b) -> Bool in
                        a.compare(b, options: String.CompareOptions.numeric, range: nil, locale: nil) == .orderedDescending
                    }
                    
                    
                    
                } catch {
                    
                    print(error)
                }
            } else {
                do {
                    
                    
                    let octs = try fileManager.contentsOfDirectory(at: URL(fileURLWithPath: tmp + "/oct/s"), includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
                    if !octs.isEmpty {
                        
                        for v in octs {
                            let vers = v.lastPathComponent.replacingOccurrences(of: ".plist", with: "")
                            
                            
                            //  self.PlistData = fileManager.contents(atPath: "\(tmp)/oct/c/\(vers).plist")!
                            getHAPlistFrom("\(tmp)/oct/c/\(vers).plist") { expl in
                                
                                
                                self.ocTemplatesHD.updateValue(expl, forKey: vers)
                                self.availableocts.append(vers)
                            }
                            
                        }
                        
                        
                        self.availableocts.sort { (a, b) -> Bool in
                            a.compare(b, options: String.CompareOptions.numeric, range: nil, locale: nil) == .orderedDescending
                        }
                        
                        
                        
                        if let first = self.availableocts.first {
                            guard Version(first)! != Version(gitocvs.first!)  else {return}
                            
                            var vpatch = 0
                            var vminor = 0
                            var vmajor = 0
                            
                            var newVersion = "\(Version(first)!)"
                            while Version(newVersion)! != Version(gitocvs.first!)! {
                                if vpatch != 9 {
                                    vpatch += 1
                                } else {
                                    vpatch = 0
                                    if vminor != 9 {
                                        vminor += 1
                                    } else {
                                        vminor = 0
                                        vmajor += 1
                                    }
                                }
                                
                                newVersion = "\(Version(first)!.major).\(Version(first)!.minor + vminor).\(Version(first)!.patch + vpatch)"
                                
                                shell("curl --silent https://github.com/acidanthera/OpenCorePkg/releases/download/\(newVersion)/OpenCore-\(newVersion)-RELEASE.zip  -L -o '\(tmp)/oct/downloads/\(newVersion).zip'") { download, _ in
                                    
                                    do {
                                        try Zip.unzipFile(URL(fileURLWithPath: "\(tmp)/oct/downloads/\(newVersion).zip"), destination: URL(fileURLWithPath: "\(tmp)/oct/downloads/\(newVersion)"), overwrite: true, password: nil, progress:  { completed in
                                            
                                            if completed == 1.0 {
                                                
                                                do {
                                                    try fileManager.removeItem(atPath: "\(tmp)/oct/downloads/\(newVersion).zip")
                                                    
                                                    try fileManager.moveItem(atPath: "\(tmp)/oct/downloads/\(newVersion)/Docs/Sample.plist", toPath: "\(tmp)/oct/s/\(newVersion).plist")
                                                    try fileManager.moveItem(atPath: "\(tmp)/oct/downloads/\(newVersion)/Docs/SampleCustom.plist", toPath: "\(tmp)/oct/c/\(newVersion).plist")
                                                    try fileManager.removeItem(atPath: "\(tmp)/oct/downloads/\(newVersion)")
                                                    
                                                    
                                                    
                                                    // self.PlistData = fileManager.contents(atPath: "\(tmp)/oct/c/\(newVersion).plist")!
                                                    getHAPlistFrom("\(tmp)/oct/c/\(newVersion).plist") { expl in
                                                        
                                                        
                                                        self.ocTemplatesHD.updateValue(expl, forKey: newVersion)
                                                        self.availableocts.insert(newVersion, at: 0)
                                                    }
                                                    
                                                    
                                                    
                                                    
                                                } catch {
                                                    print(error)
                                                }
                                            }
                                            
                                        })
                                    } catch {
                                        print("unzipping error:", error)
                                    }
                                    
                                }
                                
                                
                            }
                            
                        }
                        
                        //   Check if .first == github latest version if not then download every each version if possible
                    }
                } catch {
                    print(error)
                }
            }
            
        
        
    }
    
    

    
}

func currentOCv() -> String {
    var Getocv = nvram.GetOFVariable("4D1FDA02-38C7-4A6A-9CC6-4BCCA8B30102:opencore-version").slice(from: "-", to: "-") ?? "0.0.0"
    if Getocv != "0.0.0" {
        Getocv.insert(".", at: Getocv.index(Getocv.startIndex, offsetBy: 1))
        Getocv.insert(".", at: Getocv.index(Getocv.startIndex, offsetBy: 3))
    }
    return Getocv
}

let nvram = NVRAM()

let MyHackData = MyHackDataStrc(MLB: nvram.GetOFVariable("4D1EDE05-38C7-4A6A-9CC6-4BCCA8B38C14:MLB"),
                                ROM: nvram.systemROM("4D1EDE05-38C7-4A6A-9CC6-4BCCA8B38C14:HW_ROM"),
                                SystemUUID: nvram.systemID("system-id"),
                                BootArgs: nvram.GetOFVariable("boot-args"),
                                SystemSerialNumber: nvram.GetOFVariable("4D1EDE05-38C7-4A6A-9CC6-4BCCA8B38C14:SSN"), // getMacSerialNumber() == "" ?? nvram.GetOFVariable("4D1EDE05-38C7-4A6A-9CC6-4BCCA8B38C14:SSN") ,
                                SystemProductName: modelIdentifier(),
                                OCV: currentOCv(),
                                SIP: nvram.GetMySIP(),
                                oemVendor: nvram.GetOFVariable("4D1FDA02-38C7-4A6A-9CC6-4BCCA8B30102:oem-vendor").trimmingCharacters(in: .whitespacesAndNewlines),
                                oemProduct: nvram.GetOFVariable("4D1FDA02-38C7-4A6A-9CC6-4BCCA8B30102:oem-product").trimmingCharacters(in: .whitespacesAndNewlines),
                                cpuCount: getLogicalCPUCount()
                                
)


func getLogicalCPUCount()-> String {
    var totalCPUCores = ""
    shell("sysctl hw.physicalcpu") { res, _ in
        let stdOut = res.replace(string: "hw.physicalcpu: ", replacement: "")
        
        if stdOut == "6" {
            totalCPUCores = "06"
        } else  if stdOut == "8" {
            totalCPUCores = "08"
        } else if stdOut == "12" {
            totalCPUCores = "0C"
        } else  if stdOut == "16" {
            totalCPUCores = "10"
        } else  if stdOut == "32" {
            totalCPUCores = "20"
        } else {
            totalCPUCores = "08"
        }
        
    }
    return totalCPUCores
}

