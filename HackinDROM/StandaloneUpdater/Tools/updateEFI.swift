//
//  updateEFI.swift
//  HackinDROM
//
//  Created by lian on 23/02/2022.
//  Copyright © 2022 Inqnuam. All rights reserved.
//

import Foundation



func updateEFI(canUpdate: Bool, savingPath:String) -> String? {
    var savingPath = savingPath
    
    if fileManager.fileExists(atPath: savingPath) {
        savingPath = URL(fileURLWithPath: savingPath).deletingLastPathComponent().relativePath + "/EFI_\(CreateTodayDate())"
    }
    
    if canUpdate {
        do {
            try fileManager.moveItem(atPath: standaloneUpdateDir + "/EFI", toPath: savingPath)
            return savingPath
        } catch {
            // may fail for various reason like no permission on volume, Argument list too long
            // unstable USB stick may throws these errors
            
            print(error)
            print("Cant move standalone to savingPath")
            return nil
            
        }
        
    } else {
        print("❌ CAN'T Update")
        
        // #TODO: show file selector
        return nil
    }
}


