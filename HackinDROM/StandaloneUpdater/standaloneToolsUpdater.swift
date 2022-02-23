//
//  standaloneToolsUpdater.swift
//  HackinDROM
//
//  Created by lian on 22/02/2022.
//  Copyright © 2022 Inqnuam. All rights reserved.
//

import Foundation

func standaloneToolsUpdater(_ usersToolsDir: String) {
    let toolsDir =  standaloneUpdateDir + "/EFI/OC/Tools"
    
    if let standaloneTools = try? fileManager.contentsOfDirectory(atPath: toolsDir) {
        
        for tool in standaloneTools {
            
            if !fileManager.fileExists(atPath: usersToolsDir + "/\(tool)") {
                do {
                    try fileManager.removeItem(atPath: toolsDir + "/\(tool)")
                } catch {
                    print(error)
                }
            }
        }
    }
    
    if let userseTools = try? fileManager.contentsOfDirectory(atPath: usersToolsDir) {
        
        for tool in userseTools {
            
            if !fileManager.fileExists(atPath: toolsDir + "/\(tool)") {
                do {
                    try fileManager.copyItem(atPath: usersToolsDir + "/\(tool)", toPath: toolsDir + "/\(tool)")
                } catch {
                    print(error)
                }
            }
        }
    }
}
