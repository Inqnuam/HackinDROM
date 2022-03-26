//
//  StartView.swift
//  HackinDROM EFI
//
//  Created by Inqnuam 05/02/2021.
//  Copyright © 2021 HackinDROM. All rights reserved.
//

import SwiftUI

struct StartView: View {
    @EnvironmentObject var sharedData: HASharedData
    @AppStorageCompat("FirstOpen") var FirstOpen = true
    @State var EFIs: [EFI] = []
    @State var ExternalDisks: [ExternalDisks] = GetAllExtDisks()
    
    @State var isCharging: Bool = false
    let nvram = NVRAM()
    
    let NCJustMounted = nc.publisher(for: NSNotification.Name("JustMounted"))
    let NCJustUnmounted = nc.publisher(for: NSNotification.Name("JustUnmounted"))
    let NCExternalAdded = nc.publisher(for: NSNotification.Name("ExternalAdded"))
    let NCExternalRemoved = nc.publisher(for: NSNotification.Name("ExternalRemoved"))
    let NCMountAutomaticly =  nc.publisher(for: NSNotification.Name("MountAutomaticly"))
    
    var body: some View {
        VStack {
            
            if FirstOpen {
                if sharedData.isOnline {
                    if !sharedData.AllBuilds.isEmpty {
                        SettingsView().environmentObject(sharedData)
                    } else {
                        
                        if #available(OSX 11.0, *) {
                            ProgressView()
                            
                        } else {
                            Text("Please wait....")
                        }
                        Text("Loading Builds")
                        Button("Cancel") {
                            
                            DispatchQueue.main.async {
                                FirstOpen = false
                                
                                sharedData.currentview = 0
                                
                            }
                            
                        }
                    }
                } else {
                    //  FirstOpen.toggle()
                    ContentView(EFIs: $EFIs, isCharging: $isCharging).environmentObject(sharedData)
                }
                
            } else {
                
                if sharedData.currentview == 0 {
                    
                    ContentView(EFIs: $EFIs, isCharging: $isCharging).environmentObject(sharedData)
                } else if sharedData.currentview == 1 {
                    
                    InstallView(EFIs: $EFIs, isCharging: $isCharging).environmentObject(sharedData)
                        .transition(AnyTransition.move(edge: .trailing)).animation(.default)
                } else if sharedData.currentview == 2 {
                    
                    // ErrorView().environmentObject(sharedData)
                } else if sharedData.currentview == 3 {
                    
                    SettingsView().environmentObject(sharedData)
                        .transition(AnyTransition.move(edge: .leading)).animation(.default)
                    
                } else if sharedData.currentview == 4 {
                    
                    CreateEFI(ExternalDisksList: $ExternalDisks, isCharging: $isCharging, EFIs: $EFIs).environmentObject(sharedData)
                        .transition(AnyTransition.move(edge: .bottom)).animation(.default)
                    //.transition(.move(edge: .bottom)).animation(.default)
                    
                    
                } else if sharedData.currentview == 5 {
                    LeaderStartView(isCharging: $isCharging).environmentObject(sharedData)
                    
                } else if sharedData.currentview == 6 {
                    
                    NewBuildView(isCharging: $isCharging).environmentObject(sharedData)
                    
                    
                } else if sharedData.currentview == 10 {
                    
                    //  PlistEditorMainView().environmentObject(sharedData).openInWindow(title: "Win View", sender: self)
                    //  .transition(AnyTransition.move(edge: .top)).animation(.default)
                    
                    
                }
                
            }
            
        }
        
        .frame(minWidth: 500, maxWidth: .infinity, minHeight: 560, maxHeight: .infinity)
        
        .onReceive(NCJustMounted) { (_) in
            
            self.isCharging = true
            
            DispatchQueue.global().async {
                self.EFIs = getEFIList()
                self.isCharging = false
            }
            
        }
        
        .onReceive(NCJustUnmounted) { (output) in
            self.isCharging = true
            DispatchQueue.main.async {
                self.EFIs = getEFIList()
                self.isCharging = false
            }
            
        }
        
        .onReceive(NCExternalAdded) { (output) in
            
            DispatchQueue.main.async {
                guard let name = output.userInfo!["ExternalAdded"] else { return }
                let mounteddisk = name as! ExternalDisks
                
                ExternalDisks.append(mounteddisk)
            }
        }
        
        .onReceive(NCExternalRemoved) { (output) in
            
            DispatchQueue.main.async {
                guard let name = output.userInfo!["ExternalRemoved"] else { return }
                let mounteddisk = name as! String
                
                ExternalDisks.removeAll(where: { $0.location == "/dev/" + mounteddisk})
                
                self.EFIs.removeAll(where: {$0.parent == mounteddisk})
            }
        }
        .onReceive(NCMountAutomaticly) { (output) in
            
            guard let name = output.userInfo!["MountAutomaticly"] else { return }
            let mounteddisk = name as! String
            
            if sharedData.Mypwd == "" {
                
                sharedData.MountThisPartition[0] = mounteddisk
                nc.post(name: Notification.Name("OpenPasswordWindow"), object: nil)
                
            } else {
                
                _ =  mountEFI(UUID: mounteddisk, NAME: "", user: sharedData.whoami, pwd: sharedData.Mypwd)
                
            }
        }
        
        
    }
}
