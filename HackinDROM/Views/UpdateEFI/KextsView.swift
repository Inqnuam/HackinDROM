//
//  KextsView.swift
//  HackinDROM EFI
//
//  Created by Inqnuam 08/02/2021.
//  Copyright © 2021 HackinDROM. All rights reserved.
//

import SwiftUI

struct KextsView: View {
    
    @EnvironmentObject var sharedData: HASharedData
    
    @Binding var PreparingKexts: [SelectingKexts]
    @State var selectedId:Int = 0
    
    var  isWorking: Bool
    
    
    func bindingChild(for index: Int) -> Binding<SelectingKexts> {
        .init(get: {
            guard PreparingKexts.indices.contains(index) else { return SelectingKexts() } // check if `index` is valid
            return PreparingKexts[index]
        }, set: {
            PreparingKexts[index] = $0
        })
    }
    var body: some View {
        
        VStack {
            if PreparingKexts.isEmpty {
                
                Spacer()
                Text("Analyzing Kexts...")
                if #available(OSX 11.0, *) {
                    ProgressView()
                }
                Spacer()
                
            } else {
                UpateViewTableHeader()
                Divider()
            }
            
            
            List {
                
                ForEach(PreparingKexts.indexed(), id:\.element.id) { (index, element) in
                    
                    HStack {
                        if #available(OSX 11.0, *) {
                            Toggle("", isOn: $PreparingKexts[index].isSelected)
                                
                                .toggleStyle(SwitchToggleStyle(tint: .blue))
                                
                                .padding(.leading, 5)
                                .disabled(isWorking)
                            Toggle("", isOn: $PreparingKexts[index].Kext.Enabled)
                                .toggleStyle(SwitchToggleStyle(tint: .green))
                                .disabled(isWorking)
                        } else {
                            HDToggleView(isOn: $PreparingKexts[index].isSelected, togCol: Color(.systemBlue), disabled: isWorking)
                                .padding(.leading, 25)
                            HDToggleView(isOn: $PreparingKexts[index].Kext.Enabled, disabled: isWorking)
                                .padding(.leading, 25)
                                .padding(.trailing, 10)
                            
                        }
                       
                        Button(PreparingKexts[index].Kext.BundlePath.replacingOccurrences(of: ".kext", with: "")) {
                            selectedId = index
                        } .buttonStyle(PlainButtonStyle())
                            
                        Text(element.Kext.BundlePath.replacingOccurrences(of: ".kext", with: ""))
                            .toolTip(element.Kext.Comment)
                        Spacer()
                    }
                    .contextMenu(ContextMenu(menuItems: {
                        
                        Button("Remove") {
                            
                            PreparingKexts.remove(at: index)
                        }
                        
                    }))
                    
                
                }
            }.background(Color.clear)
            
            
        }
    }
    
    
    func makeIsPresented(_ item: Int) -> Binding<Bool> {
        return .init(get: {
            return self.selectedId == item && !PreparingKexts[item].Kext.Comment.isEmpty
        }, set: { _ in
        })
    }
}
