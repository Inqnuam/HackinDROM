//
//  HAPlistContentHandler.swift
//  HAPlistContentHandler
//
//  Created by lian on 18/08/2021.
//  Copyright © 2021 Golden Chopper. All rights reserved.
//

import Foundation
import Scout
class HAPlistContent: ObservableObject {
    
    @Published var originalPath: String = ""
    var originalContent: HAPlistStruct = HAPlistStruct()
    @Published var pContent: HAPlistStruct = HAPlistStruct()
    
    var isSaved: Bool = true
    var isTemplate:Bool = true
    init() {
       
    }
    
    func loadPlist(filePath: String, isTemplate:Bool) {
        if fileManager.fileExists(atPath: filePath) {
            
            getHAPlistFrom(filePath) { plist in
                self.originalPath = filePath
                self.originalContent = plist
                self.pContent = plist
                self.isTemplate = isTemplate
                print("okkkkkk")
                
//                if let FirstDictIndex =  self.plistContent.Childs.firstIndex(where: {$0.type == "dict"}) {
//
//                }
                nc.post(name: Notification.Name("plistLoaded"), object: self.pContent)
            }
            
        }
    }
    func saveplist(newPath: String? = nil) {
        pContent.Childs.removeAll(where: {$0.name.hasPrefix("#WARNING")})
        
        do {
            var PlistExpl = PathExplorers.Plist(value: .dictionary([:]))
            try PlistExpl.add(createScoutExplValfromHDDict(hdItem: pContent))
            let readydata = try PlistExpl.get().exportData()
            try readydata.write(to: URL(fileURLWithPath: newPath != nil ? newPath! : originalPath))
          originalContent = pContent
            if newPath != nil {
                originalPath = newPath!
            }
          
        } catch {
            print(error)
        }
    }
}
