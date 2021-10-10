//
//  ACPI.swift
//  HackinDROM EFI
//
//  Created by Inqnuam 09/02/2021.
//  Copyright © 2021 HackinDROM. All rights reserved.
//

import SwiftUI

struct ACPI: View {
    @Binding var PreparingAMLs: [SelectingAMLs]
    var  isWorking: Bool
    @State var selectedId:Int = 0
    
    
    func bindingChild(for index: Int) -> Binding<SelectingAMLs> {
        .init(get: {
            guard PreparingAMLs.indices.contains(index) else { return SelectingAMLs() } // check if `index` is valid
            return PreparingAMLs[index]
        }, set: {
            PreparingAMLs[index] = $0
        })
    }
    var body: some View {
        
        VStack {
            if PreparingAMLs.isEmpty {
                Spacer()
                Text("No .aml files...")
                LoaderView()
                Spacer()
                
            } else {
                UpateViewTableHeader()
                Divider()
            }
            
            List {
               
                           
              ForEach(PreparingAMLs.indexed(), id:\.element.id) { (index, element) in
                
              
                    HStack {
                        if #available(OSX 11.0, *) {
                            Toggle("", isOn:  $PreparingAMLs[index].isSelected)
                                .labelsHidden()
                                .toggleStyle(SwitchToggleStyle(tint: .blue))
                                
                                .padding(.leading, 5)
                                .disabled(isWorking)
                            
                            Toggle("", isOn:  $PreparingAMLs[index].AML.Enabled)
                                .labelsHidden()
                                .toggleStyle(SwitchToggleStyle(tint: .green))
                                .disabled(isWorking)
                        } else {
                            HDToggleView(isOn:  $PreparingAMLs[index].isSelected, togCol: Color(.systemBlue), disabled: isWorking)
                                .padding(.leading, 25)
                            HDToggleView(isOn:  $PreparingAMLs[index].AML.Enabled, disabled: isWorking)
                                .padding(.leading, 25)
                                .padding(.trailing, 10)
                            
                        }
                        Button(element.AML.Path.replacingOccurrences(of: ".aml", with: "")) {
                            selectedId = index
                        } .buttonStyle(PlainButtonStyle())
                        
//                        .popover(isPresented: self.makeIsPresented(index)) {
//
//                            Text(PreparingAMLs[index].AML.Comment)
//                                .padding(8)
//                        }
//
                        
                        Spacer()
                    }
                    .contextMenu(ContextMenu(menuItems: {
                        
                        Button("Remove") {
                            
                            PreparingAMLs.remove(at: index)
                        }
                        
                    }))
                    
                
              }
            }
            
        }
    }
    func makeIsPresented(_ item: Int) -> Binding<Bool> {
        return .init(get: {
            return self.selectedId == item && !PreparingAMLs[item].AML.Comment.isEmpty
        }, set: { _ in
        })
    }
}






struct UpateViewTableHeader: View {
    var body: some View {
        HStack {
            Text("Update")
                .font(.subheadline)
                
                .padding(.trailing, 7)
            Text("Enable")
                .font(.subheadline)
            
            Text("Path")
                .font(.subheadline)
            
            Spacer()
            
        }.padding(.leading, 18)
    }
    
}
