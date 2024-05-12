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
    
    let version = versions.first!
    var remoteVersion = Version(tolerant: version)
    
    
    if remoteVersion == nil {
        // trying to parse version manually, example: "0.7.2f1"
        var rawVersionComponents: [String] = []
        
        for v in version.components(separatedBy:  ".") {
            
            if Int(v) != nil  {
                rawVersionComponents.append(v)
            } else {
                
                var versionComponent = ""
                
                for dirtyComponent in Array(v) {
                    let dirtyString = String(dirtyComponent)
                    if Int(dirtyString) == nil {
                        break
                    }
                    versionComponent += dirtyString
                }
                
                if !versionComponent.isEmpty {
                    rawVersionComponents.append(versionComponent)
                }
                
                break
            }
            
        }
        
        remoteVersion = Version(tolerant: rawVersionComponents.joined(separator: "."))
        
    }
    
    if remoteVersion == nil {
        return nil
    }
    
    
    let localKextPath = latestFolder + "/\(kextInfo.repo)/\(kextInfo.name)"
    
    let localVersion = getKextVersionFrom(path: localKextPath)
    
    if remoteVersion! > localVersion {
        return versions.first!
    } else {
        return nil
    }
}
