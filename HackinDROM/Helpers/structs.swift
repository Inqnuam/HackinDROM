//
//  structs.swift
//  HackinDROM
//
//  Created by Inqnuam 19/04/2021.
//  Copyright © 2021 HackinDROM. All rights reserved.
//

import Foundation


struct MotherboardsList: Hashable {

    var id: String = ""
    var name: String = ""

}
struct MyHackDataStrc {

    var MLB: String = ""
    var ROM: String = ""
    var SystemUUID: String = ""
    var BootArgs: String = ""
    var SystemSerialNumber: String = ""
    var SystemProductName: String = ""
    var OCV: String = ""
    var SIP: String = ""
    var oemVendor:String = ""
    var oemProduct:String = ""
    var cpuCount: String = ""
}

struct AllBuilds: Identifiable, Codable, Hashable {
    var id: String = ""
    var leader: String = ""
    var name: String = ""
    var SPN: String = ""
    var active: Bool = true
    var configs: [BuildConfigs] = []
    var latest = BuildConfigs()
    var vendor = ""

}

struct BuildConfigs: Identifiable, Codable , Hashable  {

    var id: String = ""
    var ocv: Double = 0.0
    var ocvs: String = ""
    var Archive: String = ""
    var size: Int = 0
    var amdosx: Bool = false
    var AMDGPU: [PlistData] = []
    var IntelGPU: [PlistData] = []
    var active: Bool = false
    var warning: Bool = false
    var followLink: String = ""
    var notes: String = ""

}

struct PlistData: Codable , Hashable {
  
    var _id: String = ""
    var Name: String = ""
    var link: String = ""
    var bootArgs: String = ""

}

struct PlistRequest {
    var plistid: String
    var MLB: String
    var ROM: String
    var SystemUUID: String
    var SystemProductName: String
    var SystemSerialNumber: String
    var newsmbios: String
    var bootargs: String

}


struct Kexts: Hashable, Decodable, Encodable {
    var Arch: String = ""
    var BundlePath: String = ""
    var Comment: String = ""
    var Enabled: Bool = (1 != 0)
    var ExecutablePath: String = ""
    var MaxKernel: String = ""
    var MinKernel: String = ""
    var PlistPath: String = ""

}

struct AMLs: Decodable, Encodable, Equatable {
    var Comment: String = ""
    var Enabled: Bool = (1 != 0)
    var Path: String = ""

}

struct Drivers: Hashable, Equatable, Decodable, Encodable {
    var Path: String = ""
    var Arguments: String = ""
    var Comment: String?
    var Enabled: Bool = true
}

struct KextStructs: Hashable, Decodable, Encodable {
    var id = UUID()
    var name: String
    var LocalV: String
    var GitHubV: String
    var DownloadLink: String
    var isUpdatable: Bool = false
}

struct RunningKextsStruct: Hashable {
    var name: String = ""
    var version: String = ""

}

struct BTDevices: Hashable, Decodable, Encodable {

    var name: String = ""
    var RSSI: String = ""

}

struct BootArgData: Hashable, Decodable, Encodable {

    var value: String = ""
    var description: String = ""

}



struct ExternalDisks: Hashable, Identifiable {
    var id = UUID()
    var location: String = ""
    var name: String = ""
    var size: String = ""
    var SSD: String = ""

}

struct UploadNewBuildStruct: Codable, Equatable {
    var leader: String = ""
    var name: String = ""
    var SPN: String = ""
    var config: UploadNewConfig = UploadNewConfig()
    var vendor: String = ""

}

struct UploadNewConfig: Codable, Equatable {

    var buildID: String = "nul"
    var ocv: Double = 0.00
    var ocvs: String = ""
    var Archive: String  = ""
    var size: Int = 0
    var amdosx: Bool = false
    var warning: Bool = false
    var followLink: String = ""
    var notes: String = ""
    var active: Bool = true
    var AMDGPU: [NewConfigsData] = []
    var IntelGPU: [NewConfigsData] = []

}

struct NewConfigsData: Codable, Equatable  {

