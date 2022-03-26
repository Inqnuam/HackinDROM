//
//  generateNewDriverStructType.swift
//  HackinDROM
//
//  Created by lian on 28/02/2022.
//

import Foundation

func generateNewDriverStructType(template: HAPlistStruct? = nil , driverPath: String)-> HAPlistStruct {
    
    var driverTemplate:HAPlistStruct {
        if template != nil {return template!}
        else {
            var foundDriverTemplate = HAPlistStruct()
            getHAPlistFrom(latestOCFolder + "/Docs/SampleCustom.plist") { plist in
                if let allDrivers = plist.get(["UEFI", "Drivers"]) {
                    if !allDrivers.childs.isEmpty {
                        foundDriverTemplate = allDrivers.childs.first!
                    }
                }
            }
            return foundDriverTemplate
        }
    }
    
    var cleanedDriverTemplate = cleanHAPlistStruct(driverTemplate)
    
    if let foundPathIndex = cleanedDriverTemplate.childs.firstIndex(where: {$0.name == "Path"}) {
        
        cleanedDriverTemplate.childs[foundPathIndex].stringValue = driverPath.replacingOccurrences(of: "#", with: "")
    }
    
    
    
    if let foundEnabledIndex = cleanedDriverTemplate.childs.firstIndex(where: {$0.name == "Enabled"}) {
        
        cleanedDriverTemplate.childs[foundEnabledIndex].boolValue = driverPath.hasPrefix("#") ? false : true
    }
    
    
    
    return cleanedDriverTemplate
}
