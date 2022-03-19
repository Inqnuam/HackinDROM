//
//  getLatestOCPath.swift
//  HackinDROM
//
//  Created by lian on 21/02/2022.
//  Copyright © 2022 Inqnuam. All rights reserved.
//

import Foundation
import Version
func getLatestOCPath()  async -> String? {
    do {
        guard let gitOCReleasesVersions =  getGitReleasesVersions("acidanthera", "OpenCorePkg", true) else {return nil}
        let latestOCVersion = Version(gitOCReleasesVersions[0])
        let latestOcUrl = URL(string: "https://github.com/acidanthera/OpenCorePkg/releases/download/\(gitOCReleasesVersions.first!)/OpenCore-\(gitOCReleasesVersions.first!)-RELEASE.zip")!
        let latestOCFolder = latestFolder + "/oc/" + gitOCReleasesVersions.first!
        
        if !fileManager.fileExists(atPath: latestFolder + "/oc") {
            try fileManager.createDirectory(atPath: latestFolder + "/oc", withIntermediateDirectories: true, attributes: nil)
        }
        let filesOfDir = try fileManager.contentsOfDirectory(at: URL(fileURLWithPath: latestFolder + "/oc"), includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
        if filesOfDir.isEmpty {
            
            try fileManager.createDirectory(atPath: latestOCFolder, withIntermediateDirectories: true, attributes: nil)
            // download
            guard  let downloadedPath = await downloadtoHD(url: latestOcUrl) else {
                try fileManager.removeItem(atPath: latestOCFolder)
                return nil
            }
            
            await asyncUnzip(from: downloadedPath, to: latestOCFolder)
            try fileManager.removeItem(atPath: downloadedPath)
            
            return latestOCFolder
        } else  {
            let localOCVersion = Version(filesOfDir[0].lastPathComponent)
            if latestOCVersion! > localOCVersion! {
                let oldOCPath = latestFolder + "/oc/" + localOCVersion!.description
                
                try fileManager.removeItem(atPath: oldOCPath) // -> previously latestOCFolder
                try fileManager.createDirectory(atPath: latestOCFolder, withIntermediateDirectories: true, attributes: nil)
                
                
                guard  let downloadedPath = await downloadtoHD(url: latestOcUrl) else {
                    try fileManager.removeItem(atPath: latestOCFolder)
                    // TODO: add callback to tell about this error, OC not compiled yet...
                    return nil
                }
                
                await asyncUnzip(from: downloadedPath, to: latestOCFolder)
                try fileManager.removeItem(atPath: downloadedPath)
                
                return latestOCFolder
                
                
            } else {
                return filesOfDir[0].relativePath
            }
        }
    }
    catch {
        
        print(error)
        return nil
    }
}
