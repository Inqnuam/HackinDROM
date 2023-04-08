//
//  kextLists.swift
//  HackinDROM
//
//  Created by lian on 24/02/2022.
//  Copyright © 2022 Inqnuam. All rights reserved.
//



// list of kexts on GitHub with stable downloading archive names where only version change at every release
// # in downloadName = github tag (ex: v2.1.4, or 0.4.3, etc.)
// This is acidenthara style
// OpenIntelWireless uses this style for IntelBluetoothFirmware but not for AirportItlwm
let gitHubKexts: [GitHubInfo] = [
    
    GitHubInfo(owner: "acidanthera", repo: "Lilu", name: "Lilu", downloadName: "Lilu-#-RELEASE.zip"),
    GitHubInfo(owner: "acidanthera", repo: "WhateverGreen", name: "WhateverGreen", downloadName: "WhateverGreen-#-RELEASE.zip"),
    
    GitHubInfo(owner: "acidanthera", repo: "FeatureUnlock", name: "FeatureUnlock", downloadName: "FeatureUnlock-#-RELEASE.zip"),
    GitHubInfo(owner: "acidanthera", repo: "CpuTscSync", name: "CpuTscSync", downloadName: "CpuTscSync-#-RELEASE.zip"),
    GitHubInfo(owner: "acidanthera", repo: "AirportBrcmFixup", name: "AirportBrcmFixup", downloadName: "AirportBrcmFixup-#-RELEASE.zip"),
    GitHubInfo(owner: "acidanthera", repo: "RestrictEvents", name: "RestrictEvents", downloadName: "RestrictEvents-#-RELEASE.zip"),
    GitHubInfo(owner: "acidanthera", repo: "CPUFriend", name: "CPUFriend", downloadName: "CPUFriend-#-RELEASE.zip"),
    GitHubInfo(owner: "acidanthera", repo: "MacHyperVSupport", name: "MacHyperVSupport", downloadName: "MacHyperVSupport-#-RELEASE.zip"),
    GitHubInfo(owner: "acidanthera", repo: "HibernationFixup", name: "HibernationFixup", downloadName: "HibernationFixup-#-RELEASE.zip"),
    GitHubInfo(owner: "acidanthera", repo: "BrightnessKeys", name: "BrightnessKeys", downloadName: "BrightnessKeys-#-RELEASE.zip"),
    GitHubInfo(owner: "acidanthera", repo: "NVMeFix", name: "NVMeFix", downloadName: "NVMeFix-#-RELEASE.zip"),
    GitHubInfo(owner: "acidanthera", repo: "UEFIGraphicsFB", name: "UEFIGraphicsFB", downloadName: "UEFIGraphicsFB-#-RELEASE.zip"),
    GitHubInfo(owner: "acidanthera", repo: "RTCMemoryFixup", name: "RTCMemoryFixup", downloadName: "RTCMemoryFixup-#-RELEASE.zip"),
    GitHubInfo(owner: "acidanthera", repo: "DebugEnhancer", name: "DebugEnhancer", downloadName: "DebugEnhancer-#-RELEASE.zip"),
    GitHubInfo(owner: "acidanthera", repo: "WhateverGreen", name: "WhateverGreen", downloadName: "WhateverGreen-#-RELEASE.zip"),
    
    GitHubInfo(owner: "acidanthera", repo: "VirtualSMC", name: "VirtualSMC", downloadName: "VirtualSMC-#-RELEASE.zip"),
    GitHubInfo(owner: "acidanthera", repo: "VirtualSMC", name: "SMCBatteryManager", downloadName: "VirtualSMC-#-RELEASE.zip"),
    GitHubInfo(owner: "acidanthera", repo: "VirtualSMC", name: "SMCDellSensors", downloadName: "VirtualSMC-#-RELEASE.zip"),
    GitHubInfo(owner: "acidanthera", repo: "VirtualSMC", name: "SMCLightSensor", downloadName: "VirtualSMC-#-RELEASE.zip"),
    GitHubInfo(owner: "acidanthera", repo: "VirtualSMC", name: "SMCProcessor", downloadName: "VirtualSMC-#-RELEASE.zip"),
    GitHubInfo(owner: "acidanthera", repo: "VirtualSMC", name: "SMCSuperIO", downloadName: "VirtualSMC-#-RELEASE.zip"),
    
    GitHubInfo(owner: "acidanthera", repo: "BrcmPatchRAM", name: "BlueToolFixup", downloadName: "BrcmPatchRAM-#-RELEASE.zip"),
    GitHubInfo(owner: "acidanthera", repo: "BrcmPatchRAM", name: "BrcmBluetoothInjector", downloadName: "BrcmPatchRAM-#-RELEASE.zip"),
    GitHubInfo(owner: "acidanthera", repo: "BrcmPatchRAM", name: "BrcmBluetoothInjectorLegacy", downloadName: "BrcmPatchRAM-#-RELEASE.zip"),
    GitHubInfo(owner: "acidanthera", repo: "BrcmPatchRAM", name: "BrcmFirmwareData", downloadName: "BrcmPatchRAM-#-RELEASE.zip"),
    GitHubInfo(owner: "acidanthera", repo: "BrcmPatchRAM", name: "BrcmFirmwareRepo", downloadName: "BrcmPatchRAM-#-RELEASE.zip"),
    GitHubInfo(owner: "acidanthera", repo: "BrcmPatchRAM", name: "BrcmNonPatchRAM", downloadName: "BrcmPatchRAM-#-RELEASE.zip"),
    GitHubInfo(owner: "acidanthera", repo: "BrcmPatchRAM", name: "BrcmNonPatchRAM2", downloadName: "BrcmPatchRAM-#-RELEASE.zip"),
    GitHubInfo(owner: "acidanthera", repo: "BrcmPatchRAM", name: "BrcmPatchRAM", downloadName: "BrcmPatchRAM-#-RELEASE.zip"),
    GitHubInfo(owner: "acidanthera", repo: "BrcmPatchRAM", name: "BrcmPatchRAM2", downloadName: "BrcmPatchRAM-#-RELEASE.zip"),
    GitHubInfo(owner: "acidanthera", repo: "BrcmPatchRAM", name: "BrcmPatchRAM3", downloadName: "BrcmPatchRAM-#-RELEASE.zip"),
    
    GitHubInfo(owner: "acidanthera", repo: "IntelMausi", name: "IntelMausi", downloadName: "IntelMausi-#-RELEASE.zip"),
    GitHubInfo(owner: "acidanthera", repo: "IntelMausi", name: "IntelSnowMausi", downloadName: "IntelMausi-#-RELEASE.zip"),
    
    GitHubInfo(owner: "acidanthera", repo: "AppleALC", name: "AppleALC", downloadName: "AppleALC-#-RELEASE.zip"),
    GitHubInfo(owner: "acidanthera", repo: "AppleALC", name: "AppleALCU", downloadName: "AppleALC-#-RELEASE.zip"),
    
    GitHubInfo(owner: "acidanthera", repo: "VoodooPS2", name: "VoodooPS2Controller", downloadName: "VoodooPS2Controller-#-RELEASE.zip"),
    GitHubInfo(owner: "acidanthera", repo: "VoodooInput", name: "VoodooInput", downloadName: "VoodooInput-#-RELEASE.zip"),
    
    GitHubInfo(owner: "OpenIntelWireless", repo: "IntelBluetoothFirmware", name: "IntelBluetoothFirmware", downloadName: "IntelBluetoothFirmware-#.zip"),
    GitHubInfo(owner: "OpenIntelWireless", repo: "IntelBluetoothFirmware", name: "IntelBluetoothInjector", downloadName: "IntelBluetoothFirmware-#.zip"),
    
    GitHubInfo(owner: "aluveitie", repo: "RadeonSensor", name: "RadeonSensor", downloadName: "RadeonSensor-#.zip"),
    GitHubInfo(owner: "aluveitie", repo: "RadeonSensor", name: "SMCRadeonGPU", downloadName: "RadeonSensor-#.zip"),
    
    GitHubInfo(owner: "trulyspinach", repo: "SMCAMDProcessor", name: "SMCAMDProcessor", downloadName: "SMCAMDProcessor.kext.zip"),
    GitHubInfo(owner: "trulyspinach", repo: "SMCAMDProcessor", name: "AMDRyzenCPUPowerManagement", downloadName: "AMDRyzenCPUPowerManagement.kext.zip")
]



