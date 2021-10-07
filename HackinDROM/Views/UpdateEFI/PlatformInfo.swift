//
//  PlatformInfo.swift
//  HackinDROM EFI
//
//  Created by Inqnuam 08/02/2021.
//  Copyright © 2021 HackinDROM. All rights reserved.
//

import SwiftUI

var FontSize: CGFloat {

    if #available(OSX 11.0, *) {

        return 15

    } else {

        return 15
    }

}
struct PlatformInfo: View {

    @EnvironmentObject var sharedData: HASharedData
    @Binding var mycustomdata: MyHackDataStrc
    @State var MyRom: String = ""
    @State var EnableSIP: Bool = false
    var  isWorking: Bool

    var body: some View {

        ScrollView {
            VStack {
                // Text("Boot Arguments").font(.headline)

                Section(header: Text("Boot Arguments").font(.system(size: FontSize)).bold() ) {

                    if #available(OSX 11.0, *) {
                        TextEditor(text: $mycustomdata.BootArgs)
                            .frame(height: 50)
                            .disabled(isWorking)
                    } else {
                        TextField("Boot arguments", text: $mycustomdata.BootArgs)
                            .disabled(isWorking)
                        // .frame(weight: 50)

                    }
                }
                Divider()
                if sharedData.Updating == "Update" {
                    HStack {

                        VStack(spacing: 2) {
                        
                            Text("System Product Name").font(.system(size: FontSize)).bold()
                            TextField("Required", text: $mycustomdata.SystemProductName)
                                .disabled(isWorking)
                        }
                        VStack(spacing: 2) {
                           
                            Text("System Serial Number").font(.system(size: FontSize)).bold()
                            TextField("Required", text: $mycustomdata.SystemSerialNumber)
                                .disabled(isWorking)
                        }

                    }

                    HStack {
                        VStack(spacing: 2) {
                         
                            Text("Motherboard").font(.system(size: FontSize)).bold()
                            TextField("Required", text: $mycustomdata.MLB)
                                .disabled(isWorking)
                        }

                        //  Spacer()
                        VStack(spacing: 2) {
                            
                            Text("ROM").font(.system(size: FontSize)).bold()

                            HStack {

                                TextField("Required", text: $mycustomdata.ROM.stringChanged(0, SetNewRom))
                                Text(MyRom)
                                    .font(.system(size: 10))
                                    .disabled(isWorking)
                            }

                        }

                    }

                    Section(header: Text("System UUID").font(.system(size: FontSize)).bold()  .padding(.top, 10)) {
                        TextField("Required", text: $mycustomdata.SystemUUID)

                    }

                }
                Divider()
                Button("Import from My System") {

                    mycustomdata = MyHackData

                    if mycustomdata.SIP == "00000000" {
                        EnableSIP = true

                    } else {
                        EnableSIP = false
                    }

                }
                HStack {
                    if #available(OSX 11.0, *) {
                        Toggle("Enable SIP", isOn: $EnableSIP.toggled(0, "", SetSIPValue))
                            .toggleStyle(SwitchToggleStyle(tint: .green))
                    } else {
                        Toggle("Enable SIP", isOn: $EnableSIP.toggled(0, "", SetSIPValue))

                    }
                    if !EnableSIP {

                        TextField("Custom SIP value", text: $mycustomdata.SIP)
                            .frame(width: 110)
                    }
                    Spacer()
                }
            }
            .padding(10)

        }
        .onAppear {
            if mycustomdata.SIP == "00000000" {
                EnableSIP = true

            }

            MyRom = (mycustomdata.ROM.data(using: .bytesHexLiteral)?.base64EncodedString()) ?? "invalid"

            mycustomdata.ROM = String(mycustomdata.ROM.prefix(12))

        }

    }
    func SetSIPValue(to value: ToggleChanged) {

        if value.yes {
            mycustomdata.SIP = "00000000"

        } else {

            mycustomdata.SIP = "E7030000"
        }

    }

    func SetNewRom(to value: StringChanged) {

        MyRom = (value.what.data(using: .bytesHexLiteral)?.base64EncodedString()) ?? "invalid"
        mycustomdata.ROM = String(value.what.prefix(12))
    }
}
