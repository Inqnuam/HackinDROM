//
//  DriversView.swift
//  HackinDROM EFI
//
//  Created by Inqnuam 15/02/2021.
//  Copyright © 2021 HackinDROM. All rights reserved.
//

import SwiftUI

struct DriversView: View {
    @EnvironmentObject var sharedData: HASharedData
    @Binding var PreparingDrivers: [SelectingDrivers]
    
    var  isWorking: Bool
    var body: some View {
        
        VStack {
            
            if PreparingDrivers.isEmpty {
                
                Spacer()
                Text("Analyzing Drivers...")
                if #available(OSX 11.0, *) {
                    ProgressView()
                }
                Spacer()
                
            } else {
                UpateViewTableHeader()
                Divider()
                
                List {
                    
                    ForEach(PreparingDrivers.indexed(), id:\.element.id) { (index, element) in
                       
                        HStack {
                            if #available(macOS 11.0, *) {
                                Toggle("", isOn: $PreparingDrivers[index].isSelected)
                                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                                    .padding(.leading, 5)
                                    .disabled(isWorking)
                                Toggle("", isOn: $PreparingDrivers[index].Driver.Enabled.toggled(index, "", ChangeDriverStatus)) // .onChange(intChanged)
                                    .toggleStyle(SwitchToggleStyle(tint: .green))
                                    .disabled(isWorking)
                                
                            } else {
                                HDToggleView(isOn: $PreparingDrivers[index].isSelected, togCol: Color(.systemBlue), disabled: isWorking)
                                    .padding(.leading, 25)
                                
                                HDToggleView(isOn: $PreparingDrivers[index].Driver.Enabled.toggled(index, "", ChangeDriverStatus), disabled: isWorking)
                                    .padding(.leading, 25)
                                    .padding(.trailing, 10)
                                
                                
                            }
                            Text(PreparingDrivers[index].Driver.Path.replacingOccurrences(of: "#", with: "").replacingOccurrences(of: ".efi", with: ""))
                            
                            Spacer()
                        }
                        .contextMenu(ContextMenu(menuItems: {
                            
                            Button("Remove") {
                                
                                PreparingDrivers.remove(at: index)
                            }
                            
                        }))
                        
                    
                    
                }
                
                }
                
            }
        }
    }
    
    func ChangeDriverStatus(to value: ToggleChanged) {
        
        if value.yes {
            PreparingDrivers[value.which].Driver.Path = PreparingDrivers[value.which].Driver.Path.replacingOccurrences(of: "#", with: "")
        } else {
            PreparingDrivers[value.which].Driver.Path = "#\( PreparingDrivers[value.which].Driver.Path)"
        }
        
    }
}

struct ToggleChanged {
    
    var which: Int = 0
    var yes: Bool = false
    var name: String = ""
    
}

struct StringChanged {
    
    var which: Int
    var what: String
    
}
