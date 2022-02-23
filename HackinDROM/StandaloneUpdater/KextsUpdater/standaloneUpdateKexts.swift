//
//  standaloneUpdateKexts.swift
//  HackinDROM
//
//  Created by lian on 21/02/2022.
//  Copyright © 2022 Inqnuam. All rights reserved.
//

import Foundation
import Version
func standaloneUpdateKexts(_ kextsDir: String, _ userKexts: [String], _ stableRelease:GitHubJSON? = nil) async -> Bool {
    
    var userKexts = userKexts
    
    if stableRelease != nil,  let foundIndex = userKexts.firstIndex(where: {$0 == "itlwm"}) {
        let repoName = "OpenIntelWireless"
        if let intelwm = stableRelease!.assets.first(where: {$0.name.hasPrefix("itlwm")}) {
          
            let localKextPath = latestFolder + "/\(repoName)/itlwm"
            let localVersion = getKextVersionFrom(path: localKextPath)
         
            if let remoteVersion:Version = Version(tolerant: stableRelease!.tag_name) {
                
                if remoteVersion > localVersion {
                   
                        if let downloadedPath = await downloadtoHD(url: URL(string: intelwm.browser_download_url)!) {
                            
                            let latestKextDir = latestFolder + "/\(repoName)"
                            do {
                                try fileManager.createDirectory(atPath: latestKextDir, withIntermediateDirectories: true, attributes: nil)
                            } catch {
                                print(error)
                            }
                            
                            await asyncUnzip(from: downloadedPath, to: latestKextDir)
                            
                            do {
                                try fileManager.removeItem(atPath: downloadedPath)
                            } catch {
                                print(error)
                            }
                            // Move kexts into cached repo root dir and remove other files (dSYM, tools..)
                            cleanDownloadedLatestKext(latestKextDir)
                            
                            do {
                                try fileManager.copyItem(atPath: latestKextDir + "/itlwm.kext", toPath: standaloneUpdateDir + "/EFI/OC/Kexts/itlwm.kext")
                            } catch {
                                print(error)
                            }
                            
                            
                        } else {
                            
                            copyFromUsersEFI("itlwm")
                         
                            
                        }
                    
                   
                } else {
                    
                    do {
                        try fileManager.copyItem(atPath: localKextPath + ".kext", toPath: standaloneUpdateDir + "/EFI/OC/Kexts/itlwm.kext")
                    } catch {
                        print(error)
                    }
                }
                
            } else {
              
                copyFromUsersEFI("itlwm")
            }
            
        }  else {
            copyFromUsersEFI("itlwm")
            
        }
        userKexts.remove(at: foundIndex)
    }
    
    
    
    func copyFromUsersEFI(_ kext:String) {
        do {
            try fileManager.copyItem(atPath: kextsDir + "\(kext).kext", toPath: standaloneUpdateDir + "/EFI/OC/Kexts/\(kext).kext" )
        } catch {
           
            print(error)
        }
    }
    
    for kext in userKexts {
        
        
        if let kextPath =  await findLatestKext(kext) {
            
            
            do {
                try fileManager.copyItem(at: kextPath, to: URL(fileURLWithPath: standaloneUpdateDir + "/EFI/OC/Kexts/\(kext).kext"))
            } catch {
                print(error)
            }
        } else {
            copyFromUsersEFI(kext)
        }
    }
    return true
    
}



