//
//  updateCachedKext.swift
//  HackinDROM
//
//  Created by lian on 24/02/2022.
//  Copyright © 2022 Inqnuam. All rights reserved.
//

import Foundation
import Version

func updateCachedKext(_ kextInfo: GitHubInfo, _ remoteVersion: String) async -> URL? {
    guard let link =  await getGHDownloadLink(kextInfo, remoteVersion) else {return nil}
    
  
        let latestKextDir = latestFolder + "/\(kextInfo.repo)"
        do {
            try fileManager.createDirectory(atPath: latestKextDir, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error)
        }
        
        guard let downloadedPath = await downloadtoHD(url: link) else {return nil}
        
        
        await asyncUnzip(from: downloadedPath, to: latestKextDir)
        
    do {
        try fileManager.removeItem(atPath: downloadedPath)
    } catch {
        print(error)
        return nil
    }
      
        
        // Move kexts into cached repo root dir and remove other files (dSYM, tools..)
        cleanDownloadedLatestKext(latestKextDir)
        
        return URL(fileURLWithPath: "\(latestKextDir)/\(kextInfo.name).kext")
   
}
