//
//  DortaniaJSON.swift
//  HackinDROM
//
//  Created by Inqnuam on 14/07/2021.
//  Copyright © 2021 HackitALL. All rights reserved.
//

import Foundation
import Scout
import Version

func getDortConf() async throws -> [DortaniaJSON] {
    var allKexts: [DortaniaJSON] = []
    
    
    do {
        let path = await downloadtoHD(url: URL(string: "https://raw.githubusercontent.com/dortania/build-repo/builds/config.json")!)
        guard let path = path else { return [] }
        
        let data = fileManager.contents(atPath: path)!
        
        let json = try PathExplorers.Json(data: data)
        
        
        let keyList =  try json.get(.keysList).array(of: String.self)
        
        for k in keyList {
            var element = DortaniaJSON()
            
            element.name = k
            do {
                element.type = try json.get([k, "type"]).string!
            } catch {
                print(error)
            }
            do {
                element.versions = try json.get([k, "versions"]).array(of: DortaniaJSONVersions.self)
            }
            catch {
                print(error)
            }
            
            allKexts.append(element)
        }
        
        
    } catch {
        print(error)
    }
    
    
    return allKexts
    
}


struct DortaniaJSON: Codable, ExplorerValueCreatable {
    var name: String = ""
    var type: String = ""
    var versions: [DortaniaJSONVersions] = []
}


struct DortaniaJSONVersions: Codable, ExplorerValueCreatable {
    var version: String = ""
    var links: DortaniaJSONLinks = DortaniaJSONLinks()
    var date_authored: String = ""
    var date_built: String = ""
    var date_committed: String = ""
}


struct DortaniaJSONLinks: Codable, ExplorerValueCreatable {
    var release: String = ""
}


