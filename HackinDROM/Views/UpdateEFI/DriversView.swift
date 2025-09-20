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
    
    func bindingChild(for index: Int) -> Binding<SelectingDrivers> {
        .init(get: {
            guard PreparingDrivers.indices.contains(index) else { return SelectingDrivers() } // check if `index` is valid
            return PreparingDrivers[index]
        }, set: {
            PreparingDrivers[index] = $0
        })
    }
    var body: some View {
        
        VStack {
            
            if PreparingDrivers.isEmpty {
                
                
                HStack {
                    Spacer()
                    Text("Analyzing Drivers...")
                    if #available(OSX 11.0, *) {
                        ProgressView()
                    }
                    Spacer()
                }
                
                
                
            } else {
                UpateViewTableHeader()
                Divider()
                
                List {
                    ForEach(PreparingDrivers.indexed(), id:\.element.id) { (index, element) in
                        
                        HStack {
                            if #available(macOS 11.0, *) {
                                Toggle("", isOn: bindingChild(for: index).isSelected)
                                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                                    .padding(.leading, 5)
                                    .disabled(isWorking)
                                Toggle("", isOn: bindingChild(for: index).Driver.Enabled.toggled(index, "", ChangeDriverStatus))
                                    .toggleStyle(SwitchToggleStyle(tint: .green))
                                    .disabled(isWorking)
                                
                            } else {
                                HDToggleView(isOn: bindingChild(for: index).isSelected, togCol: Color(.systemBlue), disabled: isWorking)
                                    .padding(.leading, 25)
                                
                                HDToggleView(isOn: bindingChild(for: index).Driver.Enabled.toggled(index, "", ChangeDriverStatus), disabled: isWorking)
                                    .padding(.leading, 25)
                                    .padding(.trailing, 10)
                                
                                
                            }
                            Text(element.Driver.Path.replacingOccurrences(of: "#", with: "").replacingOccurrences(of: ".efi", with: ""))
                                .contextMenu(ContextMenu(menuItems: {
                                    
                                    Button("Remove") {
                                        
                                        PreparingDrivers.remove(at: index)
                                    }
                                    
                                }))
                            
                            Spacer()
                        }.id(index)
                        
                        
                    }
                }
                
            }
        }
        Spacer()
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
