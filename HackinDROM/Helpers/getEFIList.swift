//
//  getEFIList.swift
//  getEFIList
//
//  Created by lian on 13/08/2021.
//  Copyright © 2021 Golden Chopper. All rights reserved.
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
                                                
                                                
                                                do {
                                                    let FindPlists = try fileManager.contentsOfDirectory(at: URL(fileURLWithPath: "\(foundEFI.mounted)/EFI/OC"), includingPropertiesForKeys: nil)
                                                    let plists =  FindPlists.filter { $0.pathExtension == "plist" }
                                                    
                                                    
                                                    for plist in plists {
                                                        
                                                        
                                                        foundEFI.plists.append(plist.lastPathComponent)
                                                        
                                                    }
                                                } catch {
                                                    print(error)
                                                }
                                                
                                                let  OCEFIPath = "\(foundEFI.mounted)/EFI/OC/OpenCore.efi"
                                                let  PlistPath = "\(foundEFI.mounted)/EFI/OC/config.plist"
                                                
                                                foundEFI.OC = fileManager.fileExists(atPath: OCEFIPath) && fileManager.fileExists(atPath: PlistPath)
                                                
                                                if foundEFI.OC {
                                                    
                                                    let createddate = GetOCCreatedDate(OCEFIPath)
                                                    
                                                    print(createddate.monthAndYear)
                                                        
                                                       
                                                        shell("curl --silent https://github.com/acidanthera/opencorepkg/releases | grep 'datetime=\"\(createddate.monthAndYear)'  -A 60 | grep '<h4>v' ") { result, _ in
                                                            
                                                            foundEFI.OCv = result.slice(from: "<h4>v", to: "</h4>") ?? "0.0.0" //#FIXME add github API to find and store date and version instead of using this "old" method, use this method if API request rate limit is reached
                                                            
                                                        }
                                                    
                                                    
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
                                                                     
                                                                     
                                                                     if let VolName = APFSVolumes.Childs.first(where: {$0.Childs.first(where: {$00.name == "VolumeName"
                                                                         && $00.StringValue != "VM"
                                                                         && $00.StringValue != "Update"
                                                                         && $00.StringValue != "Preboot"
                                                                         && $00.StringValue != "Recovery"
                                                                          
                                                                     }) != nil})?.Childs.first(where: {$0.name == "VolumeName"}) {
                                                                         
                                                                         foundEFI.SSD = VolName.StringValue.replacingOccurrences(of: " - Data", with: "")
                                                                             .replacingOccurrences(of: " - Données", with: "")
                                                                             .replacingOccurrences(of: " - Gegevens", with: "")
                                                                             .replacingOccurrences(of: " - Dados", with: "")
                                                                             .replacingOccurrences(of: " - Datos", with: "")
                                                                             .replacingOccurrences(of: " - Dati", with: "")
                                                                     }
                                                                    
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