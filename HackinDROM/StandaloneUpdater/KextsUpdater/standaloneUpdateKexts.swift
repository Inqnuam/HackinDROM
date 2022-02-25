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
    // if user uses intel wifi handle it
    
    var userKexts = await updateIntelwm(kextsDir, userKexts, stableRelease)
    
    userKexts = await updateAirportintelwmWithCustomName(kextsDir, userKexts, stableRelease)
    
    for kext in userKexts {
        if let kextPath =  await findLatestKext(kext) {
            do {
                try fileManager.copyItem(at: kextPath, to: URL(fileURLWithPath: standaloneUpdateDir + "/EFI/OC/Kexts/\(kext).kext"))
            } catch {
                print(error)
            }
        } else {
            copyFromUsersEFI(kextsDir, kext)
        }
    }
    return true
    
}


func copyFromUsersEFI(_ kextsDir: String, _ kext:String) {
    do {
        try fileManager.copyItem(atPath: kextsDir + "\(kext).kext", toPath: standaloneUpdateDir + "/EFI/OC/Kexts/\(kext).kext" )
    } catch {
        
        print(error)
    }
}

func updateIntelwm(_ kextsDir: String, _ userKexts: [String], _ stableRelease:GitHubJSON? = nil) async ->  [String] {
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
                        copyFromUsersEFI(kextsDir,"itlwm")
                    }
                } else {
                    
                    do {
                        try fileManager.copyItem(atPath: localKextPath + ".kext", toPath: standaloneUpdateDir + "/EFI/OC/Kexts/itlwm.kext")
                    } catch {
                        print(error)
                    }
                }
                
            } else {
                copyFromUsersEFI(kextsDir, "itlwm")
            }
            
        }  else {
            copyFromUsersEFI(kextsDir, "itlwm")
        }
        // remove it from usersKexts to avoid searching it in next loop
        userKexts.remove(at: foundIndex)
    }
    return userKexts
    
}



func updateAirportintelwmWithCustomName(_ kextsDir: String, _ userKexts: [String], _ stableRelease:GitHubJSON? = nil) async ->  [String] {
    guard stableRelease != nil else {return userKexts}
    var userKexts = userKexts
    let airportintelwmKexts = userKexts.filter({$0.lowercased().contains("airportitlwm")})
    
    for intl in airportintelwmKexts {
        
        // check if hackindrom supports that custom name
        if let foundCustomName =  airportItlwmCustomNames.first(where: {$0.customNames.first(where: {name in
            name.lowercased() == intl.lowercased()
        }) != nil
        }) {
            
            if let foundIndex = userKexts.firstIndex(where: {$0 == intl}) {
                userKexts.remove(at: foundIndex)
            }
            
            let localKextPath = latestFolder + "/OpenIntelWireless/\(foundCustomName.localName)"
            var cachedVersion = getKextVersionFrom(path: localKextPath)
            let usersVersion = getKextVersionFrom(path: kextsDir + "\(intl)")
            
            if let remoteVersion:Version = Version(tolerant: stableRelease!.tag_name) {
                
                if remoteVersion > cachedVersion {
                    var downloadLink: URL?
                    
                    // find download link
                    for name in foundCustomName.remoteNames {
                        if let foundRemoteFile = stableRelease!.assets.first(where: {$0.name.lowercased().contains(name.lowercased())}) {
                            downloadLink = URL(string: foundRemoteFile.browser_download_url)
                            break
                        }
                    }
                    
                    if downloadLink != nil {
                        if let downloadedPath = await downloadtoHD(url: downloadLink!) {
                            let latestKextDir = latestFolder + "/OpenIntelWireless"
                            if !fileManager.fileExists(atPath: latestKextDir) {
                                do {
                                    try fileManager.createDirectory(atPath: latestKextDir, withIntermediateDirectories: true, attributes: nil)
                                } catch {
                                    print(error)
                                }
                            }
                            
                            let downloadingPath = tmp + "/tmp/airport"
                            
                            
                            if !fileManager.fileExists(atPath: downloadingPath) {
                                do {
                                    try  fileManager.createDirectory(atPath: downloadingPath, withIntermediateDirectories: true)
                                } catch {
                                    print(error)
                                }
                                
                            }
                            
                            await asyncUnzip(from: downloadedPath, to: downloadingPath)
                            let unzipppedKexts = findKextFilesInSubDir(downloadingPath)
                            if !unzipppedKexts.isEmpty {
                                do {
                                    let cachingPath = latestKextDir + "/\(foundCustomName.localName).kext"
                                    if fileManager.fileExists(atPath: cachingPath) {
                                        try fileManager.removeItem(atPath: cachingPath)
                                    }
                                    
                                    try fileManager.moveItem(at: unzipppedKexts.first!, to: URL(fileURLWithPath: cachingPath))
                                    try fileManager.removeItem(atPath: downloadingPath)
                                } catch {
                                    print(error)
                                }
                            }
                            do {
                                try fileManager.removeItem(atPath: downloadedPath)
                            } catch {
                                print(error)
                            }
                        }
                    }
                }
            }
            
            cachedVersion = getKextVersionFrom(path: localKextPath)
            if cachedVersion >= usersVersion {
                do {
                    try fileManager.copyItem(atPath: localKextPath + ".kext", toPath: standaloneUpdateDir + "/EFI/OC/Kexts/\(intl).kext")
                } catch {
                    print(error)
                    copyFromUsersEFI(kextsDir, intl)
                }
            } else {
                copyFromUsersEFI(kextsDir, intl)
            }
            
        }
    }
    
    return userKexts
}



func findKextFilesInSubDir(_ dir: String) -> [URL] {
    var foundPaths:[URL] = []
    
    if let allFiles = try? fileManager.contentsOfDirectory(at: URL(fileURLWithPath: dir), includingPropertiesForKeys: nil, options:  [.skipsHiddenFiles]) {
        for file in allFiles {
            
            if file.pathExtension == "kext" {
                foundPaths.append(file)
            } else if directoryExistsAtPath(file.relativePath) {
                foundPaths.append(contentsOf: findKextFilesInSubDir(file.relativePath))
            }
        }
    }
    
    return foundPaths
}



fileprivate func directoryExistsAtPath(_ path: String) -> Bool {
    var isDirectory = ObjCBool(true)
    let exists = fileManager.fileExists(atPath: path, isDirectory: &isDirectory)
    return exists && isDirectory.boolValue
}
