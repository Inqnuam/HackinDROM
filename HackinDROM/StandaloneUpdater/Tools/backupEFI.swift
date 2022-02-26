//
//  backupEFI.swift
//  HackinDROM
//
//  Created by lian on 23/02/2022.
//  Copyright © 2022 Inqnuam. All rights reserved.
//

import Foundation



func backupEFI(backedUpPath: String, canBackUp:Bool, savingPath: String) {
    var fileName = URL(fileURLWithPath: backedUpPath).lastPathComponent
    if canBackUp {
        
        
        if fileManager.fileExists(atPath: savingPath + "/\(fileName)") {
            
            fileName = fileName.replacingOccurrences(of: ".zip", with: "\(CreateTodayDate()).zip")
        }
        
        do {
            try fileManager.moveItem(atPath: backedUpPath, toPath: savingPath + "/\(fileName)")
        } catch {
            print(error)
            print("cant move backedUp archie to saving Path")
        }
        
        
    } else {
        
        print("❌ CAN'T BackUp")
        
        // if users already defined a backup dir then move archive there
        // if not ask for new backup dir
        
        let hasSelectedBackupDir = UserDefaults.standard.bool(forKey: "BackUpToFolder")
        if let customBackupdir = UserDefaults.standard.string(forKey: "BackUpsCustomFolder") {
        
        if hasSelectedBackupDir && fileManager.fileExists(atPath: customBackupdir) {
            
            
            do {
                let backedUpFileName = URL(fileURLWithPath: backedUpPath).lastPathComponent
                try fileManager.moveItem(atPath: backedUpPath, toPath: customBackupdir + "/\(backedUpFileName)")
            } catch {
                print(error)
                print("cant move backedUp archive to saving Path")
            }
            
        }
        else {
            // present file selector for custom dir
            // #FIXME: opening file selector dialog crashs the app from async func...
            //
            //
            //            let selectedPath = FileSelector(allowedFileTypes: [], canCreateDirectories: true, canChooseFiles: false, canChooseDirectories: true, customTitle: "Custom backup folder")
            //
            //            if !selectedPath.isEmpty && selectedPath != "nul" {
            //
            //                do {
            //                    let backedUpFileName = URL(fileURLWithPath: backedUpPath).lastPathComponent
            //                    try fileManager.moveItem(atPath: backedUpPath, toPath: selectedPath + "/\(backedUpFileName)")
            //
            //                    UserDefaults.standard.set(true, forKey: "BackUpToFolder")
            //                    UserDefaults.standard.set(selectedPath, forKey: "BackUpsCustomFolder")
            //                } catch {
            //                    print(error)
            //                    print("cant move backedUp archive to saving Path")
            //                }
            //            }
            
        }
    }
    }
}
