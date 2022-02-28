//
//  standaloneUpdateDrivers.swift
//  HackinDROM
//
//  Created by lian on 21/02/2022.
//  Copyright © 2022 Inqnuam. All rights reserved.
//

import Foundation

func standaloneUpdateDrivers(_ usersDriversDir: String) async {
    var commitDate: Date?
    let localDriversDir = standaloneUpdateDir + "/EFI/OC/Drivers"
    
    guard var localDrivers = getFilesFrom(localDriversDir) else {
        // if no driver is found in local then copy all drivers from user's EFI
        
        do {
            try fileManager.copyItem(atPath: usersDriversDir, toPath: localDriversDir)
        } catch {
            print(error)
        }
        return
        
    }
    guard  let usersDrivers = getFilesFrom(usersDriversDir) else {
        // if users dont use any driver then remove them from local dir
        cleanDir(localDriversDir)
        return
        
    }
    
    
    commitDate = getGitLatestCommitDate("https://github.com/acidanthera/OcBinaryData/commits.atom")
    for driver in localDrivers {
        
        if !usersDrivers.contains(where: {$0.lowercased() == driver.lowercased()}) {
            do {
                try fileManager.removeItem(atPath: localDriversDir + "/\(driver).efi")
            } catch {
                print(error)
            }
        }
    }
    localDrivers = getFilesFrom(localDriversDir)!
    
    // check for drivers which are not inside original OC release folder
    for driver in usersDrivers {
        if let foundName = localDrivers.first(where: {$0.lowercased() == driver.lowercased()}) {
            // if it contains then rename the file to be sure it match users defined file name
            if foundName != driver {
                do {
                    try fileManager.moveItem(atPath: localDriversDir + "/\(foundName).efi", toPath: localDriversDir + "/\(driver).efi")
                } catch {
                    print(error)
                }
            }
        } else {
            // check if we can find the driver in cache or on internet
            if let foundPath = await findDriverPath(driver, commitDate: commitDate) {
                do {
                    try fileManager.copyItem(atPath: foundPath, toPath: localDriversDir + "/\(driver).efi")
                } catch {
                    print(error)
                }
            } else {
                // copy from users EFI drivers
                do {
                    try fileManager.copyItem(atPath: usersDriversDir + "/\(driver).efi", toPath: localDriversDir + "/\(driver).efi")
                } catch {
                    print(error)
                }
            }
        }
    }
}





