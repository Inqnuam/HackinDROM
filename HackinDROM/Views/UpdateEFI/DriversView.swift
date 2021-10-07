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
    @Binding var PreparingDrivers: [Drivers]
    
    var  isWorking: Bool
    
    
    func bindingChild(for index: Int) -> Binding<Drivers> {
        .init(get: {
            guard PreparingDrivers.indices.contains(index) else { return Drivers() } // check if `index` is valid
            return PreparingDrivers[index]
        }, set: {
            PreparingDrivers[index] = $0
        })
    }
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
                    
                    ForEach(PreparingDrivers, id: \.self) { element in
                        if let index = PreparingDrivers.firstIndex(where: {$0 == element})  {
                        HStack {
                            if #available(macOS 11.0, *) {
                                Toggle("", isOn: bindingChild(for:index).isSelected)
                                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                                    .padding(.leading, 5)
                                    .disabled(isWorking)
                                Toggle("", isOn: bindingChild(for:index).Enabled.toggled(index, "", ChangeDriverStatus)) // .onChange(intChanged)
                                    .toggleStyle(SwitchToggleStyle(tint: .green))
                                    .disabled(isWorking)
                                
                            } else {
                                HDToggleView(isOn: bindingChild(for:index).isSelected, togCol: Color(.systemBlue), disabled: isWorking)
                                    .padding(.leading, 25)
                                
                                HDToggleView(isOn: bindingChild(for:index).Enabled.toggled(index, "", ChangeDriverStatus), disabled: isWorking)
                                    .padding(.leading, 25)
                                    .padding(.trailing, 10)
                                
                                
                            }
                            Text(PreparingDrivers[index].Path.replacingOccurrences(of: "#", with: "").replacingOccurrences(of: ".efi", with: ""))
                            
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
    }
    
    func ChangeDriverStatus(to value: ToggleChanged) {
        
        if value.yes {
            PreparingDrivers[value.which].Path = PreparingDrivers[value.which].Path.replacingOccurrences(of: "#", with: "")
        } else {
            PreparingDrivers[value.which].Path = "#\( PreparingDrivers[value.which].Path)"
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
