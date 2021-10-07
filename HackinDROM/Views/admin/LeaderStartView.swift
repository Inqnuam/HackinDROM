//
//  LeaderStartView.swift
//  HackinDROM
//
//  Created by Inqnuam 23/02/2021.
//  Copyright © 2021 HackinDROM. All rights reserved.
//

import SwiftUI

struct LeaderStartView: View {
    @EnvironmentObject var sharedData: HASharedData

    @AppStorageCompat("CurrentUser") var CurrentUser = ""
    @AppStorageCompat("UserID") var UserID = ""
    @Binding var isCharging: Bool
    @State var showingSheet = false
    @State var buildID = 0
    @State var showingIndex = 0
    var body: some View {
        VStack {

                HStack {
                    Button(action: {

                        sharedData.currentview = 0

                    }, label: {
                        if #available(OSX 11.0, *) {
                            Image(systemName: "arrow.backward")
                        } else {
                          Text("←")
                        }

                    }
                    )

                    if sharedData.ConnectedUser != "" {
                    

                        Spacer()

                        Button(action: {
                            LogoutReq { ImOut in

                                if ImOut {

                                    sharedData.ConnectedUser = ""

                                    CurrentUser = ""
                                    UserID = ""
                                    sharedData.currentview = 0
                                } else {return}
                            }

                        }, label: {

                            if #available(OSX 11.0, *) {
                                Image(systemName: "person.crop.circle.badge.xmark")

                            } else {
                                Image("person.crop.circle.badge.xmark")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 18, height: 18)

                            }

                        })
                        .toolTip("Log out")

                        Button(action: {
                            withAnimation {
                                sharedData.currentview = 6
                            }
                            // NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
                            // self.presentationMode.wrappedValue.dismiss()
                            // NSApp.hide(nil)

                        }, label: {
                            if #available(OSX 11.0, *) {
                                Image(systemName: "square.and.pencil")
                            } else {
                                Image("square.and.pencil")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 18, height: 18)
                            }

                        }
                        )
                        .toolTip("New build")

                    } else {
                        Spacer()
                    }

                }
                .padding(.leading, 15)
                .padding(.top, 18)
                .padding(.trailing, 15)
                Divider()

                if sharedData.ConnectedUser != "" {

                    NavigationView {
                        List {
                            ForEach(sharedData.AllBuilds.filter({$0.leader.localizedCaseInsensitiveContains(sharedData.ConnectedUser)}), id: \.self) { myBuild in

                            
                                if let index = sharedData.AllBuilds.firstIndex(where:{$0 == myBuild}) {
                                    NavigationLink(destination: BuildDetailView(ThisBuildConfigs: $sharedData.AllBuilds[index],showingSheet: $showingSheet, indeX: index, buildID: $buildID).onAppear {
                                        showingIndex = index
                                    }) {

                                        Text(myBuild.vendor + " " + myBuild.name)
                                           
                                    }
                                    
                                }
                            }

                        }

                    }.listStyle(SidebarListStyle())

                } else {

                    Spacer()
                    LoginView()
                    Spacer()

                }

        }
        
        .sheet(isPresented: $showingSheet) {

          VStack {
                if #available(OSX 11.0, *) {
                TextEditor(text: $sharedData.AllBuilds[showingIndex].configs[buildID].notes)
                } else {

                    TextField("Release Notes", text: $sharedData.AllBuilds[showingIndex].configs[buildID].notes)
                }
            Divider()
            HStack {
                Image(nsImage: NSImage(named: NSImage.touchBarOpenInBrowserTemplateName)!)
                TextField("link to forum", text: $sharedData.AllBuilds[showingIndex].configs[buildID].followLink)

                Spacer()
//                Text(StatusMsg)
//                    .foregroundColor(.red)
                Button("OK") {

                  if  EditReleaseNotesandLink(link: sharedData.AllBuilds[showingIndex].configs[buildID].followLink,
                                            notes: sharedData.AllBuilds[showingIndex].configs[buildID].notes,
                                            id: sharedData.AllBuilds[showingIndex].configs[buildID].id,
                                            uid: UserID) == "ok" {
                    showingSheet = false
                  //  StatusMsg = ""
                  //  presentationMode.wrappedValue.dismiss()

                  } else {

                   // StatusMsg = "Error"

                  }

                }
                .padding(.trailing, 0)

            }
        }
            .frame(width: 400, height: 450)
          .padding()
            
        }
        
        
    }
}
