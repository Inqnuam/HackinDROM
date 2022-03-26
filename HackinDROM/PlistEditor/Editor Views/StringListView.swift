//
//  StringListView.swift
//  HackinDROM
//
//  Created by Inqnuam 01/05/2021.
//  Copyright © 2021 HackinDROM. All rights reserved.
//

import SwiftUI
struct SingleRawStringView: View {
    @EnvironmentObject var sharedData: HASharedData
    @Binding var Dict: HAPlistStruct
    @State var selectedPicker = 0
    @State var showbase64:Bool = false
    @State var base64value:String = ""
    @State var selectedType:Int = 0
    var parentType:String = ""
    let NCExternalAdded = nc.publisher(for: NSNotification.Name("UpdateValues"))
    @State var isShowingPopover:Bool = false

    func setEditingVals() {
     
        
        if Dict.type == "string" {
            selectedType = 0
        } else if Dict.type == "bool" {
            selectedType = 1
        } else if Dict.type == "int" {
            selectedType = 2
           
        } else if Dict.type == "data" {
            selectedType = 3
        }
       
    }
    var body: some View {
        
       
            
        HStack {
            Section(header: HStack {
                    
                    if parentType != "array" {
                    if !Dict.isEditing {
                        
                        
                        Text(Dict.name + ":")
                            
                            .bold()
                            .contentShape(Rectangle())
                            .foregroundColor(Color(.secondaryLabelColor))
                            .onLongPressGesture {
                                Dict.isEditing.toggle()
                           
                            }
    
                        
                    } else {
                       
                        Picker("", selection: $selectedType.pickerChanged(setDictType)) {
                            Text("String").tag(0)
                            Text("Boolean").tag(1)
                            Text("Number").tag(2)
                            Text("Data").tag(3)
                           
                           
                        }.labelsHidden()
                        TextField("String", text: $Dict.name, onCommit: {
                            Dict.isEditing = false
                            
                        })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onAppear {
                            setEditingVals()
                        }
                        
                    }
                }
                    
                }) {
                    
                    if Dict.name == "Arch" && Dict.type == "string" {
                        
                        Picker(selection: $selectedPicker.pickerChanged(setArchVal), label: Text("")) {
                            
                            Text("Any").tag(0)
                            Text("i386").tag(1)
                            Text("x86_64").tag(2)
                            Divider()
                            Text("Other").tag(199)
                        }.labelsHidden()
                        
                        
                    }
                    else if Dict.name == "TableSignature" && Dict.type == "data" {
                        Picker("", selection: $selectedPicker.pickerChanged(SetTableSigData)) {
                            
                            ForEach(TableSignature.indices, id: \.self) { i in
                                
                                Text(TableSignature[i].name).tag(i)
                                
                            }
                            Divider()
                            Text("Other").tag(199)
                        }.labelsHidden()
                    }
                    else if Dict.name == "SystemProductName" && Dict.type == "string" {
                        Picker("", selection: $selectedPicker.pickerChanged(SetMacsSystemProductName)) {
                            
                            ForEach(Macs.indices, id: \.self) { i in
                                
                                Text(Macs[i]).tag(i)
                                
                            }
                            Divider()
                            Text("Other").tag(199)
                        }.labelsHidden()
                        
                        
                    }
                    else if Dict.name == "DmgLoading" && Dict.type == "string" && Dict.parentName == "Security" {
                        
                        Picker(selection: $selectedPicker.pickerChanged(setDmgLoading), label: Text("")) {
                            
                            Text("Any — any DMG images will mount as normal filesystems. The Any policy is strongly discouraged and will result in boot failures when Apple Secure Boot is active.").tag(0)
                            Text("Disabled — loading DMG images will fail. The Disabled policy will still let the macOS Recovery load in most cases...").tag(1)
                            Text("Signed — only Apple-signed DMG images will load.").tag(2)
                            Divider()
                            Text("Other").tag(199)
                            
                        }.labelsHidden()
                        
                    }
                    else if Dict.name == "ExposeSensitiveData" && Dict.type == "int" && Dict.parentName == "Security" {

                        Button("Select") {
                            isShowingPopover.toggle()

                        } .popover(isPresented: $isShowingPopover, arrowEdge: .bottom) {
                          
                                
                            PopoverForOptions(value: $Dict.stringValue, selectingOptions: [HAPMultiOptions(value: 1, isSelected: false, info: "Expose the printable booter path as an UEFI variable."),
                                                                                         HAPMultiOptions(value: 2, isSelected: false, info: "Expose the OpenCore version as an UEFI variable."),
                                                                                         HAPMultiOptions(value: 4, isSelected: false, info: "Expose the OpenCore version in the OpenCore picker menu title."),
                                                                                         HAPMultiOptions(value: 8, isSelected: false, info: "Expose OEM information as a set of UEFI variables.")])
                                    

                        }
                        
                    }
                    else if Dict.name == "ScanPolicy" && Dict.type == "int" && Dict.parentName == "Security" {

                        Button("Select") {
                            isShowingPopover.toggle()

                        } .popover(isPresented: $isShowingPopover, arrowEdge: .bottom) {
                          
                                
                            PopoverForOptions(value: $Dict.stringValue, selectingOptions: [HAPMultiOptions(value: 1, isSelected: false, info: "Restricts scanning to only known file systems defined as a part of this policy..."),
                                                                                           HAPMultiOptions(value: 2, isSelected: false, info: "Restricts scanning to only known device types defined as a part of this policy..."),
                                                                                           HAPMultiOptions(value: 256, isSelected: false, info: "Allows scanning of APFS file system."),
                                                                                           HAPMultiOptions(value: 512, isSelected: false, info: "Allows scanning of HFS file system."),
                                                                                           HAPMultiOptions(value: 1024, isSelected: false, info: "Allows scanning of EFI System Partition file system."),
                                                                                           HAPMultiOptions(value: 2048, isSelected: false, info: "Allows scanning of NTFS (Msft Basic Data) file system."),
                                                                                           HAPMultiOptions(value: 4096, isSelected: false, info: "Allows scanning of EXT (Linux Root) file system."),
                                                                                           HAPMultiOptions(value: 65536, isSelected: false, info: "Allows scanning SATA devices."),
                                                                                           HAPMultiOptions(value: 131072, isSelected: false, info: "Allows scanning SAS and Mac NVMe devices."),
                                                                                           HAPMultiOptions(value: 262144, isSelected: false, info: "Allows scanning SCSI devices."),
                                                                                           HAPMultiOptions(value: 524288, isSelected: false, info: "Allows scanning NVMe devices."),
                                                                                           HAPMultiOptions(value: 1048576, isSelected: false, info: "Allows scanning CD/DVD devices and old SATA."),
                                                                                           HAPMultiOptions(value: 2097152, isSelected: false, info: "Allows scanning USB devices."),
                                                                                           HAPMultiOptions(value: 4194304, isSelected: false, info: "Allows scanning FireWire devices."),
                                                                                           HAPMultiOptions(value: 8388608, isSelected: false, info: "Allows scanning card reader devices."),
                                                                                           HAPMultiOptions(value: 16777216, isSelected: false, info: "Allows scanning devices directly connected to PCI bus (e.g. VIRTIO).")])
                                    

                        }
                        
                    }
                    else if Dict.name == "Vault" && Dict.type == "string" && Dict.parentName == "Security" {
                        
                        Picker(selection: $selectedPicker.pickerChanged(setVault), label: Text("")) {
                            
                            Text("Optional — require nothing, no vault is enforced, insecure.").tag(0)
                            Text("Basic — require vault.plist file present in OC directory. ").tag(1)
                            Text("Secure — require vault.sig signature file for vault.plist in OC directory.").tag(2)
                            Divider()
                            Text("Other").tag(199)
                          
                        }.labelsHidden()
                        
                    }
                    else if Dict.name == "SecureBootModel" && Dict.type == "string" && Dict.parentName == "Security" {
                        
                        Picker(selection: $selectedPicker.pickerChanged(SetSecureBootModel), label: Text("")) {
                            ForEach(SecureBootModels.indices, id: \.self) { i in
                                
                                Text(SecureBootModels[i].name).tag(i)
                                
                            }
                            Divider()
                            Text("Other").tag(199)
                        }.labelsHidden()
                        
                    }
                    else if Dict.name == "ConsoleAttributes" && Dict.type == "int" && Dict.parentName == "Boot" {
                        ConsoleAttributesView(stringValue: $Dict.stringValue)
                    }
                    else if Dict.name == "PickerAttributes" && Dict.type == "int" && Dict.parentName == "Boot" {
                        
                        Button("Select") {
                            isShowingPopover.toggle()

                        } .popover(isPresented: $isShowingPopover, arrowEdge: .bottom) {
                            
                            PopoverForOptions(value: $Dict.stringValue, selectingOptions: [
                                HAPMultiOptions(value: 1, isSelected: false, info: "Provides custom icons for boot entries:..."),
                                HAPMultiOptions(value: 2, isSelected: false, info: "Provides custom prerendered titles for boot entries from .disk_label (.disk_label_2x) file next to the bootloader for all filesystems..."),
                                HAPMultiOptions(value: 4, isSelected: false, info: "Provides predefined label images for boot entries without custom entries. This may however give less detail for the actual boot entry."),
                                HAPMultiOptions(value: 8, isSelected: false, info: "Prefers builtin icons for certain icon categories to match the theme style. For example, this could force displaying the builtin Time Machine icon. Requires 0x01"),
                                HAPMultiOptions(value: 16, isSelected: false, info: "Enables pointer control in the OpenCore picker when available. For example, this could make use of mouse or trackpad to control UI elements."),
                                HAPMultiOptions(value: 32, isSelected: false, info: "Enable display of additional timing and debug information, in Builtin picker in DEBUG and NOOPT builds only."),
                                HAPMultiOptions(value: 64, isSelected: false, info: "Use minimal UI display, no Shutdown or Restart buttons, affects OpenCanopy and builtin picker."),
                                HAPMultiOptions(value: 128, isSelected: false, info: "Provides flexible boot entry content description, suitable for picking the best media across different content sets:...")])
                            
                            
                        }
                        
                    }
                    else if Dict.name == "PickerMode" && Dict.type == "string" && Dict.parentName == "Boot" {
                        
                        Picker(selection: $selectedPicker.pickerChanged(setPickerMode), label: Text("")) {
                            
                            Text("Builtin — boot management is handled by OpenCore, a simple text-only user interface is used.").tag(0)
                            Text("External — an external boot management protocol is used if available. Otherwise, the Builtin mode is used.").tag(1)
                            Text("Apple — Apple boot management is used if available. Otherwise, the Builtin mode is used.").tag(2)
                            Divider()
                            Text("Other").tag(199)
                          
                        }.labelsHidden()
                        
                    }
                    else if Dict.name == "PickerVariant" && Dict.type == "string" && Dict.parentName == "Boot" {
                        
                        Picker(selection: $selectedPicker.pickerChanged(setPickerVariant), label: Text("")) {
                            
                            Text("Auto — Automatically select one set of icons based on the DefaultBackground colour.").tag(0)
                            Text("Default").tag(1)
                            Text("Old — Vintage icon set (Old filename prefix). 0.6.9 & -").tag(2)
                            Text("Modern — Nouveau icon set (Modern filename prefix). 0.6.9 & -").tag(3)
                            Divider()
                            Text("Other").tag(199)
                          
                        }.labelsHidden()
                        
                    }
                    else if Dict.name == "HibernateMode" && Dict.type == "string" && Dict.parentName == "Boot" {
                        
                        Picker(selection: $selectedPicker.pickerChanged(setHibernateMode), label: Text("")) {
                            
                            Text("None — Ignore hibernation state.").tag(0)
                            Text("Auto — Use RTC and NVRAM detection.").tag(1)
                            Text("RTC — Use RTC detection.").tag(2)
                            Text("NVRAM — Use NVRAM detection.").tag(3)
                            Divider()
                            Text("Other").tag(199)
                          
                        }.labelsHidden()
                        
                    }
                    else if Dict.name == "LauncherOption" && Dict.type == "string" && Dict.parentName == "Boot" {
                        
                        Picker(selection: $selectedPicker.pickerChanged(setLauncherOption), label: Text("")) {
                            
                            Text("Disabled — do nothing.").tag(0)
                            Text("Full — create or update the top priority boot option in UEFI variable storage at bootloader startup. RequestBootVarRouting is required to be enabled.").tag(1)
                            Text("Short — create a short boot option instead of a complete one. This variant is useful for some older types of firmware, typically from Insyde.").tag(2)
                            Text("System — create no boot option but assume specified custom option is blessed. This variant is useful when relying on ForceBooterSignature quirk...").tag(3)
                            Divider()
                            Text("Other").tag(199)
                          
                        }.labelsHidden()
                        
                    }
                    else if Dict.name == "KernelArch" && Dict.type == "string" && Dict.parentName == "Scheme" {
                        
                        Picker(selection: $selectedPicker.pickerChanged(setKernelArch), label: Text("")) {
                            
                            Text("Auto — Choose the preferred architecture automatically.").tag(0)
                            Text("i386 — Use i386 (32-bit) kernel when available.").tag(1)
                            Text("i386-user32 — Use i386 (32-bit) kernel when available and force the use of 32-bit userspace on 64-bit capable processors if supported by the OS...").tag(2)
                            Text("x86_64 — Use x86_64 (64-bit) kernel when available.").tag(3)
                            Divider()
                            Text("Other").tag(199)
                          
                        }.labelsHidden()
                        
                    }
                    else if Dict.name == "KernelCache" && Dict.type == "string" && Dict.parentName == "Scheme" {
                        
                        Picker(selection: $selectedPicker.pickerChanged(setKernelCache), label: Text("")) {
                            
                            Text("Auto — Choose the preferred kernel cache type when available.").tag(0)
                            Text("Cacheless").tag(1)
                            Text("Mkext").tag(2)
                            Text("Prelinked").tag(3)
                            Divider()
                            Text("Other").tag(199)
                          
                        }.labelsHidden()
                        
                    }
                    else if Dict.name == "Resolution" && Dict.type == "string" && Dict.parentName == "Output" {
                        
                        Picker(selection: $selectedPicker.pickerChanged(setOutputResolution), label: Text("")) {
                            
                            ForEach(outputResolutions.indices, id:\.self) { i in
                                
                                
                                Text(outputResolutions[i].name).tag(i)
                            }
                            Divider()
                            Text("Other").tag(199)
                          
                        }.labelsHidden()
                        
                    }
                    else if Dict.name == "GopPassThrough" && Dict.type == "string" && Dict.parentName == "Output" {
                       
                       Picker(selection: $selectedPicker.pickerChanged(setOutputGopPassThrough), label: Text("")) {
                           
                        Text("Apple — provide GOP for AppleFramebufferInfo-enabled protocols.").tag(0)
                        Text("Disabled — do not provide GOP.").tag(1)
                        Text("Enabled — provide GOP for all UGA protocols.").tag(2)
                           Divider()
                           Text("Other").tag(199)
                         
                       }.labelsHidden()
                       
                   }
                    else if Dict.name == "AppleEvent" && Dict.type == "string" && Dict.parentName == "AppleInput" {
                        
                        Picker("", selection: $selectedPicker.pickerChanged(setAppleEvent)) {
                            
                            Text("Auto — Use OEM Apple Event implementation if available, connected and recent enough to be used, otherwise use OC reimplementation...").tag(0)
                            Text("Builtin — Always use OpenCore’s updated re-implementation of the Apple Event protocol...").tag(1)
                            Text("OEM — Assume Apple’s protocol will be available at driver connection...").tag(2)
                            Divider()
                            Text("Other").tag(199)
                          
                        }.labelsHidden()
                        
                    }
                    else if Dict.name == "PlayChime" && Dict.type == "string" && Dict.parentName == "Audio" {
                        
                        Picker("", selection: $selectedPicker.pickerChanged(setPlayChime)) {
                            
                            Text("Auto — Enables chime when StartupMute NVRAM variable is not present or set to 00.").tag(0)
                            Text("Enabled — Enables chime unconditionally.").tag(1)
                            Text("Disabled — Disables chime unconditionally.").tag(2)
                            Divider()
                            Text("Other").tag(199)
                          
                        }.labelsHidden()
                        
                    }
                    else if Dict.name == "KeySupportMode" && Dict.type == "string" && Dict.parentName == "Input" {
                        
                        Picker("", selection: $selectedPicker.pickerChanged(setKeySupportMode)) {
                            
                            Text("Auto — Performs automatic choice as available with the following preference: AMI, V2, V1.").tag(0)
                            Text("V1 — Uses UEFI standard legacy input protocol EFI_SIMPLE_TEXT_INPUT_PROTOCOL.").tag(1)
                            Text("V2 — Uses UEFI standard modern input protocol EFI_SIMPLE_TEXT_INPUT_EX_PROTOCOL.").tag(2)
                            Text("AMI — Uses APTIO input protocol AMI_EFIKEYCODE_PROTOCOL.").tag(3)
                            Divider()
                            Text("Other").tag(199)
                          
                        }.labelsHidden()
                        
                    }
                    else if Dict.name == "TextRenderer" && Dict.type == "string" && Dict.parentName == "Output" {
                        
                        Picker("", selection: $selectedPicker.pickerChanged(setTextRenderer)) {
                            
                            Text("BuiltinGraphics — Switch to Graphics mode and use Builtin renderer with custom ConsoleControl.").tag(0)
                            Text("BuiltinText — Switch to Text mode and use Builtin renderer with custom ConsoleControl.").tag(1)
                            Text("SystemGraphics — Switch to Graphics mode and use System renderer with custom ConsoleControl.").tag(2)
                            Text("SystemText — Switch to Text mode and use System renderer with custom ConsoleControl.").tag(3)
                            Text("SystemGeneric — Use System renderer with system ConsoleControl assuming it behaves correctly.").tag(4)
                            Divider()
                            Text("Other").tag(199)
                          
                        }.labelsHidden()
                        
                    }
                    else if Dict.name == "UpdateSMBIOSMode" && Dict.type == "string" && Dict.parentName == "PlatformInfo" {
                        
                        Picker("", selection: $selectedPicker.pickerChanged(setUpdateSMBIOSMode)) {
                            
                            Text("TryOverwrite — Overwrite if new size is <= than the page-aligned original and there are no issues with legacy region unlock...").tag(0)
                            Text("Create — Replace the tables with newly allocated EfiReservedMemoryType at AllocateMaxAddress without any fallbacks...").tag(1)
                            Text("Overwrite — Overwrite existing gEfiSmbiosTableGuid and gEfiSmbiosTable3Guid data if it fits new size. Abort with unspecified state otherwise...").tag(2)
                            Text("Custom — Write SMBIOS tables (gEfiSmbios(3)TableGuid) to gOcCustomSmbios(3)TableGuid to workaround firmware overwriting SMBIOS contents at ExitBootServices...").tag(3)
                            Divider()
                            Text("Other").tag(199)
                          
                        }.labelsHidden()
                        
                    }
                    else if Dict.name == "SystemMemoryStatus" && Dict.type == "string" && Dict.parentName == "Generic" {
                        
                        Picker("", selection: $selectedPicker.pickerChanged(setSystemMemoryStatus)) {
                            
                            Text("Auto — use the original PlatformFeature value.").tag(0)
                            Text("Upgradable — explicitly unset PT_FEATURE_HAS_SOLDERED_SYSTEM_MEMORY (0x2) in PlatformFeature.").tag(1)
                            Text("Soldered — explicitly set PT_FEATURE_HAS_SOLDERED_SYSTEM_MEMORY (0x2) in PlatformFeature.").tag(2)
                            Divider()
                            Text("Other").tag(199)
                          
                        }.labelsHidden()
                       
                        
                    }
                    else if Dict.name == "Type" && Dict.type == "string" && Dict.parentName == "ReservedMemory" {
                        
                        Picker("", selection: $selectedPicker.pickerChanged(setReservedMemory)) {
                            
                            ForEach(ReservedMemory.indices, id:\.self) { ind in
                                
                                Text(ReservedMemory[ind].name).tag(ReservedMemory[ind].value).tag(ind)
                            }
                            Divider()
                            Text("Other").tag(199)
                          
                        }.labelsHidden()
                       
                        
                    }
                    else if Dict.name == "MinVersion" && Dict.type == "int" && Dict.parentName == "APFS" {
                        
                        Picker("", selection: $selectedPicker.pickerChanged(setAPFSMinVersion)) {
                            
                            ForEach(APFSMinVersion.indices, id:\.self) { ind in
                                
                                Text("\(APFSMinVersion[ind].value) — \(APFSMinVersion[ind].name)").tag(ind)
                            }
                            Divider()
                            Text("Other").tag(199)
                          
                        }.labelsHidden()
                       
                        
                    }
                    else if Dict.name == "MinDate" && Dict.type == "int" && Dict.parentName == "APFS" {
                        
                        Picker("", selection: $selectedPicker.pickerChanged(setAPFSMinDate)) {
                            
                            ForEach(APFSMinVersion.indices, id:\.self) { ind in
                                
                                Text("\(APFSMinVersion[ind].aux!) — \(APFSMinVersion[ind].name)").tag(ind)
                            }
                            Divider()
                            Text("Other").tag(199)
                          
                        }.labelsHidden()
                       
                        
                    }

                    else {
                        if Dict.type == "bool" { //&& Dict.name != "Enabled" {
                            
                            Toggle("", isOn: $Dict.boolValue)
                                .labelsHidden()
                            Spacer()
                        } else {
                            
                            if !showbase64 {
                                
                                TextField(Dict.type == "data" ? "Data (Hex)" : Dict.type == "int" ? "Number" : "String" , text: $Dict.stringValue, onEditingChanged: { isTaping in
                                    if !isTaping {
                                        checkAndFix(to: StringChanged(which: 0, what: Dict.stringValue))
                                    }
                                })
                                  .textFieldStyle(RoundedBorderTextFieldStyle()) //
                            } else {
                                
                                TextField("Data (Base64)", text: $base64value.stringChanged(64, checkAndFix), onEditingChanged: { isTaping in
                                    if !isTaping {
                                        checkAndFix(to: StringChanged(which: 64, what: base64value))
                                    }
                                })
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            
                            Spacer()
                            if Dict.type == "data"  {
                                Divider()
                                    .frame(height: 15)
                                Text("🧬")
                                    .onTapGesture{
                                        
                                        showbase64.toggle()
                                    }
                            }
                        }
                    }
                    
                    if selectedPicker == 199 {
                        
                        if !showbase64 {
                            if Dict.type != "bool" {
                                TextField(Dict.type == "string" ? "String" : Dict.type == "int" ? "Number" : "Data (Hex)", text: $Dict.stringValue, onEditingChanged: { isTaping in
                                    if !isTaping {
                                        checkAndFix(to: StringChanged(which: 0, what: Dict.stringValue))
                                    }
                                })
                                .frame(width: 110)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                        } else {
                            
                            TextField("Data (Base64)", text: $base64value.stringChanged(64, checkAndFix), onEditingChanged: { isTaping in
                                if !isTaping {
                                    checkAndFix(to: StringChanged(which: 64, what: base64value))
                                }
                            })
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                        }
                        Spacer()
                        if Dict.type == "data" {
                            Divider()
                                .frame(height: 15)
                         Text("🧬")
                            
                            .onTapGesture{
                                
                                showbase64.toggle()
                            
                            }
                        }
                    }
                }
              
        }
            
         
        .onAppear{
          
            findAllValues()
       }
        
        .onReceive(NCExternalAdded) { (output) in
            guard let name = output.userInfo!["name"] else { return }
            if name as! String == Dict.name {
                findAllValues()
                
            }

    }
       
        
    }
   

    func findAllValues() {
        
        
         if Dict.type == "data" {
             
             base64value = Dict.stringValue.data(using: .bytesHexLiteral)?.base64EncodedString() ?? ""
         }
         
         
         if Dict.name == "TableSignature" && Dict.type == "data" {
             
             findTableSigData()
             
         } else if Dict.name == "Arch" && Dict.type == "string" {
             
             findArch()
         } else if Dict.name == "SystemProductName" && Dict.type == "string" && Dict.parentName == "Generic" {
             findMacsSystemProductName()
             
         } else if Dict.name == "SystemMemoryStatus" && Dict.type == "string" && Dict.parentName == "Generic" {
            findSystemMemoryStatus()
            
         }
        else if Dict.name == "ExposeSensitiveData" || Dict.name == "ScanPolicy" && (Dict.type == "int" && Dict.parentName == "Security") {
             
          
            selectedPicker = 199
             
         }
        else if Dict.name == "DmgLoading" && Dict.type == "string" && Dict.parentName == "Security" {
             
             findDmgLoading()
             
         }  else if Dict.name == "SecureBootModel" && Dict.type == "string" && Dict.parentName == "Security" {
             
             findSecureBootModel()
             
         } else if Dict.name == "Vault" && Dict.type == "string" && Dict.parentName == "Security" {
             
             findVault()
             
         } else if Dict.name == "PickerMode" && Dict.type == "string" && Dict.parentName == "Boot" {
             
             findPickerMode()
             
         }
        else if Dict.name == "PickerAttributes" && Dict.type == "int" && Dict.parentName == "Boot" {
            
            selectedPicker = 199
            
        }
        else if Dict.name == "PickerVariant" && Dict.type == "string" && Dict.parentName == "Boot" {
             
            findPickerVariant()
             
         }  else if Dict.name == "HibernateMode" && Dict.type == "string" && Dict.parentName == "Boot" {
             
             findHibernateMode()
              
          }  else if Dict.name == "LauncherOption" && Dict.type == "string" && Dict.parentName == "Boot" {
             
            findLauncherOption()
              
          }  else if Dict.name == "KernelArch" && Dict.type == "string" && Dict.parentName == "Scheme" {
            
             findKernelArch()
             
         } else if Dict.name == "KernelCache" && Dict.type == "string" && Dict.parentName == "Scheme" {
             
             findKernelCache()
             
         } else if Dict.name == "AppleEvent" && Dict.type == "string" && Dict.parentName == "AppleInput" {
             
             findAppleEvent()
             
         } else if Dict.name == "PlayChime" && Dict.type == "string" && Dict.parentName == "Audio" {
             
             findPlayChime()
             
         } else if Dict.name == "KeySupportMode" && Dict.type == "string" && Dict.parentName == "Input" {
             
             findKeySupportMode()
             
         } else if Dict.name == "TextRenderer" && Dict.type == "string" && Dict.parentName == "Output" {
             
             findTextRenderer()
             
         }  else if Dict.name == "UpdateSMBIOSMode" && Dict.type == "string" && Dict.parentName == "PlatformInfo" {
             
             findUpdateSMBIOSMode()
             
         }  else if Dict.name == "Resolution" && Dict.type == "string" && Dict.parentName == "Output" {
            
            findoutputResolution()
            
        } else if Dict.name == "Type" && Dict.type == "string" && Dict.parentName == "ReservedMemory" {
            
            findReservedMemory()
            
        } else if Dict.name == "GopPassThrough" && Dict.type == "string" && Dict.parentName == "Output" {
            
            findOutputGopPassThrough()
            
        } else if Dict.name == "MinVersion" && Dict.type == "int" && Dict.parentName == "APFS" {
            
            findAPFSMinVersion()
            
        } else if Dict.name == "MinDate" && Dict.type == "int" && Dict.parentName == "APFS" {
            
            findAPFSMinDate()
            
        }
        
        
      
    }
    
    func findSystemMemoryStatus(){
        
        if Dict.stringValue == "Auto" {
            selectedPicker = 0
        } else  if Dict.stringValue == "Upgradable" {
            selectedPicker = 1
        }  else  if Dict.stringValue == "Soldered" {
            selectedPicker = 2
        }  else {
            selectedPicker = 199
        }
        
    }
    func setSystemMemoryStatus(to value: Int) {
        
        if value == 0 {
            Dict.stringValue = "Auto"
        } else if value == 1 {
            Dict.stringValue = "Upgradable"
        } else if value == 2 {
            Dict.stringValue = "Soldered"
        } else if value == 199 {
            Dict.stringValue = "Auto"
        }
        
    }
    
    
   func findReservedMemory() {
        
    if let index = ReservedMemory.firstIndex(where: {$0.value == Dict.stringValue}) {
        
        selectedPicker = index
    } else {
        selectedPicker = 199
    }
    
    }
    
    
    func setReservedMemory (to ind: Int) {
        
       if ind != 199 {
           
            Dict.stringValue = ReservedMemory[ind].value
       } else {
      
        Dict.stringValue = "Reserved"
       }
        
        
        
    }
    
    func findAPFSMinVersion() {
         
     if let index = APFSMinVersion.firstIndex(where: {$0.value == Dict.stringValue}) {
         
         selectedPicker = index
     } else {
         selectedPicker = 199
     }
     
     }
    
    func setAPFSMinVersion (to ind: Int) {
        
        if ind != 199 {
            
             Dict.stringValue = APFSMinVersion[ind].value
        } else {
       
         Dict.stringValue = "0"
        }
        
    }
    
    func findAPFSMinDate() {
         
     if let index = APFSMinVersion.firstIndex(where: {$0.aux! == Dict.stringValue}) {
         
         selectedPicker = index
     } else {
         selectedPicker = 199
     }
     
     }
    
    func setAPFSMinDate (to ind: Int) {
        
        if ind != 199 {
            
             Dict.stringValue = APFSMinVersion[ind].aux!
        } else {
       
         Dict.stringValue = "0"
        }
        
    }
    func findUpdateSMBIOSMode(){
        
        if Dict.stringValue == "TryOverwrite" {
            selectedPicker = 0
        } else  if Dict.stringValue == "Create" {
            selectedPicker = 1
        }  else  if Dict.stringValue == "Overwrite" {
            selectedPicker = 2
        }  else  if Dict.stringValue == "Custom" {
            selectedPicker = 3
        }  else {
            selectedPicker = 199
        }
        
    }
    func setUpdateSMBIOSMode(to value: Int) {
        
        if value == 0 {
            Dict.stringValue = "TryOverwrite"
        } else if value == 1 {
            Dict.stringValue = "Create"
        } else if value == 2 {
            Dict.stringValue = "Overwrite"
        }  else if value == 3 {
            Dict.stringValue = "Custom"
        } else if value == 199 {
            Dict.stringValue = "Create"
        }
        
    }
    
    
    func findTextRenderer(){
        
        if Dict.stringValue == "BuiltinGraphics" {
            selectedPicker = 0
        } else  if Dict.stringValue == "BuiltinText" {
            selectedPicker = 1
        }  else  if Dict.stringValue == "SystemGraphics" {
            selectedPicker = 2
        }  else  if Dict.stringValue == "SystemText" {
            selectedPicker = 3
        }  else  if Dict.stringValue == "SystemGeneric" {
            selectedPicker = 4
        } else {
            selectedPicker = 199
        }
        
    }
    func setTextRenderer(to value: Int) {
        
        if value == 0 {
            Dict.stringValue = "BuiltinGraphics"
        } else if value == 1 {
            Dict.stringValue = "BuiltinText"
        } else if value == 2 {
            Dict.stringValue = "SystemGraphics"
        }  else if value == 3 {
            Dict.stringValue = "SystemText"
        }  else if value == 4 {
            Dict.stringValue = "SystemGeneric"
        }  else if value == 199 {
            Dict.stringValue = "BuiltinGraphics"
        }
        
    }
    
    
    func findKeySupportMode(){
        
        if Dict.stringValue == "Auto" {
            selectedPicker = 0
        } else  if Dict.stringValue == "V1" {
            selectedPicker = 1
        }  else  if Dict.stringValue == "V2" {
            selectedPicker = 2
        }  else  if Dict.stringValue == "AMI" {
            selectedPicker = 3
        }  else {
            selectedPicker = 199
        }
        
    }
    func setKeySupportMode(to value: Int) {
        
        if value == 0 {
            Dict.stringValue = "Auto"
        } else if value == 1 {
            Dict.stringValue = "V1"
        } else if value == 2 {
            Dict.stringValue = "V2"
        }  else if value == 3 {
            Dict.stringValue = "AMI"
        } else if value == 199 {
            Dict.stringValue = "Auto"
        }
        
        
    }
    
    
    func findPlayChime(){
        
        if Dict.stringValue == "Auto" {
            selectedPicker = 0
        } else  if Dict.stringValue == "Enabled" {
            selectedPicker = 1
        }  else  if Dict.stringValue == "Disabled" {
            selectedPicker = 2
        }  else {
            selectedPicker = 199
        }
        
    }
    func setPlayChime(to value: Int) {
        
        if value == 0 {
            Dict.stringValue = "Auto"
        } else if value == 1 {
            Dict.stringValue = "Enabled"
        } else if value == 2 {
            Dict.stringValue = "Disabled"
        } else if value == 199 {
            Dict.stringValue = "Auto"
        }
        
        
    }
    func findAppleEvent(){
        
        if Dict.stringValue == "Auto" {
            selectedPicker = 0
        } else  if Dict.stringValue == "Builtin" {
            selectedPicker = 1
        }  else  if Dict.stringValue == "OEM" {
            selectedPicker = 2
        }  else {
            selectedPicker = 199
        }
        
    }
    func setAppleEvent(to value: Int) {
        
        if value == 0 {
            Dict.stringValue = "Auto"
        } else if value == 1 {
            Dict.stringValue = "Builtin"
        } else if value == 2 {
            Dict.stringValue = "OEM"
        } else if value == 199 {
            Dict.stringValue = "Auto"
        }
        
    }
    
    func findKernelCache(){
        
        if Dict.stringValue == "Auto" {
            selectedPicker = 0
        } else  if Dict.stringValue == "Cacheless" {
            selectedPicker = 1
        }  else  if Dict.stringValue == "Mkext" {
            selectedPicker = 2
        }  else  if Dict.stringValue == "Prelinked" {
            selectedPicker = 3
        }  else {
            selectedPicker = 199
        }
        
    }
    func setKernelCache(to value: Int) {
        
        if value == 0 {
            Dict.stringValue = "Auto"
        } else if value == 1 {
            Dict.stringValue = "Cacheless"
        } else if value == 2 {
            Dict.stringValue = "Mkext"
        }  else if value == 3 {
            Dict.stringValue = "Prelinked"
        } else if value == 199 {
            Dict.stringValue = "Auto"
        }
        
        
        
    }
    
    func setOutputResolution(to value: Int) {
        
        if value == 199 {
            Dict.stringValue = "Max"
        } else {
            Dict.stringValue = outputResolutions[value].name
        }
        
        
        
    }
    func findOutputGopPassThrough() {
        
        if Dict.stringValue == "Apple" {
            selectedPicker = 0
        } else if Dict.stringValue == "Disabled" {
            selectedPicker = 1
        }  else if Dict.stringValue == "Enabled" {
            selectedPicker = 2
        } else {
            selectedPicker = 199
        }
    }
    func setOutputGopPassThrough(to value: Int) {
        
        
        if value == 199 {
            Dict.stringValue = "Disabled"
            
        } else if value == 0 {
            Dict.stringValue = "Apple"
        } else if value == 1 {
            Dict.stringValue = "Disabled"
        } else if value == 2 {
            Dict.stringValue = "Enabled"
        }
        
        
        
    }
    func findoutputResolution(){
        
        if let index = outputResolutions.firstIndex(where: {$0.name == Dict.stringValue}) {
            
            selectedPicker = index
        } else {
            selectedPicker = 199
            
        }
        
    }
    func findKernelArch(){
        
        if Dict.stringValue == "Auto" {
            selectedPicker = 0
        } else  if Dict.stringValue == "i386" {
            selectedPicker = 1
        }  else  if Dict.stringValue == "i386-user32" {
            selectedPicker = 2
        }  else  if Dict.stringValue == "x86_64" {
            selectedPicker = 3
        }  else {
            selectedPicker = 199
        }
        
    }
    func setKernelArch(to value: Int) {
        
        if value == 0 {
            Dict.stringValue = "Auto"
        } else if value == 1 {
            Dict.stringValue = "i386"
        } else if value == 2 {
            Dict.stringValue = "i386-user32"
        }  else if value == 3 {
            Dict.stringValue = "x86_64"
        } else if value == 199 {
            Dict.stringValue = "Auto"
        }
        
    }
    
    
    func findLauncherOption(){
        
        if Dict.stringValue == "Disabled" {
            selectedPicker = 0
        } else  if Dict.stringValue == "Full" {
            selectedPicker = 1
        }  else  if Dict.stringValue == "Short" {
            selectedPicker = 2
        }  else  if Dict.stringValue == "System" {
            selectedPicker = 3
        }  else {
            selectedPicker = 199
        }
        
    }
    func setLauncherOption(to value: Int) {
        
        if value == 0 {
            Dict.stringValue = "Disabled"
        } else if value == 1 {
            Dict.stringValue = "Full"
        } else if value == 2 {
            Dict.stringValue = "Short"
        }  else if value == 3 {
            Dict.stringValue = "System"
        } else if value == 199 {
            Dict.stringValue = "Disabled"
        }
        
    }
    
    func SetTableSigData(to value: Int) {
        
        // Scout set
        if value != 199 {
            
            Dict.stringValue = TableSignature[value].value
            base64value = TableSignature[value].value.data(using: .bytesHexLiteral)?.base64EncodedString() ?? ""
            
            if let HexToData =  Dict.stringValue.uppercased().filter({ "ABCDEF0123456789".contains($0) }).data(using: .bytesHexLiteral) {
                
                base64value = HexToData.base64EncodedString()
            }
        }
        
    }
    func findTableSigData(){
        
        if let IndeX = TableSignature.firstIndex(where: {$0.value == Dict.stringValue}) {
            
            selectedPicker = IndeX
        } else {
            selectedPicker = 199
        }
    }
    
    func findSecureBootModel(){
        
        if let IndeX = SecureBootModels.firstIndex(where: {$0.value == Dict.stringValue}) {
            
            selectedPicker = IndeX
        } else {
            selectedPicker = 199
        }
    }
    
    func SetMacsSystemProductName(to value: Int) {
        
        if value != 199 {
            Dict.stringValue = Macs[value]
            
            
            
        }
    }
    func SetSecureBootModel(to value: Int) {
        
        if value != 199 {
            Dict.stringValue = SecureBootModels[value].value
            
            
        } else {
            
            Dict.stringValue = "Default"
        }
        
        
    }
    func findMacsSystemProductName(){
        
        if let IndeX = Macs.firstIndex(where: {$0 == Dict.stringValue}) {
            
            selectedPicker = IndeX
        } else {
            selectedPicker = 199
        }
    }
    
    func setArchVal(to value: Int) {
        
        if value == 0 {
            Dict.stringValue = "Any"
        } else if value == 1 {
            Dict.stringValue = "i386"
        } else if value == 2 {
            Dict.stringValue = "x86_64"
        }
        
        
        
        
    }
    
    func setDmgLoading(to value: Int) {
        
        if value == 0 {
            Dict.stringValue = "Any"
        } else if value == 1 {
            Dict.stringValue = "Disabled"
        } else if value == 2 {
            Dict.stringValue = "Signed"
        } else if value == 199 {
            Dict.stringValue = "Signed"
        }
        
        
    }
    
    func findDmgLoading(){
        
        if Dict.stringValue == "Any" {
            
            selectedPicker = 0
        } else  if Dict.stringValue == "Disabled" {
            selectedPicker = 1
        }  else  if Dict.stringValue == "Signed" {
            selectedPicker = 2
        } else  {
            selectedPicker = 199
        }
        
    }
    
    func findVault(){
        
        if Dict.stringValue == "Optional" {
            
            selectedPicker = 0
        } else  if Dict.stringValue == "Basic" {
            selectedPicker = 1
        }  else  if Dict.stringValue == "Secure" {
            selectedPicker = 2
        }   else {
            selectedPicker = 199
        }
        
    }
    
    func setVault(to value: Int) {
        
        if value == 0 {
            Dict.stringValue = "Optional"
        } else if value == 1 {
            Dict.stringValue = "Basic"
        } else if value == 2 {
            Dict.stringValue = "Secure"
        } else if value == 199 {
            Dict.stringValue = "Secure"
        }
        
        
    }

    func findPickerMode(){
        
        if Dict.stringValue == "Builtin" {
            
            selectedPicker = 0
        } else  if Dict.stringValue == "External" {
            selectedPicker = 1
        }  else  if Dict.stringValue == "Apple" {
            selectedPicker = 2
        }   else {
            selectedPicker = 199
        }
        
    }
    
    func findPickerVariant(){
        
        if Dict.stringValue == "Auto" {
            
            selectedPicker = 0
        } else  if Dict.stringValue == "Default" {
            selectedPicker = 1
        }  else  if Dict.stringValue == "Old" {
            selectedPicker = 2
        }  else  if Dict.stringValue == "Modern" {
            selectedPicker = 3
        }  else {
            selectedPicker = 199
        }
        
    }
    func setPickerVariant(to value: Int) {
        
        if value == 0 {
            Dict.stringValue = "Auto"
        } else if value == 1 {
            Dict.stringValue = "Default"
        } else if value == 2 {
            Dict.stringValue = "Old"
        }  else if value == 3 {
            Dict.stringValue = "Modern"
        } else if value == 199 {
            Dict.stringValue = "Custom"
        }
        
        
    }
    
    func findHibernateMode(){
        
        if Dict.stringValue == "None" {
            selectedPicker = 0
        } else  if Dict.stringValue == "Auto" {
            selectedPicker = 1
        }  else  if Dict.stringValue == "RTC" {
            selectedPicker = 2
        }  else  if Dict.stringValue == "NVRAM" {
            selectedPicker = 3
        }  else {
            selectedPicker = 199
        }
        
    }
    func setHibernateMode(to value: Int) {
        
        if value == 0 {
            Dict.stringValue = "None"
        } else if value == 1 {
            Dict.stringValue = "Auto"
        } else if value == 2 {
            Dict.stringValue = "RTC"
        }  else if value == 3 {
            Dict.stringValue = "NVRAM"
        } else if value == 199 {
            Dict.stringValue = "None"
        }
        
        
    }
    
    
    func setPickerMode(to value: Int) {
        
        if value == 0 {
            Dict.stringValue = "Builtin"
        } else if value == 1 {
            Dict.stringValue = "External"
        } else if value == 2 {
            Dict.stringValue = "Apple"
        } else if value == 199 {
            Dict.stringValue = "Builtin"
        }
        
     
    }
    
    func findArch(){
        
        if Dict.stringValue == "Any" {
            
            selectedPicker = 0
        } else  if Dict.stringValue == "i386" {
            selectedPicker = 1
        }  else  if Dict.stringValue == "x86_64" {
            selectedPicker = 2
        }
        
    }
    
    func checkAndFix(to value: StringChanged) {
        
        if  Dict.type == "int" {
            
            var  filtered = value.what.filter { $0.isNumber }
            
            if value.what.contains("-") {
                filtered.insert("-", at: filtered.startIndex)
            }
            if Dict.stringValue != filtered {
                Dict.stringValue = filtered
            }
     
        } else  if  Dict.type == "data" {
            
                if value.which != 64 {

                    if let HexToData =  value.what.uppercased().filter({ "ABCDEF0123456789".contains($0) }).data(using: .bytesHexLiteral) {

                     
                        Dict.stringValue = value.what.uppercased().filter { "ABCDEF0123456789".contains($0) }
                        base64value = HexToData.base64EncodedString()
                    }
                    
                } else {
                  
                    let convertedVal = Base64toHex(base64value)
                 
                    Dict.stringValue = convertedVal
                }

         }

    }
    
    

    
    func setDictType(to value: Int) {
        
        if value == 0 {
            Dict.type = "string"
        } else if value == 1 {
            Dict.type = "bool"
        } else if value == 2 {
            Dict.type = "int"
            checkAndFix(to: StringChanged(which: 0, what: Dict.stringValue))
            
        }  else if value == 3 {
            Dict.type = "data"
            checkAndFix(to: StringChanged(which: 0, what: Dict.stringValue))
            
        }
        
    }
      
}


struct PickerDataList: Hashable {
    let id = UUID()
    let name: String
    let value: String
    var aux: String?
}

var TableSignature: [PickerDataList] = [PickerDataList(name:"SSDT", value: "53534454"),
                                        PickerDataList(name:"DSDT", value: "44534454"),
                                        PickerDataList(name:"HPET", value: "48504554"),
                                        PickerDataList(name:"ECDT", value: "45434454"),
                                        PickerDataList(name:"BGRT", value: "42475254"),
                                        PickerDataList(name:"MCFG", value: "4D434647"),
                                        PickerDataList(name:"DMAR", value: "444D4152"),
                                        PickerDataList(name:"APIC", value: "41504943"),
                                        PickerDataList(name:"ASFT", value: "41534654"),
                                        PickerDataList(name:"SBST", value: "53425354"),
                                        PickerDataList(name:"SLIC", value: "534C4943"),
                                        PickerDataList(name:"MATS", value: "4D415453"),
                                        PickerDataList(name:"BATB", value: "42415442"),
                                        PickerDataList(name:"UEFI", value: "55454649")
]

var outputResolutions: [PickerDataList] = [
    PickerDataList(name:"1024x600", value: "1024x600"),
    PickerDataList(name:"1024x768", value: "1024x768"),
    PickerDataList(name:"1152x864", value: "1152x864"),
    PickerDataList(name:"1280x720", value: "1280x720"),
    PickerDataList(name:"1280x800", value: "1280x800"),
    PickerDataList(name:"1280x1024", value: "1280x1024"),
    PickerDataList(name:"1360x768", value: "1360x768"),
    PickerDataList(name:"1366x768", value: "1366x768"),
    PickerDataList(name:"1400x1050", value: "1400x1050"),
    PickerDataList(name:"1440x900", value: "1440x900"),
    PickerDataList(name:"1600x900", value: "1600x900"),
    PickerDataList(name:"1600x1200", value: "1600x1200"),
    PickerDataList(name:"1680x1050", value: "1680x1050"),
    PickerDataList(name:"1920x1080", value: "1920x1080"),
    PickerDataList(name:"2048x1252", value: "2048x1252"),
    PickerDataList(name:"2048x1536", value: "2048x1536"),
    PickerDataList(name:"2560x1600", value: "2560x1600"),
    PickerDataList(name:"2560x2048", value: "2560x2048"),
    PickerDataList(name:"3840×2160", value: "3840×2160"),
    PickerDataList(name:"4096×2160", value: "4096×2160"),
    PickerDataList(name:"5120×2880", value: "5120×2880"),
    PickerDataList(name:"Max", value: "Max")]

var ReservedMemory: [PickerDataList] = [
    PickerDataList(name: "Reserved — EfiReservedMemoryType", value: "Reserved"),
    PickerDataList(name: "LoaderCode — EfiLoaderCode", value: "LoaderCode"),
    PickerDataList(name: "LoaderData — EfiLoaderData", value: "LoaderData"),
    PickerDataList(name: "BootServiceCode — EfiBootServicesCode", value: "BootServiceCode"),
    PickerDataList(name: "BootServiceData — EfiBootServicesData", value: "BootServiceData"),
    PickerDataList(name: "RuntimeCode — EfiRuntimeServicesCode", value: "RuntimeCode"),
    PickerDataList(name: "RuntimeData — EfiRuntimeServicesData", value: "RuntimeData"),
    PickerDataList(name: "Available — EfiConventionalMemory", value: "Available"),
    PickerDataList(name: "Persistent — EfiPersistentMemory", value: "Persistent"),
    PickerDataList(name: "UnusableMemory — EfiUnusableMemory", value: "UnusableMemory"),
    PickerDataList(name: "ACPIReclaimMemory — EfiACPIReclaimMemory", value: "ACPIReclaimMemory"),
    PickerDataList(name: "ACPIMemoryNVS — EfiACPIMemoryNVS", value: "ACPIMemoryNVS"),
    PickerDataList(name: "MemoryMappedIO — EfiMemoryMappedIO", value: "MemoryMappedIO"),
    PickerDataList(name: "MemoryMappedIOPortSpace — EfiMemoryMappedIOPortSpace", value: "MemoryMappedIOPortSpace"),
    PickerDataList(name: "PalCode — EfiPalCode", value: "PalCode"),
]

let APFSMinVersion: [PickerDataList] = [PickerDataList(name:"require the default supported version of APFS in OpenCore.", value: "0", aux: "0"),
                                        PickerDataList(name:"permit any version to load (strongly discouraged).", value: "-1", aux: "-1"),
                                        PickerDataList(name:"High Sierra", value: "7480770080000000", aux: "20180621"),
                                        PickerDataList(name:"Mojave", value: "9452750070000000", aux: "20190820"),
                                        PickerDataList(name:"Catalina", value: "1412101001000000", aux: "20200306"),
                                        PickerDataList(name:"Big Sur", value: "1677120009000000", aux: "20210508")]



var SecureBootModels: [PickerDataList] = [PickerDataList(name:"Default — Recent available model", value: "Default"),
                                          PickerDataList(name:"Disabled — No model, Secure Boot will be disabled.", value: "Disabled"),
                                          PickerDataList(name:"j137 — iMacPro1,1 (December 2017). macOS 10.13.2+", value: "j137"),
                                          PickerDataList(name:"j680 — MacBookPro15,1 (July 2018). macOS 10.13.6+", value: "j680"),
                                          PickerDataList(name:"j132 — MacBookPro15,2 (July 2018). macOS 10.13.6+", value: "j132"),
                                          PickerDataList(name:"j174 — Macmini8,1 (October 2018). macOS 10.14+", value: "j174"),
                                          PickerDataList(name:"j140k — MacBookAir8,1 (October 2018). macOS 10.14.1+", value: "j140k"),
                                          PickerDataList(name:"j780 — MacBookPro15,3 (May 2019). macOS 10.14.5+", value: "j780"),
                                          PickerDataList(name:"j213 — MacBookPro15,4 (July 2019). macOS 10.14.5+", value: "j213"),
                                          PickerDataList(name:"j140a — MacBookAir8,2 (July 2019). macOS 10.14.5+", value: "j140a"),
                                          PickerDataList(name:"j152f — MacBookPro16,1 (November 2019). macOS 10.15.1+", value: "j152f"),
                                          PickerDataList(name:"j160 — MacPro7,1 (December 2019). macOS 10.15.1+", value: "j160"),
                                          PickerDataList(name:"j230k — MacBookAir9,1 (March 2020). macOS 10.15.3+", value: "j230k"),
                                          PickerDataList(name:"j214k — MacBookPro16,2 (May 2020). macOS 10.15.4+", value: "j214k"),
                                          PickerDataList(name:"j223 — MacBookPro16,3 (May 2020). macOS 10.15.4+", value: "j223"),
                                          PickerDataList(name:"j215 — MacBookPro16,4 (June 2020). macOS 10.15.5+", value: "j215"),
                                          PickerDataList(name:"j185 — iMac20,1 (August 2020). macOS 10.15.6+", value: "j185"),
                                          PickerDataList(name:"j185f — iMac20,2 (August 2020). macOS 10.15.6+", value: "j185f"),
                                          PickerDataList(name:"x86legacy — Macs without T2 chip and VMs. macOS 11.0.1+", value: "x86legacy")
]






struct PopoverForOptions: View {
    @Binding var value: String
    @State var selectingOptions: [HAPMultiOptions] = []
    var body: some View {
        VStack(alignment: .leading) {
                                   
            
            ForEach(selectingOptions.indexed(), id:\.element.id) { (idx, opt) in
                Toggle("0x\(String(opt.value, radix: 16).uppercased()) — \(opt.info)", isOn: $selectingOptions[idx].isSelected.toggled(opt.value, "", calculateSelectedSum))
                
            }
        }.padding(.all)
        .onAppear {
            
            if Int(value) != nil {
                for opt in calculateSelected(Int(value)!, selectingOptions) {
                    if let indeX = selectingOptions.firstIndex(of: opt) {
                        selectingOptions[indeX].isSelected = true
                    }
                }
            }
            
            
        }
    }
    
    func calculateSelectedSum(to valueo: ToggleChanged) {
        if valueo.yes {
          var calculated = Int(value)!
            calculated += valueo.which
            value = String(calculated)
        } else {
            var calculated = Int(value)!
              calculated -= valueo.which
              value = String(calculated)
        }
    }
}

struct ConsoleAttributesView: View {
    @Binding var stringValue: String
    @State var selectedForeground: Int = 0
    @State var selectedBackground: Int = 0
    
    @State var customValue:Bool = false
    
    let foregrounds = [
        HAPMultiOptions(value: 0, isSelected: false, info: "EFI_BLACK"),
        HAPMultiOptions(value: 1, isSelected: false, info: "EFI_BLUE"),
        HAPMultiOptions(value: 2, isSelected: false, info: "EFI_GREEN"),
        HAPMultiOptions(value: 3, isSelected: false, info: "EFI_CYAN"),
        HAPMultiOptions(value: 4, isSelected: false, info: "EFI_RED"),
        HAPMultiOptions(value: 5, isSelected: false, info: "EFI_MAGENTA"),
        HAPMultiOptions(value: 6, isSelected: false, info: "EFI_BROWN"),
        HAPMultiOptions(value: 7, isSelected: false, info: "EFI_LIGHTGRAY"),
        HAPMultiOptions(value: 8, isSelected: false, info: "EFI_DARKGRAY"),
        HAPMultiOptions(value: 9, isSelected: false, info: "EFI_LIGHTBLUE"),
        HAPMultiOptions(value: 10, isSelected: false, info: "EFI_LIGHTGREEN"),
        HAPMultiOptions(value: 11, isSelected: false, info: "EFI_LIGHTCYAN"),
        HAPMultiOptions(value: 12, isSelected: false, info: "EFI_LIGHTRED"),
        HAPMultiOptions(value: 13, isSelected: false, info: "EFI_LIGHTMAGENTA"),
        HAPMultiOptions(value: 14, isSelected: false, info: "EFI_YELLOW"),
        HAPMultiOptions(value: 15, isSelected: false, info: "EFI_WHITE"),]
    
    
  
    
    let backgrounds = [
        HAPMultiOptions(value: 0, isSelected: false, info: "EFI_BACKGROUND_BLACK"),
        HAPMultiOptions(value: 16, isSelected: false, info: "EFI_BACKGROUND_BLUE"),
        HAPMultiOptions(value: 32, isSelected: false, info: "EFI_BACKGROUND_GREEN"),
        HAPMultiOptions(value: 48, isSelected: false, info: "EFI_BACKGROUND_CYAN"),
        HAPMultiOptions(value: 64, isSelected: false, info: "EFI_BACKGROUND_RED"),
        HAPMultiOptions(value: 80, isSelected: false, info: "EFI_BACKGROUND_MAGENTA"),
        HAPMultiOptions(value: 96, isSelected: false, info: "EFI_BACKGROUND_BROWN"),
        HAPMultiOptions(value: 112, isSelected: false, info: "EFI_BACKGROUND_LIGHTGRAY"),
    ]
    
    var body: some View {
        HStack {
           
                
            
            if customValue {
                Button("Select") {
                    customValue = false
                }
                Text("Sum:")
                  
                TextField("Number", text: $stringValue)
                
                
                    
            } else {
                Picker(selection: $selectedForeground.pickerChanged(setstringValue), label: Text("")) {
                    
                    ForEach(foregrounds, id:\.self) { foreground in
                        
                        Text("0x\(String(foreground.value, radix: 16).uppercased()) — \(foreground.info)").tag(foreground.value)
                    }
                 
                    Divider()
                    Text("Other").tag(199)
                  
                }.labelsHidden()
                  
               
                Picker(selection: $selectedBackground.pickerChanged(setstringValue), label: Text("")) {
                    
                    ForEach(backgrounds, id:\.self) { background in
                        
                        Text("0x\(String(background.value, radix: 16).uppercased()) — \(background.info)").tag(background.value)
                    }
                 
                    Divider()
                    Text("Other").tag(199)
                  
                }.labelsHidden()
                
                
                    .onAppear {
                        
                        if Int(stringValue) != nil && Int(stringValue)! > 16 {
                            
                            let foundValues = calculateSelected(Int(stringValue)!, [
                                HAPMultiOptions(value: 1, isSelected: false, info: "EFI_BLUE"),
                                HAPMultiOptions(value: 2, isSelected: false, info: "EFI_GREEN"),
                                HAPMultiOptions(value: 3, isSelected: false, info: "EFI_CYAN"),
                                HAPMultiOptions(value: 4, isSelected: false, info: "EFI_RED"),
                                HAPMultiOptions(value: 5, isSelected: false, info: "EFI_MAGENTA"),
                                HAPMultiOptions(value: 6, isSelected: false, info: "EFI_BROWN"),
                                HAPMultiOptions(value: 7, isSelected: false, info: "EFI_LIGHTGRAY"),
                                HAPMultiOptions(value: 8, isSelected: false, info: "EFI_DARKGRAY"),
                                HAPMultiOptions(value: 9, isSelected: false, info: "EFI_LIGHTBLUE"),
                                HAPMultiOptions(value: 10, isSelected: false, info: "EFI_LIGHTGREEN"),
                                HAPMultiOptions(value: 11, isSelected: false, info: "EFI_LIGHTCYAN"),
                                HAPMultiOptions(value: 12, isSelected: false, info: "EFI_LIGHTRED"),
                                HAPMultiOptions(value: 13, isSelected: false, info: "EFI_LIGHTMAGENTA"),
                                HAPMultiOptions(value: 14, isSelected: false, info: "EFI_YELLOW"),
                                HAPMultiOptions(value: 15, isSelected: false, info: "EFI_WHITE"),
                                HAPMultiOptions(value: 16, isSelected: false, info: "EFI_BACKGROUND_BLUE"),
                                HAPMultiOptions(value: 32, isSelected: false, info: "EFI_BACKGROUND_GREEN"),
                                HAPMultiOptions(value: 48, isSelected: false, info: "EFI_BACKGROUND_CYAN"),
                                HAPMultiOptions(value: 64, isSelected: false, info: "EFI_BACKGROUND_RED"),
                                HAPMultiOptions(value: 80, isSelected: false, info: "EFI_BACKGROUND_MAGENTA"),
                                HAPMultiOptions(value: 96, isSelected: false, info: "EFI_BACKGROUND_BROWN"),
                                HAPMultiOptions(value: 112, isSelected: false, info: "EFI_BACKGROUND_LIGHTGRAY")
                            ])
                            
                            
                            for opt in foundValues {
                             
                                if let indeX = foregrounds.firstIndex(of: opt) {
                                    selectedForeground = foregrounds[indeX].value
                                }
                                if let indeX = backgrounds.firstIndex(of: opt) {
                                    selectedBackground = backgrounds[indeX].value
                                }
                            }
                        }
                        
                        
                    }
            }
            
            
            
        }
        
    }
    
    func setstringValue(to value: Int) {
        if value != 199 {
            stringValue = String(selectedForeground + selectedBackground)
            customValue = false
            
        } else {
            customValue = true
        }
       
     
    }
}
