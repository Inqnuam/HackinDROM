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
                    if !allDrivers.Childs.isEmpty {
                        foundDriverTemplate = allDrivers.Childs.first!
                    }
                }
            }
            return foundDriverTemplate
        }
    }
    
    var cleanedDriverTemplate = cleanHAPlistStruct(driverTemplate)
    
    if let foundPathIndex = cleanedDriverTemplate.Childs.firstIndex(where: {$0.name == "Path"}) {
        
        cleanedDriverTemplate.Childs[foundPathIndex].StringValue = driverPath.replacingOccurrences(of: "#", with: "")
    }
    
    
    
    if let foundEnabledIndex = cleanedDriverTemplate.Childs.firstIndex(where: {$0.name == "Enabled"}) {
        
        cleanedDriverTemplate.Childs[foundEnabledIndex].BoolValue = driverPath.hasPrefix("#") ? false : true
    }
    
    
    
    return cleanedDriverTemplate
}
