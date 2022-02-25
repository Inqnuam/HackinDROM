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
    
    guard let localDrivers = getFilesFrom(localDriversDir), let usersDrivers = getFilesFrom(usersDriversDir) else {return}
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
    
    for driver in usersDrivers {
        if !localDrivers.contains(where: {$0.lowercased() == driver.lowercased()}) {
            
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





