import SwiftUI
import CoreData

import ServiceManagement
import DiskArbitration

struct ContentView: View {
    
    @EnvironmentObject var sharedData: HASharedData
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var EFIs: [EFI]
    @Binding var isCharging: Bool
    @AppStorageCompat("MyBuildID") var MyBuildID = ""
    @State var CPlist: [HAPlistStruct] = []
    @State var selectedFile = ""
    @State var query:String = ""
    @State var isDownloading:Bool = false
    var body: some View {
        
        VStack {
            HStack {
                if self.sharedData.AllBuilds.firstIndex(where: { $0.id == self.MyBuildID}) == nil && sharedData.isOnline && !sharedData.AllBuilds.isEmpty {
                    Button(action: {
                        DispatchQueue.main.async {
                            sharedData.currentview = 3
                        }
                    },
                           label: {Text("⚠️")}
                    )
                    .padding(.leading, 4)
                    Text("Select a Motherboard to receive updates")
                    
                } else {
                    Button(action: {
                        DispatchQueue.main.async {
                            sharedData.currentview = 3
                        }
                    },
                           label: {
                        if #available(OSX 11.0, *) {
                            Image(systemName: "desktopcomputer")
                        } else {
                            Image("desktopcomputer")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 18, height: 18)
                        }
                        
                    }
                    )
                    .toolTip("Settings")
                    .padding(.leading, 4)
                }
                
                if sharedData.isOnline && sharedData.ConnectedUser != "" {
                    Button(action: {
                        sharedData.currentview = 5
                    }, label: {
                        if #available(OSX 11.0, *) {
                            Image(systemName: "list.dash")
                        } else {
                            Image("list.dash")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 18, height: 18)
                        }
                    }
                    )
                    .toolTip("Manage My Builds")
                    Text("Hello \(sharedData.ConnectedUser) 😎")
                }
                
                Spacer()
                
                Button(action: {
                    isCharging = true
                    EFIs = getEFIList()
                    isCharging = false
                    
                }, label: {
                    if #available(OSX 11.0, *) {
                        Image(systemName: "arrow.clockwise.circle")
                    } else {
                        Image(nsImage: NSImage(named: NSImage.refreshTemplateName)!)
                    }
                })
                .disabled(isCharging)
                .toolTip("Refresh EFI List")
                Button(action: {
                    NSApplication.shared.terminate(self)
                }) {
                    Text("Exit")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .opacity(5)
                }
                .padding(8)
                
            }
            
            Divider()
            ScrollView {
                ForEach(EFIs.indexed(), id:\.element.id) { (idx, anEFI) in
                    ListView(EFI: anEFI, CurrentEFIIndex: idx, isCharging: $isCharging)
                    Divider()
                }
            }
            
            Spacer()
            HStack {
                Button("ℹ︎") {
                    OpenSafari("https://www.tonymacx86.com/threads/hackindrom-app-for-opencore-efi-creation-and-update.312176/")
                }
                Text("v\(sharedData.CurrentBuildVersion)")
                    .bold()
                    .padding([.top, .bottom], 8)
                    .onTapGesture(count: 5) {
                        sharedData.currentview = 5
                    }
                
                if sharedData.newAppVersion != "" {
                    if isDownloading {
                        Text("Downloading...")
                    } else {
                        Button("Download \(sharedData.newAppVersion)") {
                            isDownloading = true
                            Task {
                                if let downloadedPath = await  downloadtoHD(url: URL(string: "https://hackindrom.zapto.org/app/public/HackinDROM.dmg")!) {
                                    await shellAsync("open '\(downloadedPath)'")
                                }
                                isDownloading = false
                            }
                        }
                    }
                }
                
                if !sharedData.isOnline {
                    Text("offline")
                        .bold()
                        .foregroundColor(.red)
                }
                
                if self.isCharging {
                    HStack {
                        if #available(OSX 11.0, *) {
                            ProgressView()
                        } else {
                            Text("Working....")
                        }
                    }
                }
                Spacer()
                
                if sharedData.isOnline {
                    Button(action: {
                        sharedData.Updating = "Update"
                        sharedData.currentview = 4
                    }, label: {
                        Text("Create EFI")
                    })
                }
                
                Button("Unmount All") {
                    self.isCharging = true
                    DispatchQueue.global().async {
                        for (index, _) in EFIs.enumerated() {
                            if EFIs[index].mounted.contains("/") {
                                umount(EFIs[index].path, false)
                            }
                        }
                        self.isCharging = false
                    }
                }
            }
        }
        .padding(10)
    }
}
