//
//  getGHDownloadLink.swift
//  HackinDROM
//
//  Created by lian on 24/02/2022.
//  Copyright © 2022 Inqnuam. All rights reserved.
//

import Foundation

func getGHDownloadLink(_ kextInfo: GitHubInfo, _ latestVersion: String) async -> URL? {
    
   
    let downloadingFileName = kextInfo.downloadName.replacingOccurrences(of: "#", with: latestVersion)
 
        if let link:URL = URL(string: "https://github.com/\(kextInfo.owner)/\(kextInfo.repo)/releases/download/\(latestVersion)/\(downloadingFileName)") {
          
            return link
        } else {return nil}
        
  
//    if let foundLink = await getGitHubRepoDownloadLinkfromHTML(kextInfo) {
//
//        if let link:URL = URL(string: foundLink) {
//            return link
//        } else {return nil}
//    } else {return nil}
}
