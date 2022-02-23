//
//  shouldUpdateLocalKext.swift
//  HackinDROM
//
//  Created by lian on 21/02/2022.
//  Copyright © 2022 Inqnuam. All rights reserved.
//

import Foundation
import Version
func shouldUpdateLocalKext(_ kextName: String) -> Version? {
 
    let repoOwner = getRepoOwner(kextName)
    let repoName = getRepoName(kextName)
    
    
    guard let versions = getGitReleasesVersions(repoOwner, repoName, true) else {return  nil}
    
    let remoteVersion = Version(tolerant: versions.first!)!
    
    let localKextPath = latestFolder + "/\(repoName)/\(kextName)"
    
    let localVersion = getKextVersionFrom(path: localKextPath)
    
    if remoteVersion > localVersion {
        return remoteVersion
    } else {
        return nil
    }
}
