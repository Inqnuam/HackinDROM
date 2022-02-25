//
//  findDriverPath.swift
//  HackinDROM
//
//  Created by lian on 21/02/2022.
//  Copyright © 2022 Inqnuam. All rights reserved.
//

import Foundation

func findDriverPath(_ driver: String,  commitDate: Date?) async -> String? {
    
  
    let cachedDriversDir =  "\(latestOCFolder)/X64/EFI/OC/Drivers"
    let cachedDriverPath = cachedDriversDir + "/\(driver).efi"
    
    
    print("findDriverPath \(driver)")
    guard let cachedDrivers = getFilesFrom(cachedDriversDir) else { return await  downloadDriver(driver, cachedDriverPath)}
    
    if cachedDrivers.contains(driver) {
        
        // compare cached date with latest commit date
        // later better implementation is prefered
        
        var shouldUpdate:Bool = false
        if let attr = try? fileManager.attributesOfItem(atPath: cachedDriverPath) {
            if let modifiedDate = attr[.modificationDate] as? Date {
                print("DRIVER MODIFED DATE:", modifiedDate)
                if let commitDate = commitDate,  commitDate > modifiedDate{
                    shouldUpdate = true
                }
            }

        }
        
       
        if shouldUpdate {
           
            return await downloadDriver(driver, cachedDriverPath)
        } else {
           
            return cachedDriverPath
        }
       
    } else {
       
        return await downloadDriver(driver, cachedDriverPath)
    }
      
}
