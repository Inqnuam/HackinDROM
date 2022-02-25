//
//  shouldUpdateLocalKext.swift
//  HackinDROM
//
//  Created by lian on 21/02/2022.
//  Copyright © 2022 Inqnuam. All rights reserved.
//

import Foundation
import Version
func shouldUpdateLocalKext(_ kextInfo: GitHubInfo) -> String? {
 
   
    
    guard let versions = getGitReleasesVersions(kextInfo.owner, kextInfo.repo, true) else {return  nil}
    
    let remoteVersion = Version(tolerant: versions.first!)!
    let localKextPath = latestFolder + "/\(kextInfo.repo)/\(kextInfo.name)"
    
    let localVersion = getKextVersionFrom(path: localKextPath)
    
    if remoteVersion > localVersion {
        return versions.first!
    } else {
        return nil
    }
}
