//
//  moveAMLBinariesToStandalone.swift
//  HackinDROM
//
//  Created by lian on 07/03/2022.
//

import Foundation
func moveAMLBinariesToStandalone(_ latestOCFolder: String, _ usersAMLDir: String, progress: @escaping(String)-> ())  {
    
    let binDir = latestOCFolder +  "/Docs/AcpiSamples/Binaries"
    let standaloneAMLs =  standaloneUpdateDir + "/EFI/OC/ACPI"
    
    if let usersAML = try? fileManager.contentsOfDirectory(atPath: usersAMLDir) {
        
        for aml in usersAML {
            
            var copyingFilePath:String = ""
            if fileManager.fileExists(atPath: binDir + "/\(aml)") {
                progress("Updating \(aml)")
                copyingFilePath = binDir + "/\(aml)"
                
            } else {
                progress("Copying \(aml)")
                copyingFilePath = usersAMLDir + "/\(aml)"
            }
            
            
            do {
                try fileManager.copyItem(atPath: copyingFilePath, toPath: standaloneAMLs + "/\(aml)")
            } catch {
                print(error)
            }
        }
    }
    
}
