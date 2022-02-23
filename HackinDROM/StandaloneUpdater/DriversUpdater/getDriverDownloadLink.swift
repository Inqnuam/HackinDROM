//
//  getDriverDownloadLink.swift
//  HackinDROM
//
//  Created by lian on 21/02/2022.
//  Copyright © 2022 Inqnuam. All rights reserved.
//

import Foundation

func getDriverDownloadLink(_ driver: String) -> String? {
    
    
    switch driver {
        case "ExFatDxe":
            return "https://github.com/acidanthera/OcBinaryData/raw/master/Drivers/ExFatDxe.efi"
            
        case "ExFatDxeLegacy":
            return "https://github.com/acidanthera/OcBinaryData/raw/master/Drivers/ExFatDxeLegacy.efi"
            
        case "HfsPlus":
            return "https://github.com/acidanthera/OcBinaryData/raw/master/Drivers/HfsPlus.efi"
            
        case "HfsPlus32":
            return "https://github.com/acidanthera/OcBinaryData/raw/master/Drivers/HfsPlus32.efi"
            
        case "HfsPlusLegacy":
            return "https://github.com/acidanthera/OcBinaryData/raw/master/Drivers/HfsPlusLegacy.efi"
            
        case "Rts5227S":
            return "https://github.com/acidanthera/OcBinaryData/raw/master/Drivers/Rts5227S"
            
        case "Rts5250":
            return "https://github.com/acidanthera/OcBinaryData/raw/master/Drivers/Rts5250.efi"
            
        case "Rts5260":
            return "https://github.com/acidanthera/OcBinaryData/raw/master/Drivers/Rts5260.efi"
            
        case "btrfs_x64":
            return "https://github.com/acidanthera/OcBinaryData/raw/master/Drivers/btrfs_x64.efi"
            
        case "ext4_x64":
            return "https://github.com/acidanthera/OcBinaryData/raw/master/Drivers/ext4_x64.efi"
            
            
        default:
            return nil
    }
}
