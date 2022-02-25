//
//  getOCVersionFromCache.swift
//  HackinDROM
//
//  Created by lian on 24/02/2022.
//  Copyright © 2022 Inqnuam. All rights reserved.
//

import Foundation

func getOCVersionFromCache(_ dir: String)-> String? {
    
    do {
        
        var foundFiles = try fileManager.contentsOfDirectory(atPath: dir)
        
      
        foundFiles = foundFiles.filter({!$0.hasPrefix(".")})
   
        if !foundFiles.isEmpty {
            return foundFiles.first!
        } else {
            return nil
        }
       
        
    } catch {
        print(error)
        return nil
    }
}
