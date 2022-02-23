//
//  getRepoName.swift
//  HackinDROM
//
//  Created by lian on 21/02/2022.
//  Copyright © 2022 Inqnuam. All rights reserved.
//

import Foundation


func getRepoName(_ kextName: String)-> String {
    
    var repoName = kextName
    
    if isIntelBT(kextName) {
     
        repoName = "IntelBluetoothFirmware"
    }
  else if isBroadcomRelated(kextName) {
        repoName = "BrcmPatchRAM"
    }
    
   else if isALC(kextName) {
        repoName = "AppleALC"
    }
    
   else if isIntelMausi(kextName) {
        repoName = "IntelMausi"
    }
    
   else if isVirtualSMCPlugin(kextName) {
        repoName = "VirtualSMC"
    }
    
   else if isVoodooPS2(kextName) {
        repoName = "VoodooPS2"
    }
    return repoName
}


func getRepoOwner(_ kextName: String) -> String {
    var repoOwner = "acidanthera"
    if isIntelBT(kextName) {
        repoOwner = "OpenIntelWireless"
    }
    return repoOwner
}
