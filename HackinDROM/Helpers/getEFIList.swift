//
//  getEFIList.swift
//  getEFIList
//
//  Created by Inqnuam on 13/08/2021.
//  Copyright © 2021 HackitAll. All rights reserved.
//
import Foundation

func getEFIList() -> [EFI] {
    var EFILIST:[EFI] = []
    
    let plistpath = "\(tmp)/disksx.plist"
    shell("diskutil list -plist > '\(plistpath)'") { _, _ in
        //"/Users/lian/Downloads/alldisks-4.plist"
        getHAPlistFrom(plistpath) { HAPEFI in
            
            if let AllDisksAndPartitions = HAPEFI.Childs.first(where: {$0.name == "AllDisksAndPartitions"}) {
                
                for disk in AllDisksAndPartitions.Childs {
                    
                    if disk.Childs.first(where: {$0.name == "Content" && $0.StringValue == "GUID_partition_scheme"}) != nil {
                        
                        if let partitions = disk.Childs.first(where: {$0.name == "Partitions" && $0.type == "array" }) {
                            
                            for part in partitions.Childs {
                                
                                if  part.Childs.first(where: {$0.name == "Content" && $0.StringValue == "EFI"}) != nil {
                                    var foundEFI = EFI(Name: "0.0.0", type: "Virtual",  Where: "Virtual", SSD: "NO NAME \(EFILIST.count)")
                                    
                                    if let diskIdentifier = part.Childs.first(where: {$0.name == "DeviceIdentifier" && $0.type == "string"}) {
                                        
                                        foundEFI.location = diskIdentifier.StringValue
                                        
                                        if let parent = disk.Childs.first(where: {$0.name == "DeviceIdentifier" && $0.type == "string"}) {
                                            foundEFI.Parent = parent.StringValue
                                            
                                            
                                            if let IODet = DADiskCreateFromBSDName(kCFAllocatorDefault, session!, "/dev/\(foundEFI.location)") {
                                                let IODetPar =  DADiskCopyWholeDisk(IODet)
                                                if IODetPar != nil {
                                                    let ReqDADATAPar = DADiskCopyDescription(IODetPar!)
                                                    
                                                    if ReqDADATAPar != nil {
                                                        
                                                        let desc2 = ReqDADATAPar as! [String: CFTypeRef]
                                                        
                                                        let DeviceModel =  desc2["DADeviceModel"]
                                                        let VendorName = desc2["DADeviceVendor"]
                                                        
                                                        if DeviceModel != nil && DeviceModel as! String != "" {
                                                            
                                                            foundEFI.Name = (DeviceModel as! String).trimmingCharacters(in: .whitespacesAndNewlines)
                                                            
                                                        }
                                                        if VendorName != nil && VendorName as! String != "" {
                                                            
                                                            foundEFI.Name.insert(contentsOf: (VendorName as! String).trimmingCharacters(in: .whitespacesAndNewlines) + " ", at: String.Index(utf16Offset: 0, in: foundEFI.Name)) // =
                                                        }
                                                        
                                                        if desc2["DADeviceProtocol"] != nil {
                                                            foundEFI.type = desc2["DADeviceProtocol"]! as! String
                                                        } else {
                                                            foundEFI.type =  "Virtual"
                                                            
                                                        }
                                                        if desc2["DADeviceInternal"] != nil {
                                                            foundEFI.Where =  desc2["DADeviceInternal"]! as! Int == 0 ? "External" : "Internal"
                                                        } else {
                                                            foundEFI.Where = "Virtual"
                                                            
                                                        }
                                                    } else {
                                                        foundEFI.type =  "Virtual"
                                                        foundEFI.Name = "Virtual"
                                                        foundEFI.Where = "Virtual"
                                                    }
                                                } else {
                                                    foundEFI.type =  "Virtual"
                                                    foundEFI.Name = "Virtual"
                                                    foundEFI.Where = "Virtual"
                                                }
                                            }
                                            
                                        }
                                        
                                        if let mountPoint = part.Childs.first(where: {$0.name == "MountPoint" && $0.type == "string"}) {
                                            foundEFI.mounted = mountPoint.StringValue
                                            
                                            if fileManager.fileExists(atPath: foundEFI.mounted, isDirectory: nil) {
                                                
                                                shell("rm -rf '\(foundEFI.mounted)/.Trashes'") {_, _ in}
                                                
                                                do {
                                                    let attributeDictionary = try fileManager.attributesOfFileSystem(forPath: foundEFI.mounted)
                                                    
                                                    if let size = attributeDictionary[.systemFreeSize] as? NSNumber {
                                                        
                                                        foundEFI.FreeSpace = Int(size.int64Value)
                                                        
                                                    }
                                                } catch {
                                                    
                                                }
                                                if let sizeOnDisk = try? URL(fileURLWithPath: "\(foundEFI.mounted)/EFI").sizeOnDisk() {
                                                    
                                                    foundEFI.BackUpSize = sizeOnDisk
                                                }
                                                
                                                if fileManager.fileExists(atPath: "\(foundEFI.mounted)/EFI/OC") {
                                                    do {
                                                        let FindPlists = try fileManager.contentsOfDirectory(at: URL(fileURLWithPath: "\(foundEFI.mounted)/EFI/OC"), includingPropertiesForKeys: nil)
                                                        let plists =  FindPlists.filter { $0.pathExtension == "plist" }
                                                        
                                                        
                                                        for plist in plists {
                                                            foundEFI.plists.append(plist.lastPathComponent)
                                                        }
                                                    } catch {
                                                        print(error)
                                                    }
                                                }
                                                let  OCEFIPath = "\(foundEFI.mounted)/EFI/OC/OpenCore.efi"
                                                let  PlistPath = "\(foundEFI.mounted)/EFI/OC/config.plist"
                                                
                                                foundEFI.OC = fileManager.fileExists(atPath: OCEFIPath) && fileManager.fileExists(atPath: PlistPath)
                                                
                                                if foundEFI.OC {
                                                    
                                                    let createddate = GetOCCreatedDate(OCEFIPath)
                                                    
                                                    
                                                    foundEFI.OCv = OCDateAndVersion[createddate.monthAndYear] ?? "0.0.0"
                                                    
                                                }
                                                
                                            } else {
                                                
                                                foundEFI.mounted = ""
                                                
                                            }
                                            
                                        }
                                        // Find OS Name
                                        
                                        if let firstRelatedPartition = partitions.Childs.first(where: {$0 != part}) {
                                            if let foundOSPartition = firstRelatedPartition.Childs.first(where: {$0.name == "Content"}) {
                                                
                                                if foundOSPartition.StringValue.localizedCaseInsensitiveContains("Linux") {
                                                    foundEFI.SSD = "Linux 🐧"
                                                } else if foundOSPartition.StringValue.localizedCaseInsensitiveContains("Microsoft")
                                                            || foundOSPartition.StringValue.localizedCaseInsensitiveContains("Windows") {
                                                    
                                                    // Trying to find a VolumeName to give as name
                                                    if let foundAName = firstRelatedPartition.Childs.first(where: {$0.name == "VolumeName" && !$0.StringValue.isEmpty}) {
                                                        
                                                        foundEFI.SSD = foundAName.StringValue
                                                    } else {
                                                        foundEFI.SSD = "Windows 🤔"
                                                        
                                                        let otherPartitions = partitions.Childs.filter{$0 != part && $0 != firstRelatedPartition}
                                                        
                                                        for otherPart in otherPartitions {
                                                            if let VolName = otherPart.Childs.first(where: {$0.name == "VolumeName" && !$0.StringValue.isEmpty}) {
                                                                foundEFI.SSD = VolName.StringValue
                                                            }
                                                        }
                                                    }
                                                    
                                                } else if foundOSPartition.StringValue.localizedCaseInsensitiveContains("Apple_HFS") {
                                                    
                                                    if let VolName = firstRelatedPartition.Childs.first(where: {$0.name == "VolumeName"}) {
                                                        
                                                        foundEFI.SSD = VolName.StringValue
                                                    }
                                                    
                                                } else if foundOSPartition.StringValue.localizedCaseInsensitiveContains("Apple_APFS") {
                                                    if let DeviceId = firstRelatedPartition.Childs.first(where: {$0.name == "DeviceIdentifier"})?.StringValue {
                                                        
                                                        
                                                        
                                                        
                                                        for apfsDisk in AllDisksAndPartitions.Childs.filter({$0.Childs.first(where: {$0.name == "Content" && $0.StringValue == "EF57347C-0000-11AA-AA11-00306543ECAC"}) != nil}) {
                                                            
                                                            if let APFSPhysicalStores = apfsDisk.Childs.first(where: {$0.name == "APFSPhysicalStores"}) {
                                                                
                                                                if APFSPhysicalStores.Childs.first?.Childs.first?.StringValue == DeviceId {
                                                                    
                                                                    if let APFSVolumes = apfsDisk.Childs.first(where: {$0.name == "APFSVolumes"}) {
                                                                        
                                                                       // dump(APFSVolumes.Childs)
                                                                        var volNames:[String] = []
                                                                        for vol in APFSVolumes.Childs {
                                                                            
                                                                            if let foundVolName = vol.Childs.first(where: {$0.name == "VolumeName"}) {
                                                                                
                                                                                if foundVolName.StringValue != "VM"
                                                                                    && foundVolName.StringValue != "Update"
                                                                                    && foundVolName.StringValue != "Preboot"
                                                                                    && foundVolName.StringValue != "Recovery"
                                                                                {
                                                                                    
                                                                                    let volName = foundVolName.StringValue.replacingOccurrences(of: " - Data", with: "")
                                                                                        .replacingOccurrences(of: " - Données", with: "")
                                                                                        .replacingOccurrences(of: " - Gegevens", with: "")
                                                                                        .replacingOccurrences(of: " - Dados", with: "")
                                                                                        .replacingOccurrences(of: " - Datos", with: "")
                                                                                        .replacingOccurrences(of: " - Dati", with: "")
                                                                                    
                                                                                    if !volNames.contains(volName) {
                                                                                        volNames.append(volName)
                                                                                    }
                                                                                }
                                                                                
                                                                            }
                                                                        }
                                                                        foundEFI.SSD = volNames.joined(separator: ", ")
                                                                    }
                                                                    
                                                                }
                                                            }
                                                            
                                                        }
                                                    }
                                                    
                                                }
                                            }
                                        }
                                    }
                                    EFILIST.append(foundEFI)
                                }
                                
                            }
                        }
                    }
                    
                    
                }
            }
        }
    }
    return EFILIST
}

let OCDateAndVersion = [
    "2022-09": "0.8.5",
    "2022-08": "0.8.4",
    "2022-07": "0.8.3",
    "2022-06": "0.8.2",
    "2022-05": "0.8.1",
    "2022-04": "0.8.0",
    "2022-03": "0.7.9",
    "2022-02": "0.7.8",
    "2022-01": "0.7.7",
    "2021-12": "0.7.6",
    "2021-11": "0.7.5",
    "2021-10": "0.7.4",
    "2021-09": "0.7.3",
    "2021-08": "0.7.2",
    "2021-07": "0.7.1",
    "2021-06": "0.7.0",
    "2021-05": "0.6.9",
    "2021-04": "0.6.8",
    "2021-03": "0.6.7",
    "2021-02": "0.6.6",
    "2021-01": "0.6.5",
    "2020-12": "0.6.4",
    "2020-11": "0.6.3",
    "2020-10": "0.6.2",
    "2020-09": "0.6.1",
    "2020-08": "0.6.0",
]
