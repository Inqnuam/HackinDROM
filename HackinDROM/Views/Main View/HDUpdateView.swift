//
//  HDUpdateView.swift
//  HDUpdateView
//
//  Created by Inqnuam on 09/08/2021.
//  Copyright © 2021 HackitALL. All rights reserved.
//
extension String: Identifiable {
    public typealias ID = Int
    public var id: Int {
        return hash
    }
}


import SwiftUI
import Version

var latestOCFolder: String = ""
struct HDUpdateView: View {
    
    @Binding var EFI: EFI
    @State var updatingColor: Color = .green
    @State var sheetIsPresented: GitHubJSON?
    @State var ocvalidateOutput:String?
    @State var copyableOCVoutput: String = ""
    
    var body: some View {
        HStack {
            Color.red
                .opacity(0.0)
            
        }
        .background(Color(.black).opacity(0.5))
        .contextMenu(menuItems: {
            Button("Cancel") {
                cleanDir("\(tmp)/tmp/")
                withAnimation {
                    EFI.isUpdating = false
                }
            }
        })
        .sheet(item: $sheetIsPresented, content: { data in
            
            VStack {
                Text("Please select the appropriate kext")
                    .font(.title)
                    .padding()
                List(data.assets) { kext in
                    if !kext.name.hasPrefix("itlwm") {
                        Button(kext.name) {
                            
                            Task {
                                await updateAirportItlwm(kext.browser_download_url)
                            }
                            
                            sheetIsPresented = nil
                        }
                    }
                    
                    
                }
            }.frame(width: 400, height: 500)
            
        })
        
        
        
        .sheet(item: $ocvalidateOutput) { data in
            
            
            VStack {
                VStack {
                    Text("config.plist validation error:")
                        .font(.title)
                    
                    Divider()
                    if #available(macOS 11.0, *) {
                        TextEditor(text: $copyableOCVoutput)
                    } else {
                        Text(data)
                    }
                    
                    HStack {
                        
                        Button("Cancel") {
                            cleanDir("\(tmp)/tmp/")
                            EFI.isUpdating = false
                        }
                        .foregroundColor(.red)
                        Spacer()
                        Button("Save to ...") {
                            
                            let selectedPath = FileSelector(allowedFileTypes: [], canCreateDirectories: true, canChooseFiles: false, canChooseDirectories: true, customTitle: "Custom folder")
                            
                            if !selectedPath.isEmpty && selectedPath != "nul" {
                                
                                ocvalidateOutput = nil
                                Task {
                                    await moveStandaloneToEFI(selectedPath)
                                    
                                }
                            }
                            
                            print("Save toooooo")
                        }
                        
                        Button("Update anyway") {
                            ocvalidateOutput = nil
                            Task {
                                await moveStandaloneToEFI()
                                
                            }
                        }
                        .foregroundColor(.blue)
                    }
                }.padding()
            }.frame(width: 400, height: 500)
            
        }
        HStack {
            Color.red
                .opacity(0.0)
            
        }.frame(width: CGFloat(EFI.updateProgress) * 480)
            .background(updatingColor.opacity(0.6))
            .contextMenu(menuItems: {
                Button("Cancel") {
                    withAnimation {
                        EFI.isUpdating = false
                    }
                    
                }
            })
            .onAppear{
                
                Task {
                    await  updateTask()
                }
            }
            .onDisappear{
                
                EFI.isUpdating = false
                EFI.updateProgress = 0.0
                
                let allEFIs = getEFIList()
                if let foundEFI = allEFIs.first(where: {$0.mounted == EFI.mounted}) {
                    EFI = foundEFI
                    
                }
                
            }
        
        
        if #available(macOS 11.0, *) {
            ProgressView()
        }
        
        
        
    }
    
    func setProgress(_ val: Double) {
        withAnimation {
            EFI.updateProgress = val
        }
    }
    
    
    // This should be final func if we have to handle AirportItlwm.kext
    func updateAirportItlwm(_ link: String) async {
        
        guard let downloadedPath = await downloadtoHD(url: URL(string: link)!) else {
            do {
                try fileManager.copyItem(atPath: EFI.mounted + "/EFI/OC/Kexts/AirportItlwm.kext" , toPath: standaloneUpdateDir + "/EFI/OC/Kexts/AirportItlwm.kext")
            } catch {
                print(error)
            }
            
            // finish update then
            await finishUpdate()
            return
            
        }
        
        // as theres multiple kexts with the same AirportItlwm.kext name for different macOS version we are not going to cache it
        // and everytime we have to ask to the user which version to download
        
        // #FIXME open a request to the dev to ask to include macOS target version into plist
        
        let temporaryKextPath = tmp + "/tmp/AirportItlwm.kext"
        if fileManager.fileExists(atPath: temporaryKextPath) {
            do {
                try fileManager.removeItem(atPath: temporaryKextPath)
            } catch {
                print(error)
            }
        }
        
        await asyncUnzip(from: downloadedPath, to: temporaryKextPath)
        if fileManager.fileExists(atPath: downloadedPath) {
            do {
                try fileManager.removeItem(atPath: downloadedPath)
            } catch {
                print(error)
            }
        }
        do {
            try fileManager.copyItem(atPath: temporaryKextPath, toPath: standaloneUpdateDir + "/EFI/OC/Kexts/AirportItlwm.kext")
        } catch {
            print(error)
            
            // if error copy from users EFI
            
            do {
                try fileManager.copyItem(atPath: EFI.mounted + "/EFI/OC/Kexts/AirportItlwm.kext" , toPath: standaloneUpdateDir + "/EFI/OC/Kexts/AirportItlwm.kext")
            } catch {
                print(error)
            }
        }
        
        do {
            try fileManager.removeItem(atPath: temporaryKextPath)
        } catch {
            print(error)
        }
        await finishUpdate()
        
    }
    
    
    func updateTask() async {
        // check and clean standalone updater working directory
        checkAndCleanStandaloneDir()
        setProgress(0.1)
        
        if  let foundPath = await getLatestOCPath() {
            latestOCFolder = foundPath
            setProgress(0.2)
            // Copy latest OC EFI into standalone dir.
            
            do {
                try fileManager.copyItem(atPath: latestOCFolder + "/X64/EFI/", toPath: standaloneUpdateDir + "/EFI/")
                setProgress(0.3)
                moveAMLBinariesToStandalone(latestOCFolder, EFI.mounted + "/EFI/OC/ACPI")
                setProgress(0.4)
                standaloneToolsUpdater(EFI.mounted + "/EFI/OC/Tools")
                setProgress(0.5)
            }
            catch {
                print("Can't Update OpenCore ")
                print(error)
            }
            
            let kextDir = EFI.mounted + "/EFI/OC/Kexts/"
            var shouldUpdateAirportItlwm = false
            
            var stableRelease: GitHubJSON?
            
            if var userKexts = getFilesFrom(kextDir) {
                
                // Check if user use OpenInelWirelss WiFi
                if let foundIndex = userKexts.firstIndex(where: {$0 == "AirportItlwm"}) {
                    shouldUpdateAirportItlwm = true
                    
                    // remove to avoid trying to find in standaloneUpdateKexts loop
                    userKexts.remove(at: foundIndex)
                }
                
                if shouldUpdateAirportItlwm || userKexts.firstIndex(where: {$0 == "itlwm"}) != nil {
                    if  let releases =  await  getRepoDataFromGhAPI("OpenIntelWireless", "itlwm") {
                        
                        stableRelease = releases.first(where: {!$0.prerelease})
                    }
                }
                
                standaloneUpdateResources(EFI.mounted + "/EFI/OC/Resources")
                
                // Update every kext but AirportItlm
                if await standaloneUpdateKexts(kextDir, userKexts, stableRelease) {
                    print("Kexts finished updateing")
                    setProgress(0.9)
                }
                
            }
            else {
                // remove all kexts if users dont uses any kext
                cleanDir(kextDir)
            }
            
            await standaloneUpdateDrivers(EFI.mounted + "/EFI/OC/Drivers")
            copyMissingFiles(from: EFI.mounted + "/EFI", to: standaloneUpdateDir + "/EFI")
            copyMissingFiles(from: EFI.mounted + "/EFI/BOOT", to: standaloneUpdateDir + "/EFI/BOOT")
            copyMissingFiles(from: EFI.mounted + "/EFI/OC", to: standaloneUpdateDir + "/EFI/OC")
            
            
            
            // Show options to select correct kext for AirportItlwm
            if shouldUpdateAirportItlwm {
                sheetIsPresented = stableRelease
                
            } else {
                // finish update
                await finishUpdate()
            }
            
        } else {
            print("Can't update :( ")
            EFI.isUpdating = false
            EFI.updateProgress = 0.0
        }
        
        
    }
    
    
    func finishUpdate() async {
        // remove config.plist and Config.plist
        // config.plist will be generated later
        // get correct C/c/onfig.plist path for update process
        var configPlistPath: String = ""
        let sampleConfigPlistPath: String = latestOCFolder + "/Docs/SampleCustom.plist"
        if fileManager.fileExists(atPath: EFI.mounted + "/EFI/OC/config.plist") {
            configPlistPath = EFI.mounted + "/EFI/OC/config.plist"
        } else if fileManager.fileExists(atPath: EFI.mounted + "/EFI/OC/Config.plist") {
            configPlistPath = EFI.mounted + "/EFI/OC/Config.plist"
        }
        
        let usersConfigPlist = HAPlistContent()
        usersConfigPlist.loadPlist(filePath: configPlistPath, isTemplate: false)
        
        let sampleConfigPlist = HAPlistContent()
        sampleConfigPlist.loadPlist(filePath: sampleConfigPlistPath, isTemplate: true)
        
        let updatedPlist =  updateOCPlist(sampleConfigPlist.originalContent, usersConfigPlist.originalContent)
        
        sampleConfigPlist.pContent = additionalOCFixes(fixingPlist: updatedPlist, refPlist: usersConfigPlist.originalContent)
        let savedPath = standaloneUpdateDir + "/EFI/OC/config.plist"
        if sampleConfigPlist.saveplist(newPath: savedPath) {
            let ocvalidatePath = latestOCFolder + "/Utilities/ocvalidate/ocvalidate"
            let output = await shellAsync(" '\(ocvalidatePath)' '\(savedPath)'")
            
            
            if output.contains("No issues found.") {
                await moveStandaloneToEFI()
            } else {
                
                // show output and aks for action
                // 'update anyway', 'cancel', 'save at'
                copyableOCVoutput = output
                ocvalidateOutput = output
                
            }
            
        }
    }
    
    
    func moveStandaloneToEFI(_ customDir: String? = nil) async {
        let savingPath:String = customDir ?? EFI.mounted
        var canBackUp:Bool = false
        var canUpdate:Bool = customDir == nil ? false : true // will be computed later
        var archiveSize:Double = 0.0
        var backedUpPath: String?
        
        
        if fileManager.fileExists(atPath: savingPath + "/EFI") {
            let (archivePath, generatedSize) = await asyncZip(savingPath + "/EFI",  randomizeName: true)
            
            archiveSize = generatedSize
            backedUpPath = archivePath
            if !fileManager.fileExists(atPath: savingPath + "/OLD_EFI.zip") {
                // rename generated archive name to OLD_EFI
                if let renamedPath =   renameFile(backedUpPath!, newName: "OLD_EFI.zip", overwrite: true) {
                    backedUpPath = renamedPath
                }
            }
        }
        
        
        
        if customDir == nil {
            
            let (rcanBackup, rcanUpdate) = await calculateRequiredSpaces(archiveSize: archiveSize)
            
            canBackUp = rcanBackup
            canUpdate = rcanUpdate
            
            if canUpdate {
                do {
                    try fileManager.removeItem(atPath: savingPath + "/EFI")
                } catch {
                    print(error)
                }
            }
        }
        
        
        
        if backedUpPath != nil {
            backupEFI(backedUpPath: backedUpPath!, canBackUp:canBackUp, savingPath: savingPath)
        }
        
        
        if let savedPath =  updateEFI(canUpdate: canUpdate, savingPath:savingPath + "/EFI") {
            
            // Notify about savedPath and close HDUpdateview
            setProgress(1.0)
            EFI.isUpdating = false
            SetNotif("Your EFI is ready!", "Just updated OpenCore on \(savedPath)")
            print(savedPath)
        }
        
    }
    
    
    func calculateRequiredSpaces(archiveSize: Double) async -> (Bool, Bool) {
        // clean .Trashes of EFI partition to make space
        await shellAsync("rm -rf '\(EFI.mounted)/.Trashes'")
        
        var canBackUp:Bool = false
        var canUpdate:Bool = false
        // calculate free space
        if let newEFIsize = try? URL(fileURLWithPath: standaloneUpdateDir + "/EFI").sizeWithUnits() {
            
            let requiredSpace = archiveSize + newEFIsize
            if let oldEFIsize = try? URL(fileURLWithPath: EFI.mounted + "/EFI").sizeWithUnits() {
                if let allFilesSize = try?  URL(fileURLWithPath: EFI.mounted).sizeWithUnits() {
                    
                    
                    // EFI partition .systemFreeSize can't be calculated
                    // we have to calculte by ourself based on default 209mb size
                    let partitionSize:Double = 205.0
                    let freeSpace = partitionSize - allFilesSize + oldEFIsize // old EFI will be deleted so we exclude also his size
                    
                    if requiredSpace < freeSpace {
                        canBackUp = true
                    }
                    
                    if newEFIsize < freeSpace {
                        canUpdate = true
                        
                    }
                }
            }
        } else {
            print("❌ Error at standalone dir")
        }
        
        return (canBackUp, canUpdate)
        
    }
}

