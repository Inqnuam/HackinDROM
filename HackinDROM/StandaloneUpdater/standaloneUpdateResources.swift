//
//  standaloneUpdateResources.swift
//  HackinDROM
//
//  Created by lian on 21/02/2022.
//  Copyright © 2022 Inqnuam. All rights reserved.
//

import Foundation

func standaloneUpdateResources(_ usersResourcesDir: String) {
   let resourcesDir =  standaloneUpdateDir + "/EFI/OC/Resources"
    
    if fileManager.fileExists(atPath: resourcesDir) {
        
        do {
            try fileManager.removeItem(atPath: resourcesDir)
        } catch {
            print(error)
        }
    }
    
    do {
        try fileManager.copyItem(atPath: usersResourcesDir, toPath: resourcesDir)
    } catch {
        print(error)
    }
}