struct AirportItlwmCustomName {
    var localName: String // kext file name in cache
    var customNames: [String] // values user may use
    var remoteNames: [String] // will check if remote file name contains one of these strings -> determine macOS x target kext
}

let airportItlwmCustomNames: [AirportItlwmCustomName] = [
    AirportItlwmCustomName(localName: "AirportItlwmMonterey",
                           customNames: [
                            "AirportItlwmMonterey",
                            "AirportItlwm_Monterey",
                            "AirportItlwm-Monterey"
                           ],
                           remoteNames: ["Monterey"]),
    AirportItlwmCustomName(localName: "AirportItlwmCatalina",
                           customNames: [
                            "AirportItlwmCatalina",
                            "AirportItlwm_Catalina",
                            "AirportItlwm-Catalina"
                           ], remoteNames: ["Catalina"]),
    AirportItlwmCustomName(localName: "AirportItlwmMojave",
                           customNames: [
                            "AirportItlwmMojave",
                            "AirportItlwm_Mojave",
                            "AirportItlwm-Mojave"
                           ], remoteNames: ["Mojave"]),
    AirportItlwmCustomName(localName: "AirportItlwmBigSur",
                           customNames: [
                            "AirportItlwmBigSur",
                            "AirportItlwmBig_Sur",
                            "AirportItlwmBig-Sur",
                            "AirportItlwm_BigSur",
                            "AirportItlwm_Big_Sur",
                            "AirportItlwm_Big-Sur",
                            "AirportItlwm-BigSur",
                            "AirportItlwm-Big-Sur",
                            "AirportItlwm-Big_Sur",
                            
                           ],
                           remoteNames: ["BigSur", "Big_Sur", "Big-Sur"]),
    AirportItlwmCustomName(localName: "AirportItlwmHighSierra",
                           customNames: [
                            "AirportItlwmHighSierra",
                            "AirportItlwmHigh_Sierra",
                            "AirportItlwmHigh-Sierra",
                            "AirportItlwm_HighSierra",
                            "AirportItlwm_High_Sierra",
                            "AirportItlwm_High-Sierra",
                            "AirportItlwm-HighSierra",
                            "AirportItlwm-High-Sierra",
                            "AirportItlwm-High_Sierra",
                            
                           ],
                           remoteNames: ["HighSierra", "High_Sierra", "High-Sierra"]),
    
]





func getKextGitHubRepoInfo(_ kextName: String)-> GitHubInfo? {
    let comapringName = kextName.lowercased()
    if let foundKextName = gitHubKexts.first(where: { $0.name.lowercased() == comapringName}) {
        return foundKextName
    }
    
    return nil
}
