//
//  findLatestKext.swift
//  HackinDROM
//
//  Created by lian on 21/02/2022.
//  Copyright © 2022 Inqnuam. All rights reserved.
//

import Foundation
import Version

func findLatestKext(_ kextName: String) async -> URL? {
    
    let repoName = getRepoName(kextName)
    
    // If local cached kext is up to date then return that kext path
    guard let remoteVersion = shouldUpdateLocalKext(kextName) else {return getLatestKextPath(kextName)}
    
    // When nil is returned -> kext will be copied from users EFI partition
    
    
    // if new version is availble then get zip download link
    guard let link =  await getGHDownloadLink(kextName, remoteVersion.description) else {return nil}
    
    
    // Download and update latest kext
    return await  updateCachedKext(repoName, kextName, link)
    
}


func updateCachedKext(_ repoName: String, _ kextName: String, _ link: URL) async -> URL? {
    var downloadingFileName = repoName
    
    
    // Repo name is VoodooPS2 but kext name is VoodooPS2Controller
    // some people rename VoodooPS2Controller to VoodooPS2
    if isVoodooPS2(kextName) {
        downloadingFileName = "VoodooPS2Controller"
    }
    
    // BrcmPatchRAM repo contains multiple kexts but the zip file's name is BrcmPatchRAM
    if isBroadcomRelated(kextName) {
        downloadingFileName = "BrcmPatchRAM"
    }
    
    do {
        let latestKextDir = latestFolder + "/\(repoName)"
        do {
            try fileManager.createDirectory(atPath: latestKextDir, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error)
        }
        
        guard let downloadedPath = await downloadtoHD(url: link) else {return nil}
        
        
        await asyncUnzip(from: downloadedPath, to: latestKextDir)
        
        try fileManager.removeItem(atPath: downloadedPath)
        
        // Move kexts into cached repo root dir and remove other files (dSYM, tools..)
        cleanDownloadedLatestKext(latestKextDir)
        
        
        
        if  repoName == "IntelMausi" ||  repoName == "BrcmPatchRAM" ||  repoName == "AppleALC"  ||  repoName == "IntelBluetoothFirmware" {
            return URL(fileURLWithPath: "\(latestKextDir)/\(kextName).kext")
        } else {
            
            return URL(fileURLWithPath: "\(latestKextDir)/\(downloadingFileName).kext")
        }
        
        
    } catch {
        print(error)
        return nil
    }
}


