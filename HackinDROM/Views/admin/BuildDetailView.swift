//
//  BuildDetailView.swift
//  HackinDROM
//
//  Created by Inqnuam 23/02/2021.
//  Copyright © 2021 HackinDROM. All rights reserved.
//

import SwiftUI


struct BuildDetailView: View {
    @EnvironmentObject var sharedData: HASharedData

  //  @Environment(\.presentationMode) private var presentationMode
    @State var ChangeName: Bool = false
    @State var NewName: String = ""
    @AppStorageCompat("UserID") var UserID = ""
    @AppStorageCompat("MyBuildID") var MyBuildID = ""
    @State var showAlert: Bool = false
    @State var DeleteingId: String = ""
    @State var DeleteingName: String = ""
    @State var DeletingIndex: Int = 900
    @State var DeletingType: String = ""
    @State var HoverOnLogo: String = ""
    @Binding var ThisBuildConfigs:AllBuilds

    @State var DeletedItems: [Int] = []
    @Binding var showingSheet:Bool
    @State var EditNotes: String = ""
    @State var EditingLink: String = ""
    var indeX: Int = 0
    @Binding var buildID: Int 
    let ClosePopoNotif = nc.publisher(for: NSNotification.Name("CloseSheet"))

    @State var selectedProductName = 120
    var body: some View {

        HStack {

            if ChangeName {
                // NewName = sharedData.AllBuilds[indeX].name
                TextField("New Name", text: $NewName)

                Button(action: {

                    let request = ChangeMyBuildName(UserID: UserID, id: ThisBuildConfigs.id, name: NewName)

                    if request != "nul" {
                        sharedData.AllBuilds[indeX].name = request
                        ThisBuildConfigs.name = request
                        ChangeName = false

                    } else {

                        ChangeName = false
                    }

                }, label: {

                  //  Text("􀏋")
                    if #available(OSX 11.0, *) {
                    Image(systemName: "checkmark.rectangle")
                    } else {
                        Text("OK")
                    }
                    
                }
                )
                .toolTip("Confirme")

                Button(action: {
                    ChangeName = false
                }, label: {

                    
                    
                    if #available(OSX 11.0, *) {
                    Image(systemName: "xmark.rectangle.fill")
                    } else {
                        Text("X")
                    }

                }
                )
                .toolTip("Cancel")

            } else {

                HStack {
                    Text(ThisBuildConfigs.vendor + " " + ThisBuildConfigs.name)
                        .foregroundColor(ThisBuildConfigs.active ? .primary : .red)
                        .blur(radius: ThisBuildConfigs.active ? 0.0 : 2.0)
                        .contextMenu {
                            Button(action: {
                                NewName = sharedData.AllBuilds[indeX].name
                                ChangeName = true
                            }, label: {
                                Text("Rename")
                            }
                            )

                            Button(action: {
                                ThisBuildConfigs.active.toggle()
                                activate(id: ThisBuildConfigs.id, active: ThisBuildConfigs.active, type: "builds")

                               // sharedData.AllBuilds[indeX].active = req
                            }) {
                                Text(ThisBuildConfigs.active ? "Disable" : "Enable")
                            }

                            Button(action: {

                                DeleteingId = ThisBuildConfigs.id
                                DeleteingName = ThisBuildConfigs.name
                                DeletingIndex = 100
                                DeletingType = "builds"
                                showAlert = true

                                // delete item in items array
                            }) {
                                Text("Delete")
                            }

                        }
                    // .font(.title2)
                    Spacer()

                    Picker(selection: $selectedProductName.pickerChanged(SetNewSPN), label: Text("")) {
                        ForEach(0 ..< Macs.count) {
                            Text("\(Macs[$0])")
                        }
                    }
                    .frame(width: 138)
                }
                .padding(.leading, 5)
                .padding(.trailing, 10)

            }

        }

        // .padding(5)
        Divider()
        List {
            ForEach(ThisBuildConfigs.configs.indices, id: \.self) { build in
                if !DeletedItems.contains(build) {
                    let TheBuild = ThisBuildConfigs.configs[build]

                    let  isLatest = ThisBuildConfigs.latest.id == ThisBuildConfigs.configs[build].id
                    HStack {
                        if isLatest {
                            ZStack {
                                Image("OCLogo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 10, height: 10)
                            }
                            .toolTip("Latest")

                        } else {

                            ZStack {
                                Image("OCLogo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)

                                if  HoverOnLogo == TheBuild.id {

                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 40, height: 40)
                                    Circle()
                                        .fill(Color.black)
                                        .frame(width: 15, height: 15)
                                }
                            }.toolTip("Set as Latest release")

                            .onHover { inside  in
                                if inside && TheBuild.active {

                                    self.HoverOnLogo = TheBuild.id
                                } else {
                                    self.HoverOnLogo = ""
                                }
                            }

                            .onTapGesture {

                                if SetLatest(bid: ThisBuildConfigs.id, lid: ThisBuildConfigs.configs[build].id, uid: UserID) == "ok" {

                                    ThisBuildConfigs.latest.id = ThisBuildConfigs.configs[build].id
                                    sharedData.AllBuilds[indeX].latest = ThisBuildConfigs.configs[build]

                                    if MyBuildID == TheBuild.id {

                                        if self.sharedData.AllBuilds.firstIndex(where: { $0.id == self.MyBuildID}) != nil {

                                            self.sharedData.OCv = self.sharedData.AllBuilds[indeX].latest.ocvs
                                            self.sharedData.CaseyLastestOCArchive = self.sharedData.AllBuilds[indeX].latest.Archive
                                        }

                                    }

                                }

                            }
                            .disabled(!TheBuild.active)
                        }

                        Text(TheBuild.ocvs)
                            .onTapGesture {
                                if !TheBuild.followLink.isEmpty {

                                    OpenSafari(TheBuild.followLink)

                                }

                            }

                        if #available(OSX 11.0, *) {
                            Toggle("", isOn: $ThisBuildConfigs.configs[build].active.toggled(build, "", ToggledToActivate))
                                .toggleStyle(SwitchToggleStyle(tint: .green))
                                .labelsHidden()
                                .disabled(isLatest)
                                .padding(.leading, 10)
                                .help(ThisBuildConfigs.configs[build].active ? "Disable" : "Enable") // crash on delete
                            
                            Button(action: {
                                buildID = build
                                showingSheet = true
                                
                            }, label: {
                             //   Text("􀅳")
                                Image(systemName: "info")
                                
                            })
                            
                        } else {
                            
                            HDToggleView(isOn: $ThisBuildConfigs.configs[build].active.toggled(build, "", ToggledToActivate), disabled: isLatest)
                                .padding(.leading, 10)
                            Button(action: {
                                buildID = build
                                showingSheet = true
                                
                            }, label: {
                                Text("ℹ️")
                                
                            })
                        }
                        
                        
                        //   .toolTip("Release Notes") //

                        // Toggle("⚠️", isOn: $ThisBuildConfigs.configs[build].warning)

                        if #available(OSX 11.0, *) {
                            Image(systemName: "exclamationmark.square.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundColor(ThisBuildConfigs.configs[build].warning ? .yellow : .primary)
                                //  ThisBuildConfigs.configs[build].warning
                                .help("Warning!")
                                .onTapGesture {
                                    ThisBuildConfigs.configs[build].warning.toggle()
                                    warning(id: TheBuild.id, warning: TheBuild.warning)

                                    sharedData.AllBuilds[indeX].configs[build].warning.toggle()

                                    // openURL(URL(string: "https://hackindrom.zapto.org/app/public/uploads/\(TheBuild.Archive)")!)
                                }
                        } else {
                            Image("exclamationmark.square.fill")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundColor(ThisBuildConfigs.configs[build].warning ? .yellow : .primary)
                                //  ThisBuildConfigs.configs[build].warning
                                .toolTip("Warning!")
                                .onTapGesture {
                                    ThisBuildConfigs.configs[build].warning.toggle()
                                    warning(id: TheBuild.id, warning: TheBuild.warning)

                                    sharedData.AllBuilds[indeX].configs[build].warning.toggle()

                                    // openURL(URL(string: "https://hackindrom.zapto.org/app/public/uploads/\(TheBuild.Archive)")!)
                                }
                        }

                        if #available(OSX 11.0, *) {
                            Image(systemName: "icloud.and.arrow.down.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .toolTip("Download archive")
                                .onTapGesture {

                                    OpenSafari("https://hackindrom.zapto.org/app/public/uploads/\(TheBuild.Archive)")
                                }
                        } else {
                            Text("☁️")
                                .font(.system(size: 20))
                                .toolTip("Download archive")
                                .onTapGesture {

                                    OpenSafari("https://hackindrom.zapto.org/app/public/uploads/\(TheBuild.Archive)")
                                }
                        }

                        if #available(OSX 11.0, *) {
                            Image(systemName: "trash")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.red)
                                .padding(.trailing, 15)
                                .opacity(isLatest || TheBuild.active ? 0.0 : 1.0)
                                .help("Delete definitely")
                                .onTapGesture {
                                    DeleteingId = TheBuild.id
                                    DeleteingName = "OpenCore \(String(format: "%.2f", TheBuild.ocv)  )"
                                    DeletingIndex = build
                                    DeletingType = "configs"
                                    showAlert = true
                                }
                                .disabled(isLatest || TheBuild.active)
                        } else {
                            Image("trash")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.red)
                                .padding(.trailing, 15)
                                .opacity(isLatest || TheBuild.active ? 0.0 : 1.0)
                                .toolTip("Delete definitely")
                                .onTapGesture {
                                    DeleteingId = TheBuild.id
                                    DeleteingName = "OpenCore \(String(format: "%.2f", TheBuild.ocv)  )"
                                    DeletingIndex = build
                                    DeletingType = "configs"
                                    showAlert = true
                                }
                                .disabled(isLatest || TheBuild.active)
                        }

                    }

                }
            }

        }

        .onReceive(ClosePopoNotif) { (_) in
            if showingSheet {

               // showingSheet = false
            }

        }

        .onAppear {
            // DispatchQueue.main.async{
            ThisBuildConfigs = sharedData.AllBuilds[indeX]

            if let index = Macs.firstIndex(where: { $0 == ThisBuildConfigs.SPN}) {
                selectedProductName = index

            }
            // }
        }


        .alert(isPresented: $showAlert) {
            let primaryButton = Alert.Button.cancel(Text("Cancel")) {
                showAlert = false
            }

            let secondaryButton = Alert.Button.destructive(Text("Delete!")) {

                if delete(id: DeleteingId, type: DeletingType, uid: UserID) == "ok" {
                    if DeletingType == "configs" {
                        DeletedItems.append(DeletingIndex)
                    } else {
                        self.sharedData.AllBuilds.removeAll(where: {$0.id == DeleteingId})
                        sharedData.currentview = 0
                    }
                    if DeletedItems.contains(DeletingIndex) {
                        self.sharedData.AllBuilds[indeX].configs.removeAll {
                            $0.id == ThisBuildConfigs.configs[DeletingIndex].id

                        }

                    }
                }
            }
            return Alert(title: Text("Ooooohhh"),
                         message: Text("Are you sure you want to permanently remove \(DeleteingName) from the database ?"),
                         primaryButton: primaryButton,
                         secondaryButton: secondaryButton
            )
        }

    }
    func SetNewSPN(to value: Int) {

        if   ChangeSPN(UserID: UserID, id: ThisBuildConfigs.id, name: Macs[value]) == "ok" {

            ThisBuildConfigs.SPN = Macs[value]
            sharedData.AllBuilds[indeX].SPN = Macs[value]
        }

    }

    func ToggledToActivate( to value: ToggleChanged) {
        activate(id: ThisBuildConfigs.configs[value.which].id, active: !value.yes, type: "configs")
    }

}
