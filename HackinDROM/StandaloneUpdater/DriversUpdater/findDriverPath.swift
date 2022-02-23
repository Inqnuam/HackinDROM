//
//  findDriverPath.swift
//  HackinDROM
//
//  Created by lian on 21/02/2022.
//  Copyright © 2022 Inqnuam. All rights reserved.
//

import Foundation

func findDriverPath(_ driver: String) async -> String? {
    
    guard let latestOCVersion = getOCVersionFromCache(latestFolder + "/oc") else {return nil}
    let cachedDriversDir = latestFolder + "/oc/\(latestOCVersion)/X64/EFI/OC/Drivers"
    let cachedDriverPath = cachedDriversDir + "/\(driver).efi"
    
    
    
    guard let cachedDrivers = getFilesFrom(cachedDriversDir) else { return await  downloadDriver(driver, cachedDriverPath)}
    
    if cachedDrivers.contains(driver) {
        
        // compare cached date with latest commit date
        // later better implementation is prefered
        
        var shouldUpdate:Bool = false
        if let attr = try? fileManager.attributesOfItem(atPath: cachedDriverPath) {
            if let modifiedDate = attr[FileAttributeKey.modificationDate] as? Date {
                print("DRIVER MODIFED DATE:", modifiedDate)
                if let commitDate = commitDate,  commitDate > modifiedDate{
                    shouldUpdate = true
                }
            }

        }
        
       
        if shouldUpdate {
            return await  downloadDriver(driver, cachedDriverPath)
        } else {
            return cachedDriverPath
        }
       
    } else {
        return await  downloadDriver(driver, cachedDriverPath)
    }
      
}
