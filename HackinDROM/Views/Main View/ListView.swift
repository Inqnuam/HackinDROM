//
//  ListView.swift
//  HackinDROM
//
//  Created by Inqnuam 11/04/2021.
//  Copyright © 2021 HackinDROM. All rights reserved.
//

import Foundation
import SwiftUI
import Version
struct ListView: View {
    
    var EFI: EFI
    var CurrentEFIIndex: Int
    @Binding var isCharging: Bool
    @EnvironmentObject var sharedData: HASharedData
    @State var HoverOnUpdate: Bool = false
    @State var HoverOnMount: Bool = false
    @State var hovered: Bool = false
    
    @AppStorageCompat("MyBuildID") var MyBuildID = ""
    @AppStorageCompat("GPU") var GPU = 0
    @AppStorageCompat("Wifi") var Wifi = 0
    @State var isShowingPopover:Bool = false
    @AppStorageCompat("BackUpsCustomFolder") var BackUpsCustomFolder = ""
    @AppStorageCompat("BackUpToFolder") var BackUpsToFolder = false
    @State var isUpdating:Bool = false
    @State var updatingColor: Color = .green
    @State var updatingPosition:Double = 0.0
    var body: some View {
        
        let ismounted = EFI.mounted.contains("/")
        ZStack(alignment: .leading) {
            HStack {
                VStack {
                    if #available(OSX 11.0, *) {
                        let imageName: String = {
                            if EFI.Name == "Apple Disk Image" {
                                
                                return "externaldrive.badge.timemachine"
                            } else {
                                
                                if EFI.Where == "External" {
                                    
                                    return "externaldrive"
                                } else {
                                    return "internaldrive"
                                }
                            }
                            
                        }()
                        Image(systemName: imageName)
                            .resizable()
                            .foregroundColor(ismounted ? Color("MountedNameDisk") : .primary )
                            .frame(width: 32.0, height: 32.0)
                            .opacity(hovered ? 1 : 0.9)
                        
                    } else {
                        let imageName: String = {
                            if EFI.Name == "Apple Disk Image" {
                                
                                return "timemachine"
                            } else {
                                
                                if EFI.Where == "External" {
                                    
                                    return "externaldrive"
                                } else {
                                    return "internaldrive"
                                }
                            }
                            
                        }()
                        
                        Image(imageName)
                            .resizable()
                            .foregroundColor(ismounted ? Color("MountedNameDisk") : .primary )
                            .frame(width: 32.0, height: 32.0)
                            .opacity(hovered ? 1 : 0.9)
                        
                    }
                    Text(EFI.Where)
                    if EFI.OC && EFI.OCv != "0.0.0" {
                        
                        Text("OC \(EFI.OCv)")
                        
                    } else if EFI.OC && EFI.OCv == "0.0.0" {
                        if sharedData.isOnline {
                            
                            Text("OC Beta?")
                        }
                        
                    } else {
                        if EFI.Where == "External" {
                            
                            Button("Eject") {
                                DispatchQueue.global().async {
                                    isCharging = true
                                    
                                    shell("diskutil eject /dev/\(EFI.Parent)") {_, _ in
                                        
                                        isCharging = false
                                    }
                                }
                            }
                        }
                        
                    }
                    
                }
                
                .onTapGesture {
                    if ismounted {
                        
                        NSWorkspace.shared.open(URL(fileURLWithPath: EFI.mounted, isDirectory: true))
                    }
                    
                }
                VStack(alignment: .leading) {
                    
                    Text(EFI.SSD)
                        .bold()
                    // .foregroundColor(ismounted ? Color("MountedNameDisk") : .primary )
                    // .padding(1)
                    // .background(LinearGradient(gradient: Gradient(colors: [Color.red, Color.orange]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(7.0)
                        .opacity(hovered ? 1 : 0.9)
                        .disabled(!ismounted)
                    
                    Text(EFI.Name)
                    
                    HStack {
                        Text(EFI.location)
                            .underline(true, color: Color(.systemBrown).opacity(0.1))
                            .opacity(hovered ? 1 : 0.9)
                        Text("|")
                        Text(EFI.type)
                            .opacity(hovered ? 1 : 0.9)
                    }
                    Text(EFI.mounted.replacingOccurrences(of: "/Volumes/", with: "" ))
                        .foregroundColor(Color("CustomEFIName"))
                        .opacity(hovered ? 1 : 0.9)
                    
                }
                .contentShape(Rectangle())
                .contextMenu(menuItems: {
                    
                    
//                    if ismounted {
//                        ForEach(EFI.plists, id:\.self) { plist in
//
//                            Button("Edit \(plist)") {
//                                sharedData.ocTemplateName = ""
//                                sharedData.savingFilePath = "\(EFI.mounted)/EFI/OC/\(plist)"
//                                sharedData.currentview = 10
//                            }
//                        }
//                        Button(isUpdating ? "Cancel" : "Update") {
//                            withAnimation {
//                            isUpdating.toggle()
//                            }
//                        }
//                    }
                    
                })
                .onTapGesture {
                    
                    if ismounted {
                        shell("open '\(EFI.mounted)'") {_, _ in}
                    }
                    
                }
                .padding()
                
                Spacer()
                
                if ismounted {
                    VStack(alignment: .trailing) {
                        
                        if EFI.OC {
                            Button(action: {
                                isCharging = true
                                DispatchQueue.global().async {
                                    
                                    MakeReportZIP(EFI.mounted + "/EFI", EFI.OCv, Kexts: sharedData.RunningKexts, OpenCoreV: MyHackData.OCV, BootArgs: MyHackData.BootArgs)
                                    isCharging = false
                                }
                                
                            }, label: {
                                if #available(OSX 11.0, *) {
                                    Image(systemName: "archivebox.circle.fill")
                                    
                                } else {
                                    Image("archivebox.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 18, height: 18)
                                    
                                }
                            })
                                .toolTip("Create a report Archive")
                            
                        }
                        Text("Unmount")
                        // .bold()
                        
                            .foregroundColor(HoverOnMount ? Color("MntBtn1") : Color("MntBtn2"))
                        
                            .padding(4)
                        
                            .background(LinearGradient(gradient: Gradient(colors: [Color.red, Color.orange]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(15.0)
                            .contentShape(Rectangle())
                            .opacity(hovered ? 1 : 0.9)
                            .onTapGesture {
                                self.isCharging = true
                                umount(EFI.location, false)
                                
                                // sharedData.EFIs[index].mounted = ""
                                
                            }
                            .contextMenu(menuItems: {
                                Button("Force unmount") {
                                    umount(EFI.location, true)
                                }
                                
                            })
                            .onHover { inside in
                                if inside {
                                    self.HoverOnMount = true
                                } else {
                                    self.HoverOnMount = false
                                }
                            }
                        let FoundIndeX = sharedData.AllBuilds.firstIndex(where: { $0.id == self.MyBuildID})
                        
                        if FoundIndeX != nil && sharedData.isOnline {
                            
                            
                            let requiredSpace = CalculateRequierdSpace(EFI.BackUpSize, sharedData.AllBuilds[FoundIndeX!].latest.size)
                            if EFI.FreeSpace > requiredSpace {
                                if EFI.OC {
                                    
                                    if sharedData.OCv == EFI.OCv {
                                        Button(action: {
                                            self.sharedData.CurrentEFI = CurrentEFIIndex
                                            self.sharedData.Updating =  "Update"
                                            sharedData.currentview = 1
                                            
                                        }, label: {
                                            
                                            Text("Reinstall OC")
                                                .foregroundColor(HoverOnUpdate ? Color("MntBtn1") : Color("MntBtn2") )
                                                .toolTip("No new update available for your system")
                                            
                                        })
                                        
                                    } else if Version(sharedData.OCv)! > Version(EFI.OCv)! && EFI.OCv != "0.0.0" {
                                        
                                        Button(action: {
                                            self.sharedData.CurrentEFI = CurrentEFIIndex
                                            self.sharedData.Updating =  "Update"
                                            sharedData.currentview = 1
                                            
                                        }, label: {
                                            Text("Update to \(sharedData.OCv )")
                                                .foregroundColor(HoverOnUpdate ? Color("MntBtn1") : Color("MntBtn2") )
                                        })
                                        
                                    } else {
                                        Text("Up to date")
                                    }
                                    
                                } else {
                                    
                                    Button(action: {
                                        self.sharedData.CurrentEFI = CurrentEFIIndex
                                        self.sharedData.Updating = "Install OC"
                                        sharedData.currentview =  4
                                        
                                        //    NSApp.sendAction(#selector(AppDelegate.openPreferencesWindow), to: nil, from:nil)
                                        
                                    },
                                           label: {
                                        
                                        Text("Install OC")
                                        
                                    }
                                           
                                    )
                                    
                                }
                            } else {
                                
                                
                                Button("⛔️ OpenCore requires \(ConvertToMB(requiredSpace))") {
                                    isShowingPopover.toggle()
                                } .buttonStyle(PlainButtonStyle())
                                
                                    .popover(isPresented: $isShowingPopover) {
                                        
                                        VStack {
                                            Text("Update process cannot begin because there is not enough space in the EFI partition to backup your current EFI folder and install the new one. Free up space by deleting unnecessary items from the EFI partition (including EFI/APPLE folder if present), then click Refresh button. And/Or select a custom backup folder on another drive:")
                                            Button("Select backup folder") {
                                                
                                                let SelectAFolder = FileSelector(allowedFileTypes: ["zip"], canCreateDirectories: true, canChooseFiles: false, canChooseDirectories: true)
                                                if SelectAFolder != "nul" {
                                                    BackUpsCustomFolder = SelectAFolder
                                                    BackUpsToFolder = true
                                                } else {
                                                    BackUpsToFolder = false
                                                }
                                            }
                                            
                                        }
                                        .frame(width: 400)
                                        .padding(8)
                                    }
                            }
                        }
                        
                    }
                    
                } else {
                    VStack {
                        Spacer()
                        Text("Mount")
                        
                            .foregroundColor(HoverOnMount ? Color("MntBtn1") : Color("MntBtn2"))
                        //  .padding(.top, 4)
                        // .padding(.leading, 4)
                            .padding(4)
                            .background(LinearGradient(gradient: Gradient(colors: [Color.red, Color.orange]), startPoint: .trailing, endPoint: .leading))
                            .cornerRadius(15.0)
                        
                        Spacer()
                        
                    }
                    .contentShape(Rectangle())
                    .onHover { inside in
                        if inside {
                            self.HoverOnMount = true
                        } else {
                            self.HoverOnMount = false
                        }
                    }
                    .onTapGesture {
                        
                        self.isCharging = true
                        
                        if mountEFI(UUID: EFI.location, NAME: EFI.Name, user: sharedData.whoami, pwd: sharedData.Mypwd) == "nul" {
                            
                            self.isCharging = false
                            
                        }
                       
                        self.isCharging = false
                        
                    }
                }
                
            }
            .onHover { inside in
                if inside {
                    hovered = true
                    
                } else {
                    hovered = false
                }
            }
//            if isUpdating {
//                HDUpdateView(isUpdating: $isUpdating, updatingPosition: $updatingPosition, updatingColor: $updatingColor)
//            }
           
        }
        
    }
    
}

