//
//  getFilesFrom.swift
//  HackinDROM
//
//  Created by lian on 24/02/2022.
//  Copyright © 2022 Inqnuam. All rights reserved.
//

import Foundation
func getFilesFrom(_ dir: String, _ ext: String? = nil )-> [String]? {
    
    do {
        
        let FindKexts = try fileManager.contentsOfDirectory(at: URL(fileURLWithPath: dir), includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
        
        let kexts = ext == nil ? FindKexts : FindKexts.filter { $0.pathExtension == ext }
        let kextNames = kexts.map { $0.deletingPathExtension().lastPathComponent }
        
   
        return kextNames
        
    } catch {
        print(error)
        return nil
    }
}
