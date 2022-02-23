//
//  copyMissingFiles.swift
//  HackinDROM
//
//  Created by lian on 22/02/2022.
//  Copyright © 2022 Inqnuam. All rights reserved.
//

import Foundation

func copyMissingFiles(from: String, to: String) {
    
    guard fileManager.fileExists(atPath: from) else {return}
    
    if let allFiles = try? fileManager.contentsOfDirectory(atPath: from) {
        
        for file in allFiles {
            
            if !fileManager.fileExists(atPath: to + "/\(file)") {
                do {
                    try fileManager.copyItem(atPath: from + "/\(file)", toPath: to + "/\(file)")
                } catch {
                    print(error)
                }
            }
        }
    }
    
}
