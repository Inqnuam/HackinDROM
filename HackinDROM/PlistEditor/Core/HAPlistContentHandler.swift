//
//  HAPlistContentHandler.swift
//  HAPlistContentHandler
//
//  Created by lian on 18/08/2021.
//  Copyright © 2021 HackitAll. All rights reserved.
//

import Foundation
import Scout
class HAPlistContent: ObservableObject {
    
    @Published var originalPath: String = ""
    var originalContent: HAPlistStruct = HAPlistStruct()
    @Published var pContent: HAPlistStruct = HAPlistStruct()
    
    var isSaved: Bool = true
    var isTemplate:Bool = true
    
    @discardableResult
    func loadPlist(filePath: String, isTemplate:Bool)-> Bool {
        if fileManager.fileExists(atPath: filePath) {
            
            getHAPlistFrom(filePath) { plist in
                self.originalPath = filePath
                self.originalContent = plist
                self.pContent = plist
                self.isTemplate = isTemplate
               
                
                //                if let FirstDictIndex =  self.plistContent.Childs.firstIndex(where: {$0.type == "dict"}) {
                //
                //                }
                nc.post(name: Notification.Name("plistLoaded"), object: self.pContent)
                
            }
            return true
        } else {return false}
    }
    func saveplist(newPath: String? = nil)-> Bool {
        pContent.Childs.removeAll(where: {$0.name.hasPrefix("#WARNING")})
        
        do {
            var PlistExpl = PathExplorers.Plist(value: .dictionary([:]))
            try PlistExpl.add(createScoutExplValfromHDDict(hdItem: pContent))
            let readydata = try PlistExpl.get().exportData()
            try readydata.write(to: URL(fileURLWithPath: newPath ?? originalPath))
            originalContent = pContent
            
            if newPath != nil {
                originalPath = newPath!
            }
            return true
        } catch {
            print(error)
            return false
        }
    }
}