    var Name: String = ""
    var link: String = ""
    var bootArgs: String = ""
   
}

struct Analyze: Decodable, Encodable {
    var config: String
    var table: [String]
}

struct Updater: Decodable, Encodable {
    var Old: String
    var AML: [AMLs]
    var Kext: [Kexts]
    var Driver: [Drivers]
    var Latest: String
}

struct DataResponse: Decodable, Encodable {
    var link: String
}

let Macs = ["MacBook1,1", "MacBook10,1", "MacBook2,1", "MacBook3,1", "MacBook4,1", "MacBook5,1", "MacBook5,2", "MacBook6,1", "MacBook7,1", "MacBook8,1", "MacBook9,1", "MacBookAir1,1", "MacBookAir2,1", "MacBookAir3,1", "MacBookAir3,2", "MacBookAir4,1", "MacBookAir4,2", "MacBookAir5,1", "MacBookAir5,2", "MacBookAir6,1", "MacBookAir6,2", "MacBookAir7,1", "MacBookAir7,2", "MacBookAir8,1", "MacBookAir8,2", "MacBookAir9,1", "MacBookPro1,1", "MacBookPro1,2", "MacBookPro10,1", "MacBookPro10,2", "MacBookPro11,1", "MacBookPro11,2", "MacBookPro11,3", "MacBookPro11,4", "MacBookPro11,5", "MacBookPro12,1", "MacBookPro13,1", "MacBookPro13,2", "MacBookPro13,3", "MacBookPro14,1", "MacBookPro14,2", "MacBookPro14,3", "MacBookPro15,1", "MacBookPro15,2", "MacBookPro15,3", "MacBookPro15,4", "MacBookPro16,1", "MacBookPro16,2", "MacBookPro16,3", "MacBookPro16,4", "MacBookPro2,1", "MacBookPro2,2", "MacBookPro3,1", "MacBookPro4,1", "MacBookPro5,1", "MacBookPro5,2", "MacBookPro5,3", "MacBookPro5,4", "MacBookPro5,5", "MacBookPro6,1", "MacBookPro6,2", "MacBookPro7,1", "MacBookPro8,1", "MacBookPro8,2", "MacBookPro8,3", "MacBookPro9,1", "MacBookPro9,2", "MacPro1,1", "MacPro2,1", "MacPro3,1", "MacPro4,1", "MacPro5,1", "MacPro6,1", "MacPro7,1", "Macmini1,1", "Macmini2,1", "Macmini3,1", "Macmini4,1", "Macmini5,1", "Macmini5,2", "Macmini5,3", "Macmini6,1", "Macmini6,2", "Macmini7,1", "Macmini8,1", "Xserve1,1", "Xserve2,1", "Xserve3,1", "iMac10,1", "iMac11,1", "iMac11,2", "iMac11,3", "iMac12,1", "iMac12,2", "iMac13,1", "iMac13,2", "iMac13,3", "iMac14,1", "iMac14,2", "iMac14,3", "iMac14,4", "iMac15,1", "iMac16,1", "iMac16,2", "iMac17,1", "iMac18,1", "iMac18,2", "iMac18,3", "iMac19,1", "iMac19,2", "iMac20,1", "iMac20,2", "iMac4,1", "iMac4,2", "iMac5,1", "iMac5,2", "iMac6,1", "iMac7,1", "iMac8,1", "iMac9,1", "iMacPro1,1" ]





    var BootArguments: [BootArgData] = [
        BootArgData(value: "agdpmod=vit9696", description: "Disables board-id check, may be needed for when screen turns black after finishing booting."),
        BootArgData(value: "agdpmod=pikera", description: "Renames board-id to board-ix effectively disabling board ID checks. This is required for AMD RX 5000 and RX 6000 series GPUs, but should be removed for all others, especially Radeon VII and Vega."),
        BootArgData(value: "-wegnoegpu", description: "Used for disabling all other GPUs than the integrated Intel iGPU, useful for those wanting to run newer versions of macOS where their dGPU isn't supported"),
        BootArgData(value: "-igfxnohdmi", description: "Disables DisplayPort to HDMI Audio Conversion"),
        BootArgData(value: "-cdfon", description: "Performs numerous patches required for enabling HDMI 2.0 support"),
        BootArgData(value: "-igfxvesa", description: "Forces GPU into VESA mode(no GPU acceleration), useful for troubleshooting"),
        BootArgData(value: "igfxonln=1", description: "Forces all displays online, useful for resolving screen wake issues in 10.15.4+ on Coffee and Comet Lake"),
        BootArgData(value: "igfxfw=2", description: "Enables loading Apple's GUC firmware for iGPUs, requires a 9th Gen chipset or newer(ie Z390)"),
        BootArgData(value: "debug=0x100", description: "This disables macOS's watchdog which helps prevents a reboot on a kernel panic. That way you can hopefully glean some useful info and follow the breadcrumbs to get past the issues."),
        BootArgData(value: "-v", description: "This enables verbose mode, which shows all the behind-the-scenes text that scrolls by as you're booting instead of the Apple logo and progress bar. It's invaluable to any Hackintosher, as it gives you an inside look at the boot process, and can help you identify issues, problem kexts, etc."),
        BootArgData(value: "keepsyms=1", description: "This is a companion setting to debug=0x100 that tells the OS to also print the symbols on a kernel panic. That can give some more helpful insight as to what's causing the panic itself."),
        BootArgData(value: "alcid=", description: "Used for setting layout-id for AppleALC. For more info check Dortania website."),
        BootArgData(value: "shikigva=80", description: "Enables AMD DRM for Music, Safari, TV, leaving IGPU for other applications. If this causes freezes (partially fixed in 10.15.4+), fallback to shikigva=16"),
        BootArgData(value: "shikigva=1", description: "Enables Intel online video decoder when AppleGVA enforces offline. Needed when you're wanting to use your iGPU's display out along with the dGPU, allows the iGPU to handle hardware decoding even when not using a connector-less framebuffer."),
        BootArgData(value: "shikigva=4", description: "Needed to support hardware accelerated video decoding on systems that are newer than Haswell, may need to be used with shikigva=12 to patch the needed processes"),
        BootArgData(value: "radpg=15", description: "Fixes initialization for HD 7730/7750/7770/R7 250/R7 250X"),
        BootArgData(value: "-raddvi", description: "Fixes DVI connector-type for 290X, 370, etc"),
        BootArgData(value: "-radvesa", description: "Forces GPU into VESA mode(no GPU acceleration), useful for troubleshooting. Apple's built in version of this flag is -amd_no_dgpu_accel"),
        BootArgData(value: "shikigva=128", description: "Disables software decoder unlock patches for FairPlay 1.0. This will use AMD decoder if available, but currently requires IGPU to be either not present or disabled."),
        BootArgData(value: "shikigva=256", description: "Enables software decoder unlock patches for FairPlay 4.0. This will use software decoder, but currently requires IGPU to be either not present or disabled."),
        BootArgData(value: "shikigva=64", description: "Attempt to support fps.2_1 (FairPlay 2.x) in Safari with hardware decoder. Works on most modern AMD GPUs. Broken GPU driver will just freeze the system with .gpuRestart crash"),
        BootArgData(value: "shikigva=32", description: "Replace board-id used by AppleGVA and AppleVPA by a different board-id. Sometimes it is feasible to use different GPU acceleration settings from the main mac model. By default Mac-27ADBB7B4CEE8E61 (iMac14,2) will be used, but you can override this via shiki-id boot-arg."),
        BootArgData(value: "shikigva=16", description: "Use hardware DRM decoder (normally AMD) by pretending to be iMacPro in apps that require it. For example, in Music.app or TV.app for TV+."),
        BootArgData(value: "-wegdbg", description: "Enables debug printing (available in DEBUG binaries)"),
        BootArgData(value: "-wegoff", description: "Disables WhateverGreen."),
        BootArgData(value: "-wegbeta", description: "Enables WhateverGreen on unsupported OS versions (11 and below are enabled by default)."),
        BootArgData(value: "agdpmod=ignore", description: "Disables AGDP patches (vit9696,pikera value is implicit default for external GPUs)"),
        BootArgData(value: "ngfxgl=1", description: "With \"disable-metal\" property to disable Metal support on NVIDIA"),
        BootArgData(value: "ngfxcompat=1", description: "With \"force-compat\" property to ignore compatibility check in NVDAStartupWeb"),
        BootArgData(value: "ngfxsubmit=0", description: "With \"disable-gfx-submit\" property to disable interface stuttering fix on 10.13"),
        BootArgData(value: "gfxrst=1", description: "To prefer drawing Apple logo at 2nd boot stage instead of framebuffer copying."),
        BootArgData(value: "gfxrst=4", description: "Disables framebuffer init interaction during 2nd boot stage."),
        BootArgData(value: "igfxframe=frame", description: "Injects a dedicated framebuffer identifier into IGPU (only for TESTING purposes)."),
        BootArgData(value: "igfxsnb=0", description: "Disables IntelAccelerator name fix for Sandy Bridge CPUs."),
        BootArgData(value: "-igfxtypec", description: "Forces DP connectivity for Type-C platforms"),
        BootArgData(value: "dart=0", description: "Used for disabling VT-D support. With Clover, when this flag was present it would also drop your DMAR table from ACPI. This flag also requires SIP to be disabled in macOS 10.15 Catalina, so with OpenCore this flag is no longer recommended and instead replaced with Kernel -> Quirks -> DisableIoMapper."),
        BootArgData(value: "kext-dev-mode=1", description: "Used for allowing unsigned kexts to be loaded, flag only present in Yosemite. CSR_ALLOW_UNSIGNED_KEXTS bit to be flipped in csr-active-config NVRAM variable for newer releases. This is not needed on OpenCore due to the kernel injection method used: Attaching to the prelinked kernel."),
        BootArgData(value: "darkwake=", description: "On most cases darkwake boot arg affects how computers should behave on case of Power Nap enabled. If you have Power Nap disabled then computer shouldn't wake automatically. If everything is configured properly you do not need define darkwake boot flag at all. Anyhow, there might be motherboards, which benefit from user defined value. But keep in mind that darkwake=8 and darkwake=10 are obsolete since Yosemite."),
        BootArgData(value: "-wegnoigpu", description: "IGPU disabling API"),
        BootArgData(value: "-liluoff", description: "Disables Lilu"),
        BootArgData(value: "-liluuseroff", description: "Disables Lilu user patcher (for e.g. dyld_shared_cache manipulations)."),
        BootArgData(value: "-liluslow", description: "Enables legacy user patcher."),
        BootArgData(value: "-lilulowmem", description: "Disables kernel unpack (disables Lilu in recovery mode)."),
        BootArgData(value: "-lilubeta", description: "Enables Lilu on unsupported OS versions (macOS 12 and below are enabled by default)."),
        BootArgData(value: "-lilubetaall", description: "Enables Lilu and all loaded plugins on unsupported os versions (use very carefully)."),
        BootArgData(value: "-liluforce", description: "Enables Lilu regardless of the mode, OS, installer, or recovery."),
        BootArgData(value: "liludelay=1000", description: "Enables 1 second delay after each print for troubleshooting."),
        BootArgData(value: "lilucpu=N", description: "let Lilu and plugins assume Nth CPUInfo::CpuGeneration."),
        BootArgData(value: "liludump=N", description: "let Lilu DEBUG version dump log to /var/log/Lilu_VERSION_KERN_MAJOR.KERN_MINOR.txt after N seconds."),
        BootArgData(value: "-liludbg", description: "Enables debug printing (available in DEBUG binaries)."),
        BootArgData(value: "-liludbgall", description: "Enables debug printing in Lilu and all loaded plugins (available in DEBUG binaries)."),
        BootArgData(value: "revcpu=", description: "To enable CPU brand string patching.\n  =1: non-Intel (default/disable), =0: Intel (default) \n RestrictEvents kext is required"),
        BootArgData(value: "revcpuname=", description: "Custom CPU brand string (max 48 characters, 20 or less recommended, taken from CPUID otherwise)\n RestrictEvents kext is required"),
        BootArgData(value: "-brcmfxdbg", description: "turns on debugging output"),
        BootArgData(value: "-brcmfxbeta", description: "enables loading on unsupported osx"),
        BootArgData(value: "-brcmfxoff", description: "disables kext loading"),
        BootArgData(value: "-brcmfxwowl", description: "enables WOWL (WoWLAN) - it is disabled by default"),
        BootArgData(value: "-brcmfx-alldrv", description: "allows patching for all supported drivers, disregarding current system version ..."),
        BootArgData(value: "brcmfx-country=XX", description: "changes the country code to XX (US, CN, #a, ...), also can be injected via DSDT or Properties → DeviceProperties in bootloader"),
        BootArgData(value: "brcmfx-aspm", description: "overrides value used for pci-aspm-default. Possible values: 0 = disables ASPM. kIOPCIExpressASPML0s = 0x00000001, kIOPCIExpressASPML1 = 0x00000002, kIOPCIExpressCommonClk = 0x00000040, kIOPCIExpressClkReq = 0x00000100"),
        BootArgData(value: "brcmfx-wowl", description: "enables/disables WoWLAN patch"),
        BootArgData(value: "brcmfx-delay=", description: "delays start of native broadcom driver for specified amount of milliseconds. It can solve panics or missing wi-fi device in Monterey. You can start with 15 seconds (brcmfx-delay=15000) and successively reduce this value until you notice instability in boot."),
        BootArgData(value: "brcmfx-driver=", description: "enables only one kext for loading, 0 - AirPortBrcmNIC-MFG, 1 - AirPortBrcm4360, 2 - AirPortBrcmNIC, 3 - AirPortBrcm4331, also can be injected via DSDT or Properties → DeviceProperties in bootloader"),
        BootArgData(value: "-caroff", description: "disables FeatureUnlock"),
        BootArgData(value: "-cardbg", description: "enables verbose logging for FeatureUnlock (in DEBUG builds)"),
        BootArgData(value: "-carbeta", description: "enables FeatureUnlock on macOS newer than 12"),
        BootArgData(value: "-allow_sidecar_ipad", description: "enables Sidecar support for unsupported iPads (only functional with iOS 13, iOS 14+ implements an iOS-side check)"),
        BootArgData(value: "-disable_sidecar_mac", description: "disables Sidecar/AirPlay patches"),
        BootArgData(value: "-disable_nightshift", description: "disables NightShift patches"),
        BootArgData(value: "-disable_uni_control", description: "disables Universal Control patches"),
        BootArgData(value: "-force_uni_control", description: "forces Universal Control patching even when model doesn't require"),
        BootArgData(value: "applbkl=3", description: "boot argument (and applbkl property) to enable PWM backlight control of AMD Radeon RX 5000 series graphic cards "),
        BootArgData(value: "-igfxdbeo", description: "boot argument (and enable-dbuf-early-optimizer property) to fix the Display Data Buffer (DBUF) issues on ICL+ platformsf"),
        BootArgData(value: "-igfxbls", description: "boot argument (and enable-backlight-smoother property) to make brightness transitions smoother on IVB+ platforms"),
        BootArgData(value: "-igfxmpc", description: "boot argument (enable-max-pixel-clock-override and max-pixel-clock-frequency properties) to increase max pixel clock (as an alternative to patching CoreDisplay.framework)"),
        BootArgData(value: "-igfxblr", description: "boot argument (and enable-backlight-registers-fix property) to fix backlight registers on KBL, CFL and ICL platforms"),
        BootArgData(value: "-igfxdvmt", description: "boot argument (enable-dvmt-calc-fix property) to fix the kernel panic caused by an incorrectly calculated amount of DVMT pre-allocated memory on Intel ICL platformsf"),
        BootArgData(value: "-igfxcdc", description: "boot argument (enable-cdclk-frequency-fix property) to support all valid Core Display Clock (CDCLK) frequencies on ICL platforms"),
        BootArgData(value: "igfxrpsc=1", description: "boot argument (rps-control property) to enable RPS control patch (improves IGPU performance)"),
        BootArgData(value: "wegtree=1", description: "boot argument (rebuild-device-tree property) to force device renaming on Apple FW"),
        BootArgData(value: "igfxonlnfbs=MASK", description: "boot argument (force-online-framebuffers device property) to specify indices of connectors for which online status is enforced. Format is similar to `igfxfcmsfbs`"),
        BootArgData(value: "igfxfcmsfbs=", description: "boot argument (complete-modeset-framebuffers device property) to specify indices of connectors for which complete modeset must be enforced. ..."),
        BootArgData(value: "igfxfcms=1", description: "boot argument (complete-modeset device property) to force complete modeset on Skylake or Apple firmwares."),
        BootArgData(value: "igfxagdc=0", description: "boot argument (disable-agdc device property) to disable AGDC"),
        BootArgData(value: "-igfxi2cdbg", description: "boot argument to enable verbose output in I2C-over-AUX transactions (only for debugging purposes)"),
        BootArgData(value: "-igfxlspcon", description: "boot argument (and enable-lspcon-support property) to enable the driver support for onboard LSPCON chips"),
        BootArgData(value: "-igfxhdmidivs", description: "boot argument (and enable-hdmi-dividers-fix property) to fix the infinite loop on establishing Intel HDMI connections with a higher pixel clock rate on SKL, KBL and CFL platforms."),
        BootArgData(value: "-igfxmlr", description: "boot argument (and enable-dpcd-max-link-rate-fix property) to apply the maximum link rate fix"),
        BootArgData(value: "applbkl=0", description: "boot argument (and applbkl property) to disable AppleBacklight.kext patches for IGPU. In case of custom AppleBacklight profile"),
        BootArgData(value: "-igfxfbdump", description: "dump native and patched framebuffer table to ioreg at IOService:/IOResources/WhateverGreen"),
        BootArgData(value: "-igfxdump", description: "dump IGPU framebuffer kext to /var/log/AppleIntelFramebuffer_X_Y (available in DEBUG binaries)"),
        BootArgData(value: "-cputsbeta", description: "enables CpuTscSync loading on unsupported osx"),
        BootArgData(value: "-cputsdbg", description: "turns CpuTscSync on debugging output"),
        BootArgData(value: "-cputsoff", description: "disables CpuTscSync kext loading"),
        BootArgData(value: "-cputsclock", description: "forces CpuTscSync using of method clock_get_calendar_microtime to sync TSC (the same method is used when boot-arg TSC_sync_margin is specified)"),
        BootArgData(value: "-vsmcdbg", description: "enables VirtualSMC debug printing (available in DEBUG binaries)"),
        BootArgData(value: "-vsmcoff", description: "switch off all the Lilu enhancements."),
        BootArgData(value: "-vsmcbeta", description: "enables Lilu enhancements on unsupported OS (12 and below are enabled by default)."),
        BootArgData(value: "-vsmcrpt", description: "reports about missing SMC keys to the system log."),
        BootArgData(value: "-vsmccomp", description: "to prefer existing hardware SMC implementation if found."),
        BootArgData(value: "vsmcgen=", description: "to force exposing X-gen SMC device (=1 and =2 are supported)."),
        BootArgData(value: "vsmchbkp=", description: "to set HBKP dumping mode (0 - off, 1 - normal, 2 - without encryption)."),
        BootArgData(value: "vsmcslvl=", description: "to set value serialisation level (0 - off, 1 - normal, 2 - with sensitive data (default))."),
        BootArgData(value: "smcdebug=0xff", description: "to enable AppleSMC debug information printing."),
        BootArgData(value: "watchdog=0", description: "to disable WatchDog timer (if you get accidental reboots)."),
    ]

struct GitHubInfo {
    var owner:String
    var repo: String
    var name: String
    var downloadName: String
    
}
