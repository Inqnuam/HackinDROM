//
//  fixOCFilePathErrors.swift
//  HackinDROM
//
//  Created by lian on 27/02/2022.
//

import Foundation

func fixOCFilePathErrors() {
    if let allKextFiles = try? fileManager.contentsOfDirectory(atPath: standaloneUpdateDir + "/EFI/OC/Kexts") {
        for kext in allKextFiles {
            if kext.contains(",") || kext.contains(" ") {
                do {
                    try fileManager.moveItem(atPath: standaloneUpdateDir + "/EFI/OC/Kexts/\(kext)", toPath: standaloneUpdateDir + "/EFI/OC/Kexts/\(kext.removeWhitespace().replacingOccurrences(of: ",", with: "_"))")
                } catch {
                    print(error)
                }
            }
        }
    }
    
    
    if let allAMLFiles = try? fileManager.contentsOfDirectory(atPath: standaloneUpdateDir + "/EFI/OC/ACPI") {
        for aml in allAMLFiles {
            if aml.contains(",") || aml.contains(" ") {
                
                do {
                    try fileManager.moveItem(atPath: standaloneUpdateDir + "/EFI/OC/ACPI/\(aml)", toPath: standaloneUpdateDir + "/EFI/OC/ACPI/\(aml.removeWhitespace().replacingOccurrences(of: ",", with: "_"))")
                } catch {
                    print(error)
                }
            }
        }
    }
    
    
    if let allDriversFiles = try? fileManager.contentsOfDirectory(atPath: standaloneUpdateDir + "/EFI/OC/Drivers") {
        for driver in allDriversFiles {
            if driver.contains(",") || driver.contains(" ") {
                do {
                    try fileManager.moveItem(atPath: standaloneUpdateDir + "/EFI/OC/Drivers/\(driver)", toPath: standaloneUpdateDir + "/EFI/OC/Drivers/\(driver.removeWhitespace().replacingOccurrences(of: ",", with: "_"))")
                } catch {
                    print(error)
                }
            }
        }
    }
    
}

