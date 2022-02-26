//
//  getDriverDownloadLink.swift
//  HackinDROM
//
//  Created by lian on 21/02/2022.
//  Copyright © 2022 Inqnuam. All rights reserved.
//

import Foundation


let driverGitHubLinks: [GitHubInfo] = [
    GitHubInfo(owner: "acidanthera", repo: "OcBinaryData", name: "ExFatDxe", downloadName: "https://github.com/acidanthera/OcBinaryData/raw/master/Drivers/ExFatDxe.efi"),
    GitHubInfo(owner: "acidanthera", repo: "OcBinaryData", name: "ExFatDxeLegacy", downloadName: "https://github.com/acidanthera/OcBinaryData/raw/master/Drivers/ExFatDxeLegacy.efi"),
    GitHubInfo(owner: "acidanthera", repo: "OcBinaryData", name: "HfsPlus", downloadName: "https://github.com/acidanthera/OcBinaryData/raw/master/Drivers/HfsPlus.efi"),
    GitHubInfo(owner: "acidanthera", repo: "OcBinaryData", name: "HfsPlus32", downloadName: "https://github.com/acidanthera/OcBinaryData/raw/master/Drivers/HfsPlus32.efi"),
    GitHubInfo(owner: "acidanthera", repo: "OcBinaryData", name: "HfsPlusLegacy", downloadName: "https://github.com/acidanthera/OcBinaryData/raw/master/Drivers/HfsPlusLegacy.efi"),
    GitHubInfo(owner: "acidanthera", repo: "OcBinaryData", name: "Rts5227S", downloadName: "https://github.com/acidanthera/OcBinaryData/raw/master/Drivers/Rts5227S.efi"),
    GitHubInfo(owner: "acidanthera", repo: "OcBinaryData", name: "Rts5250", downloadName: "https://github.com/acidanthera/OcBinaryData/raw/master/Drivers/Rts5250.efi"),
    GitHubInfo(owner: "acidanthera", repo: "OcBinaryData", name: "Rts5260", downloadName: "https://github.com/acidanthera/OcBinaryData/raw/master/Drivers/Rts5260.efi"),
    GitHubInfo(owner: "acidanthera", repo: "OcBinaryData", name: "btrfs_x64", downloadName: "https://github.com/acidanthera/OcBinaryData/raw/master/Drivers/btrfs_x64.efi"),
    GitHubInfo(owner: "acidanthera", repo: "OcBinaryData", name: "ext4_x64", downloadName: "https://github.com/acidanthera/OcBinaryData/raw/master/Drivers/ext4_x64.efi")
]

func getDriverDownloadLink(_ driver: String) -> String? {
    
    let comparingName = driver.lowercased()
    if let foundDriver =  driverGitHubLinks.first(where: { $0.name.lowercased() == comparingName
    }) {
        return foundDriver.downloadName
    } else {return nil}
}
