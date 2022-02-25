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
    
    guard  let kextInfo = getKextGitHubRepoInfo(kextName) else {return nil}
   
    // If local cached kext is up to date then return that kext path
    // When nil is returned -> kext will be copied from users EFI partition
    guard let remoteVersion = shouldUpdateLocalKext(kextInfo) else {return getLatestKextPath(kextInfo)}
    
   
    
    
    // if new version is availble then get zip download link
   
    
    
    // Download and update latest kext
    // then return kext cached path
    return await  updateCachedKext(kextInfo, remoteVersion)
    
}




