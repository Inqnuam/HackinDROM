//
//  cleanDir.swift
//  HackinDROM
//
//  Created by lian on 22/02/2022.
//  Copyright © 2022 Inqnuam. All rights reserved.
//

import Foundation

func cleanDir(_ dir: String) {
    
    guard fileManager.fileExists(atPath: dir) else {return}
    
    if let allFiles = try? fileManager.contentsOfDirectory(atPath: dir) {
        
        for file in allFiles {
            do {
                try fileManager.removeItem(atPath: dir + "/\(file)")
            } catch {
                print(error)
            }
        }
    }
    
}
