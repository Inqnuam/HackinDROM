//
//  ChildsNameView.swift
//  HackinDROM
//
//  Created by Inqnuam on 06/05/2021.
//  Copyright © 2021 HackitALL. All rights reserved.
//

import SwiftUI
import Scout

struct ChildsNameView: View {
    @EnvironmentObject var sharedData: HASharedData
    @Binding var MicroChild: HAPlistStruct
    var elIndex = 0
    var customName = ""
    
    var body: some View {
        let elName = MicroChild.name
        
        if customName == "" {
            if let BundlePathIndex = MicroChild.Childs.firstIndex(where: {$0.type == "string" && $0.name == "BundlePath"}) {
                
                if MicroChild.Childs[BundlePathIndex].StringValue.localizedCaseInsensitiveContains(".kext") {
                    
                    let Pathu = URL(fileURLWithPath: MicroChild.Childs[BundlePathIndex].StringValue).lastPathComponent
                    Text(Pathu.replacingOccurrences(of: ".kext", with: ""))
                        .bold()
                        .foregroundColor(Color(.labelColor))
                } else {
                    
                    
                    Text(elName == "" ? "- Item \(elIndex)" : MicroChild.ParentName + " - " + elName)
                        .bold()
                        .foregroundColor(Color(.labelColor))
                    Text(MicroChild.name)
                        .bold()
                        .foregroundColor(Color(.labelColor))
                }
                
            } else if let AMLPath = MicroChild.Childs.firstIndex(where: {$0.type == "string" && $0.name == "Path"})  {
                
                if MicroChild.Childs[AMLPath].StringValue.localizedCaseInsensitiveContains(".aml") || MicroChild.Childs[AMLPath].StringValue.localizedCaseInsensitiveContains(".efi") {
                    
                    Text(MicroChild.Childs[AMLPath].StringValue.replacingOccurrences(of: ".aml", with: "").replacingOccurrences(of: ".efi", with: ""))
                        .bold()
                        .foregroundColor(Color(.labelColor))
                    
                } else {
                    
                    Text(elName == "" ? "- Item \(elIndex)" : MicroChild.ParentName + " - " + elName)
                        .bold()
                        .foregroundColor(Color(.labelColor))
                    Text(MicroChild.name)
                        .bold()
                        .foregroundColor(Color(.labelColor))
                }
            } else if let CommentPath = MicroChild.Childs.firstIndex(where: {$0.type == "string" && $0.name == "Comment"}) {
                
                if MicroChild.Childs[CommentPath].StringValue.removeWhitespace() != "" {
                    Text(MicroChild.Childs[CommentPath].StringValue)
                        .bold()
                        .foregroundColor(Color(.labelColor))
                } else {
                    Text("Item \(elIndex)")
                        .bold()
                        .foregroundColor(Color(.labelColor))
                }
                
            } else {
                

                Text(elName == "" ? "" : MicroChild.name)
                    .bold()
                    .foregroundColor(Color(.labelColor))
                
            }
        } else {
            Text(customName)
                .bold()
                .foregroundColor(Color(.labelColor))
            
        }
    }
    

}
