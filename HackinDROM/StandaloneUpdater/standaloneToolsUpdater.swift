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
    guard let standaloneTools = getFilesFrom(toolsDir), let usersTools = getFilesFrom(usersToolsDir) else {return}
    for tool in standaloneTools {
        let originalToolPath = toolsDir + "/\(tool).efi"
        if let foundTool = usersTools.first(where: {$0.lowercased() == tool.lowercased()}) {
            
            do {
                // rename file to be insure case insensitivity
                try fileManager.moveItem(atPath: originalToolPath, toPath:  toolsDir + "/\(foundTool).efi")
            } catch {
                print(error)
            }
            
        } else {
            //remove not needed tools
            do {
                try fileManager.removeItem(atPath: originalToolPath)
            } catch {
                print(error)
            }
        }
    }
    
    // keep custom, not found, not updatable tools
    if let updatedStandaloneToolsList = getFilesFrom(toolsDir) {
        for tool in usersTools {
            if !updatedStandaloneToolsList.contains(tool) {
                do {
                    try fileManager.copyItem(atPath: usersToolsDir + "/\(tool).efi", toPath: toolsDir + "/\(tool).efi")
                } catch {
                    print(error)
                }
            }
        }
    }
}
