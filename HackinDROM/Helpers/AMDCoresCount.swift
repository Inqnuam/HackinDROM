//
//  AMDCoresCount.swift
//  HackinDROM
//
//  Created by lian on 19/02/2022.
//  Copyright © 2022 Inqnuam. All rights reserved.
//

import Foundation


func getLogicalCPUCount()-> String {
    var totalCPUCores = ""
    shell("sysctl hw.physicalcpu") { res, _ in
        let stdOut = res.replace(string: "hw.physicalcpu: ", replacement: "")
        
        
        switch stdOut {
            case "6":
                totalCPUCores = "06"
                break
                
            case "8":
                totalCPUCores = "08"
                break
                
            case "12":
                totalCPUCores = "OC"
                break
                
            case "16":
                totalCPUCores = "10"
                break
                
            case "32":
                totalCPUCores = "20"
                break
                
            default:
                totalCPUCores = "08"
        }
        
    }
    return totalCPUCores
}

