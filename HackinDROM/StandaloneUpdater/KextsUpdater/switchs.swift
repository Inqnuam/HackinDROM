//
//  switchs.swift
//  HackinDROM
//
//  Created by lian on 21/02/2022.
//  Copyright © 2022 Inqnuam. All rights reserved.
//

import Foundation

func isVirtualSMCPlugin(_ kextName: String)-> Bool {
    switch kextName {
        case "SMCBatteryManager":
            return true
            
        case "SMCDellSensors":
            return true
            
        case "SMCLightSensor":
            return true
            
        case "SMCProcessor":
            return true
            
        case "SMCSuperIO":
            return true
            
        default:
            return false
            
    }
}

func isBroadcomRelated(_ kextName: String)-> Bool {
    switch kextName {
        case "BlueToolFixup":
            return true
            
        case "BrcmBluetoothInjector":
            return true
            
        case "BrcmBluetoothInjectorLegacy":
            return true
            
        case "BrcmFirmwareData":
            return true
            
        case "BrcmFirmwareRepo":
            return true
            
        case "BrcmNonPatchRAM":
            return true
            
        case "BrcmNonPatchRAM2":
            return true
            
        case "BrcmPatchRAM":
            return true
            
        case "BrcmPatchRAM2":
            return true
            
        case "BrcmPatchRAM3":
            return true
            
        default:
            return false
            
    }
    
}

func isVoodooPS2(_ kextName: String)-> Bool {
    switch kextName {
        case "VoodooPS2Controller":
            return true
            
        case "VoodooPS2":
            return true
            
        default:
            return false
            
    }
}


func isIntelMausi(_ kextName: String)-> Bool {
    switch kextName {
        case "IntelMausi":
            return true
            
        case "IntelSnowMausi":
            return true
            
        default:
            return false
            
    }
}
func isALC(_ kextName: String)-> Bool {
    switch kextName {
        case "AppleALC":
            return true
            
        case "AppleALCU":
            return true
            
        default:
            return false
            
    }
}

func isIntelBT(_ kextName: String)-> Bool {
    switch kextName {
        case "IntelBluetoothFirmware":
            return true
            
        case "IntelBluetoothInjector":
            return true
            
        default:
            return false
            
    }
}
