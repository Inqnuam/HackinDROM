//
//  downloadDriver.swift
//  HackinDROM
//
//  Created by lian on 21/02/2022.
//  Copyright © 2022 Inqnuam. All rights reserved.
//

import Foundation

func downloadDriver(_ driver: String, _ cachedDriverPath: String) async -> String? {
    
    guard let link = getDriverDownloadLink(driver) else {return nil}
    guard let downloadedPath = await downloadtoHD(url: URL(string: link)!) else {return nil}
    
    if fileManager.fileExists(atPath: cachedDriverPath) {
        do {
            try fileManager.removeItem(atPath: cachedDriverPath)
        } catch {
            print(error)
        }
    }
    
    do {
        try fileManager.moveItem(atPath: downloadedPath, toPath: cachedDriverPath)
        return cachedDriverPath
    } catch {
        print(error)
        return nil
    }
  
}
