//
//  asyncZip.swift
//  HackinDROM
//
//  Created by lian on 23/02/2022.
//  Copyright © 2022 Inqnuam. All rights reserved.
//

import Foundation
import Zip

@discardableResult
func asyncZip(_ dir:String, customDir:String? = nil, randomizeName: Bool = false ) async -> (String?, Double) {
    
    
    var returningPath:String?
    var archiveSize:Double = 0.0
    var savingPath:String = dir
    
    if customDir != nil {
        savingPath = customDir!
    } else {
        
        savingPath = tmp + "/tmp/\(URL(fileURLWithPath: dir).lastPathComponent)"
    }
    
    
    if savingPath.last == "/" {
        if let lastSlashIndex = savingPath.lastIndex(of: "/") {
            savingPath.remove(at: lastSlashIndex)
        }
    }
    
    if !savingPath.hasSuffix(".zip") {
        savingPath += ".zip"
    }
    
    
    if fileManager.fileExists(atPath: savingPath) || randomizeName {
        let randomnumber = CreateTodayDate()
        savingPath = savingPath.replacingOccurrences(of: ".zip", with: "_\(randomnumber).zip")
    }
    
    
    do {
        try Zip.zipFiles(paths: [URL(fileURLWithPath: dir)], zipFilePath: URL(fileURLWithPath: savingPath), password: nil, progress: { progressValue -> () in
            
            if progressValue == 1.0 {
                
                
                
                do {
                    let fileAttributes = try fileManager.attributesOfItem(atPath: savingPath)
                    if let fileSize = fileAttributes[FileAttributeKey.size] as? Double {
                        
                        
                        URL.byteCountFormatter.allowedUnits = ByteCountFormatter.Units.useMB
                        URL.byteCountFormatter.countStyle = ByteCountFormatter.CountStyle.file
                        URL.byteCountFormatter.includesUnit = false
                        
                        
                        if let byteCount = Double(URL.byteCountFormatter.string(for: fileSize)!.replacingOccurrences(of: ",", with: ".")) {
                            
                            archiveSize = byteCount
                            returningPath = savingPath
                        }
                        
                        
                        
                    }
                } catch {
                    print(error)
                }
                
            }
        })
    } catch {
        print(error)
        
    }
    
    return (returningPath, archiveSize)
}
