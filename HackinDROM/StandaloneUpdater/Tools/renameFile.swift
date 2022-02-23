//
//  renameFile.swift
//  HackinDROM
//
//  Created by lian on 23/02/2022.
//  Copyright © 2022 Inqnuam. All rights reserved.
//

import Foundation





func renameFile(_ path:String, newName: String, overwrite: Bool) -> String? {
    let oldName = URL(fileURLWithPath: path).lastPathComponent
    let newPath = path.replacingOccurrences(of: oldName, with: newName)
    
    if overwrite && fileManager.fileExists(atPath: newPath) {
        do {
            try fileManager.removeItem(atPath: newPath)
        } catch {
            
            print(error)
            
        }
    }
    do {
        try fileManager.moveItem(atPath: path, toPath: newPath)
        return newPath
    } catch {
        print("can't rename file \(oldName) to \(newName)")
        return nil
        
    }
}
