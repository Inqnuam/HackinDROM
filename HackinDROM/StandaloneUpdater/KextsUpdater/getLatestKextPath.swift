//
//  getLatestKextPath.swift
//  HackinDROM
//
//  Created by lian on 21/02/2022.
//  Copyright © 2022 Inqnuam. All rights reserved.
//

import Foundation

func getLatestKextPath(_ kextName: String) -> URL? {
    
    let repoName = getRepoName(kextName)
    let kextPath = latestFolder + "/\(repoName)/\(kextName).kext"
    
    if fileManager.fileExists(atPath: kextPath) {
        return URL(fileURLWithPath: kextPath)
    } else {return nil}
}

