//
//  cleanDir.swift
//  HackinDROM
//
//  Created by lian on 21/02/2022.
//  Copyright © 2022 Inqnuam. All rights reserved.
//

import Foundation

func checkAndCleanStandaloneDir () {
    
    do {
        if !fileManager.fileExists(atPath: standaloneUpdateDir) {
            
            try fileManager.createDirectory(atPath: standaloneUpdateDir, withIntermediateDirectories: true, attributes: nil)
            
            
        }
        else {
            
            try fileManager.removeItem(atPath: standaloneUpdateDir)
            try fileManager.createDirectory(atPath: standaloneUpdateDir, withIntermediateDirectories: true, attributes: nil)
            
        }
    }
    catch {
        
    }
}

func cleanDownloadedLatestKext(_ latestKextDir: String) {
    
    if latestKextDir.contains("VirtualSMC") {
        cleanDownloadedVirtualSCMDir(latestKextDir)
    } else {
        do {
            let dirItems = try fileManager.contentsOfDirectory(at: URL(fileURLWithPath: latestKextDir), includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
            
            let filesToDelete = dirItems.filter { $0.pathExtension != "kext" }
            
            for itm in filesToDelete {
                try fileManager.removeItem(at: itm)
            }
            
        } catch {
            print(error)
        }
    }
    
}

func cleanDownloadedVirtualSCMDir(_ latestKextDir: String) {
    
    do {
        let dirItems = try fileManager.contentsOfDirectory(at: URL(fileURLWithPath: latestKextDir + "/Kexts"), includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
        
        let SMCPlugins = dirItems.filter { $0.pathExtension == "kext" }
        
        for itm in SMCPlugins {
            try fileManager.moveItem(at: itm, to: URL(fileURLWithPath: latestKextDir + "/\(itm.lastPathComponent)" ))
        }
        
    } catch {
        print(error)
    }
}
